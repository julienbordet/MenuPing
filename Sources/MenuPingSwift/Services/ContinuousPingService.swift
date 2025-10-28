//
// ContinuousPingService.swift
// MenuPingSwift
//
// Service de ping continu qui maintient un process /sbin/ping actif
// et parse sa sortie en streaming pour éviter le "cold start" à chaque mesure.
//

import Foundation

/// Service for continuous ping monitoring
@MainActor
class ContinuousPingService: ObservableObject {
    
    /// Current host being pinged
    @Published private(set) var currentHost: String?
    
    /// Callback called when a new latency measurement arrives
    var onLatencyUpdate: ((Double) -> Void)?
    
    /// Callback called when ping fails
    var onFailure: (() -> Void)?
    
    private var process: Process?
    private var readTask: Task<Void, Never>?
    
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
                            await MainActor.run {
                                self.onLatencyUpdate?(latency)
                            }
                        } else if line.contains("Request timeout") || line.contains("100.0% packet loss") {
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
    }
    
    /// Parse latency from a ping output line
    /// - Parameter line: A line from ping output
    /// - Returns: The latency in milliseconds, or nil if no match
    private static func parseLatency(from line: String) -> Double? {
        // Look for "time=XX.XX ms" pattern
        let pattern = "time=([0-9.]+) ms"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }
        
        let range = NSRange(line.startIndex..., in: line)
        guard let match = regex.firstMatch(in: line, range: range) else {
            return nil
        }
        
        guard let latencyRange = Range(match.range(at: 1), in: line) else {
            return nil
        }
        
        let latencyString = String(line[latencyRange])
        return Double(latencyString)
    }
    
    nonisolated deinit {
        // Cleanup will happen when process and task are deallocated
        // The task will be cancelled automatically
        let processToTerminate = process
        if let processToTerminate = processToTerminate, processToTerminate.isRunning {
            processToTerminate.terminate()
        }
    }
}

