#!/usr/bin/env python3
import sys

import rumps
from ping3 import ping
import os
from os.path import expanduser
import shutil

#rumps.debug_mode(True)

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
            rumps.MenuItem("Change target", self.change_target),
            None,
            self.persistant_menu,
            None,
            rumps.MenuItem("About", self.about)
        ]

        self.target_url = "www.google.fr"

        self.timer = rumps.Timer(self.on_tick, 1)
        self.timer.start()

        self.icon = 'icon.icns'

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

    def change_target(self, sender):
        window = rumps.Window('Expected format : www.something.com', "Enter new address", cancel=True)

        response = window.run()

        if response.clicked == 1:
            new_target_url = response.text
            delay = ping(new_target_url)

            if delay is False:
                rumps.alert(title='MenuPing', message="Unable to ping the entered address. Please enter new one")

    def on_tick(self, sender):
        delay = ping(self.target_url)
        if delay is False:
            self.title = "🔴"
        else:
            self.title = "{:.0f} ms".format(delay*1000)

    def about(self, sender):
        rumps.alert(title='MenuPing',
                    message="""Version 0.0.3 - FEV 2022 by J. Bordet
                               https://github.com/julienbordet/MenuPing
                               
                               Simple Menubar app to monitor Internet connexion through ping
                               
                               Licensed under MIT.
                               rumps licensed under BSD 3-Clause.
                               Framework7 icons licensed under MIT
                               """,
                    ok=None, cancel=None)


if __name__ == "__main__":
    app = MenuPingApp()
    app.run()