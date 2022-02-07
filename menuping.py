#!/usr/bin/env python3
import sys

import rumps
from ping3 import ping

rumps.debug_mode(True)

class MenuPingApp(rumps.App):
    def __init__(self):
        super(MenuPingApp, self).__init__("MenuPing")

        self.ping_url = "www.google.fr"
        self.menu = [
            rumps.MenuItem('About'),
            'Preferences'
        ]

        self.timer = rumps.Timer(self.on_tick, 1)
        self.start = 97
        self.timer.start()


    def on_tick(self, sender):
        delay = ping(self.ping_url)
        self.title = "{:.0f} ms".format(delay*1000)

if __name__ == "__main__":
    app = MenuPingApp()
    app.title = "Loading"
    app.run()