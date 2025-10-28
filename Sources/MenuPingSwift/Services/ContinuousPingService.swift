//
// ContinuousPingService.swift
// MenuPingSwift
//
// Service de ping continu qui maintient un process /sbin/ping actif
// et parse sa sortie en streaming pour éviter le "cold start" à chaque mesure.
// Utilise Swift Regex moderne et strict concurrency (macOS 15+)
//

import Foundation
import Observation

/// Service for continuous ping monitoring
@Observable
@MainActor
final class ContinuousPingService {
    
    /// Current host being pinged
    private(set) var currentHost: String?
    
    /// Callback called when a new latency measurement arrives
    /// Note: Marked as @ObservationIgnored to allow nonisolated(unsafe) access
    @ObservationIgnored
    nonisolated(unsafe) var onLatencyUpdate: (@MainActor @Sendable (Double) -> Void)?
    
    /// Callback called when ping fails
    /// Note: Marked as @ObservationIgnored to allow nonisolated(unsafe) access
    @ObservationIgnored
    nonisolated(unsafe) var onFailure: (@MainActor @Sendable () -> Void)?
    
    /// Minimum interval between ping updates (in seconds)
    var minInterval: TimeInterval = 1.0
    
    private var process: Process?
    private var readTask: Task<Void, Never>?
    private var lastUpdateTime: Date?
    
    /// Start continuous ping to the specified host
    func startPinging(host: String) {
        // Stop any existing ping
        stopPinging()
        
        currentHost = host
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/sbin/ping")
        // No -c flag = infinite pings, avoiding cold start on each measurement
        process.arguments = ["-n", host]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            self.process = process
            
            // Read output asynchronously line by line
            readTask = Task { [weak self] in
                guard let self = self else { return }
                
                do {
                    for try await line in pipe.fileHandleForReading.bytes.lines {
                        // Check if task was cancelled
                        if Task.isCancelled {
                            break
                        }
                        
                        // Parse latency from line
                        if let latency = Self.parseLatency(from: line) {
                            // Check if enough time has passed since last update
                            let now = Date()
                            let shouldUpdate = lastUpdateTime == nil || 
                                             now.timeIntervalSince(lastUpdateTime!) >= minInterval
                            
                            if shouldUpdate {
                                await MainActor.run {
                                    self.lastUpdateTime = now
                                    self.onLatencyUpdate?(latency)
                                }
                            }
                        } else if line.contains("Request timeout") || 
                                  line.contains("100.0% packet loss") ||
                                  line.contains("No route to host") ||
                                  line.contains("Host is down") ||
                                  line.contains("Network is unreachable") ||
                                  line.contains("sendto: No route to host") {
                            await MainActor.run {
                                self.onFailure?()
                            }
                        }
                    }
                } catch {
                    // Stream ended or error occurred
                    if !Task.isCancelled {
                        await MainActor.run {
                            self.onFailure?()
                        }
                    }
                }
            }
            
        } catch {
            onFailure?()
        }
    }
    
    /// Stop the continuous ping
    func stopPinging() {
        readTask?.cancel()
        readTask = nil
        
        if let process = process, process.isRunning {
            process.terminate()
        }
        
        process = nil
        currentHost = nil
        lastUpdateTime = nil
    }
    
    /// Parse latency from a ping output line using modern Swift Regex
    /// - Parameter line: A line from ping output
    /// - Returns: The latency in milliseconds, or nil if no match
    private static func parseLatency(from line: String) -> Double? {
        // Use modern Swift Regex literal - compile-time checked and more efficient
        let regex = /time=([0-9.]+) ms/
        
        guard let match = line.firstMatch(of: regex) else {
            return nil
        }
        
        return Double(match.1)
    }
    
    // Note: No explicit deinit needed - Swift 6's modern actor isolation
    // ensures proper cleanup. Call stopPinging() explicitly before deallocation if needed.
}

