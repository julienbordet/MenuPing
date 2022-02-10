#!/usr/bin/env python3

import rumps
from ping3 import ping
import os
from os import path
from os.path import expanduser
import shutil
from appdirs import user_data_dir
import configparser

# rumps.debug_mode(True)

# Global variables

make_persistant_menu = "Launch at startup"

plist_dir = "resources"
plist_model_filename = "com.zejames.MenuPing-model.plist"
plist_filename = "com.zejames.MenuPing.plist"

launch_dir = expanduser("~") + '/Library/LaunchAgents'
pref_dir = user_data_dir("MenuPing")
pref_file = "menuping.ini"


class MenuPingApp(rumps.App):

    def __init__(self):
        super(MenuPingApp, self).__init__("MenuPing", template=True)

        # Check if we are already persistant
        self.persistant_menu = rumps.MenuItem(make_persistant_menu, self.manage_persistant)
        if os.path.isfile(launch_dir + '/' + plist_filename):
            self.is_persistant = True
            self.persistant_menu.state = True
        else:
            self.is_persistant = False

        # Default polling frequency is 1 sec
        self.polling_freq = 1
        # Default target is google
        self.target_url = 'www.google.com'

        # Load preferences
        self.load_preferences()

        self.menu = [
            rumps.MenuItem("Change target", self.change_target),
            rumps.MenuItem("Change polling freq", self.change_polling_freq),
            None,
            self.persistant_menu,
            None,
            rumps.MenuItem("About", self.about)
        ]

        self.timer = rumps.Timer(self.on_tick, self.polling_freq)
        self.timer.start()

        self.icon = 'icon.icns'

    def manage_persistant(self, sender):
        fullpath = os.getcwd() + "/../MacOS/" + 'MenuPing'

        if self.is_persistant:
            # Delete LaunchAgents file
            os.remove(launch_dir + '/' + plist_filename)
        else:
            # Prepare plist file
            with open(plist_dir + '/' + plist_model_filename, 'r') as file:
                filedata = file.read()

            filedata = filedata.replace('#ownpath#', fullpath)

            with open(plist_dir + '/' + plist_filename, 'w') as file:
                file.write(filedata)

            # Copy file to ~/Library/LaunchAgents
            shutil.copy(plist_dir + '/' + plist_filename, launch_dir)

        sender.state = not sender.state
        self.is_persistant = not self.is_persistant

    def change_target(self, sender):
        window = rumps.Window('Current target : ' + self.target_url, "Enter new address", cancel=True)

        response = window.run()

        if response.clicked == 1:
            new_target_url = response.text
            delay = ping(new_target_url)

            if delay is False:
                rumps.alert(title='MenuPing', message="Unable to ping the entered address. Please enter new one")
            else:
                self.update_target_url(new_target_url)

    def change_polling_freq(self, sender):
        window = rumps.Window('Current polling frequency : ' + str(self.polling_freq), "Enter new frequency", cancel=True)

        response = window.run()

        if response.clicked == 1:
            try:
                new_polling_freq = int(response.text)
            except ValueError:
                rumps.alert(title='MenuPing', message="Enter value is not an positive integer")
            else:
                self.update_polling_freq(new_polling_freq)

    def on_tick(self, sender):
        delay = ping(self.target_url)
        if delay is False:
            self.title = "🔴"
        else:
            self.title = "{:.0f} ms".format(delay*1000)

    def about(self, sender):
        rumps.alert(title='MenuPing',
                    message="""Version 0.3 - FEV 2022 by J. Bordet
                               https://github.com/julienbordet/MenuPing
                               
                               Simple Menubar app to monitor Internet connexion through ping
                               
                               Licensed under MIT.
                               rumps licensed under BSD 3-Clause.
                               Framework7 icons licensed under MIT
                               """,
                    ok=None, cancel=None)

    def update_target_url(self, new_target_url):
        if 'menuping' not in self.config.sections():
            self.config['menuping'] = {}

        self.config['menuping']['target_url'] = new_target_url
        with open(pref_dir + '/' + pref_file, 'w') as file:
            self.config.write(file)

        self.target_url = new_target_url

    def update_polling_freq(self, new_polling_freq):
        if 'menuping' not in self.config.sections():
            self.config['menuping'] = {}

        self.config['menuping']['polling_frequency'] = str(new_polling_freq)
        with open(pref_dir + '/' + pref_file, 'w') as file:
            self.config.write(file)

        if new_polling_freq != self.polling_freq:
            self.polling_freq = new_polling_freq

            if self.timer:
                self.timer.stop()

            self.timer = rumps.Timer(self.on_tick, self.polling_freq)
            self.timer.start()

    def load_preferences(self):
        if not path.isdir(pref_dir):
            os.mkdir(pref_dir)

        self.config = configparser.ConfigParser()
        self.config.read(pref_dir + '/' + pref_file)

        if 'menuping' in self.config.sections() and 'target_url' in self.config['menuping'].keys():
            self.target_url = self.config['menuping']['target_url']
        else:
            self.update_target_url(self.target_url)

        if 'menuping' in self.config.sections() and 'polling_frequency' in self.config['menuping'].keys():
            self.polling_freq = int(self.config['menuping']['polling_frequency'])
        else:
            self.update_polling_freq(self.polling_freq)

if __name__ == "__main__":
    app = MenuPingApp()
    app.run()
