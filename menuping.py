#!/usr/bin/env python3
import sys

import rumps
from ping3 import ping
import os
from os.path import expanduser
import shutil

rumps.debug_mode(True)

# Global variables

unchecked_make_persistant_menu = "Launch at startup"
checked_make_persistant_menu = "✓ " + unchecked_make_persistant_menu

plist_dir = "resources"
plist_model_filename = "com.zejames.MenuPing-model.plist"
plist_filename = "com.zejames.MenuPing.plist"

target_dir = expanduser("~") + '/Library/LaunchAgents'


class MenuPingApp(rumps.App):

    def __init__(self):
        super(MenuPingApp, self).__init__("MenuPing")

        # Check if we are already persistant
        if os.path.isfile(target_dir + '/' + plist_filename):
            self.is_persistant = True
            self.persistant_menu = rumps.MenuItem(checked_make_persistant_menu, self.manage_persistant)
        else:
            self.is_persistant = False
            self.persistant_menu = rumps.MenuItem(unchecked_make_persistant_menu, self.manage_persistant)

        self.menu = [
            self.persistant_menu,
            None
        ]

        self.ping_url = "www.google.fr"

        self.timer = rumps.Timer(self.on_tick, 1)
        self.timer.start()


    def manage_persistant(self, sender):
        fullpath = os.getcwd() + "/../MacOS/" + 'MenuPing'

        if self.is_persistant:
            # Delete LaunchAgents file
            os.remove(target_dir + '/' + plist_filename)

            self.persistant_menu.title = unchecked_make_persistant_menu
            self.is_persistant = False
        else:
            # Prepare plist file
            with open(plist_dir + '/' + plist_model_filename, 'r') as file:
                filedata = file.read()

            filedata = filedata.replace('#ownpath#', fullpath)

            with open(plist_dir + '/' + plist_filename, 'w') as file:
                file.write(filedata)

            # Copy file to ~/Library/LaunchAgents
            shutil.copy(plist_dir + '/' + plist_filename, target_dir)

            self.persistant_menu.title = checked_make_persistant_menu
            self.is_persistant = True

    def on_tick(self, sender):
        delay = ping(self.ping_url)
        self.title = "{:.0f} ms".format(delay*1000)

if __name__ == "__main__":
    app = MenuPingApp()
    app.run()