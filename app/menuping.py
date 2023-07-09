#!/usr/bin/env python3

import configparser
import os
import shutil
from os import path
from os.path import expanduser

import rumps
from _version import __version__
from appdirs import user_data_dir
from ping3 import ping

# rumps.debug_mode(True)

# Global variables

make_persistant_menu = "Launch at startup"

plist_dir = "resources"
plist_model_filename = "com.zejames.MenuPing-model.plist"
plist_filename = "com.zejames.MenuPing.plist"

launch_dir = expanduser("~") + "/Library/LaunchAgents"
pref_dir = user_data_dir("MenuPing")
pref_file = "menuping.ini"


class MenuPingApp(rumps.App):
    def __init__(self) -> None:
        super(MenuPingApp, self).__init__("MenuPing", template=True)

        # Check if we are already persistant
        self.persistant_menu = rumps.MenuItem(
            make_persistant_menu, self.manage_persistant
        )
        self.is_persistant = self.check_persistence()

        # Default polling frequency is 1 sec
        self.polling_freq = 1
        # Default target is google
        self.target_url = "www.google.com"

        self.config = configparser.ConfigParser()

        # Load preferences
        self.load_preferences()

        self.menu = [
            rumps.MenuItem("Change target", self.change_target),
            rumps.MenuItem("Change polling freq", self.change_polling_freq),
            None,
            self.persistant_menu,
            None,
            rumps.MenuItem("About", self.about),
        ]

        self.timer = rumps.Timer(self.on_tick, self.polling_freq)
        self.timer.start()

        self.icon = "icon.icns"

    def check_persistence(self) -> bool:
        try:
            if path.isfile(launch_dir + "/" + plist_filename):
                self.persistant_menu.state = True
                return True
            else:
                return False
        except Exception as e:
            raise Exception("An error occured while checking persistence : " + str(e))

    def manage_persistant(self, sender) -> None:
        fullpath = os.getcwd() + "/../MacOS/" + "MenuPing"

        if self.is_persistant:
            # Delete LaunchAgents file
            os.remove(launch_dir + "/" + plist_filename)
        else:
            # Prepare plist file
            with open(plist_dir + "/" + plist_model_filename, "r") as file:
                filedata = file.read()

            filedata = filedata.replace("#ownpath#", fullpath)

            with open(plist_dir + "/" + plist_filename, "w") as file:
                file.write(filedata)

            # Copy file to ~/Library/LaunchAgents
            shutil.copy(plist_dir + "/" + plist_filename, launch_dir)

        sender.state = not sender.state
        self.is_persistant = not self.is_persistant

    def change_target(self, sender) -> None:
        window = rumps.Window(
            "Current target : " + self.target_url,
            "Enter new address",
            cancel=True,
            dimensions=(180, 20),
        )

        response = window.run()

        if response.clicked == 1:
            new_target_url = response.text
            delay = ping(new_target_url)

            if delay is False:
                rumps.alert(
                    title="MenuPing",
                    message="Unable to ping the entered address. Please enter new one",
                )
            else:
                self.update_target_url(new_target_url)

    def change_polling_freq(self, sender) -> None:
        window = rumps.Window(
            "Current polling frequency : " + str(self.polling_freq),
            "Enter new frequency",
            cancel=True,
            dimensions=(100, 20),
        )

        response = window.run()

        if response.clicked == 1:
            try:
                new_polling_freq = int(response.text)
                if new_polling_freq < 0:
                    raise ValueError
            except ValueError:
                rumps.alert(
                    title="MenuPing", message="Entered value is not an positive integer"
                )
            else:
                self.update_polling_freq(new_polling_freq)

    def on_tick(self, sender) -> None:
        delay = ping(self.target_url, timeout=self.polling_freq)
        if delay is False:  # Unreachable
            self.title = "🔴"
        elif delay is None:  # Timeout
            self.title = "🟡"
        else:
            self.title = "{:.0f} ms".format(delay * 1000)

    def about(self, sender) -> None:
        rumps.alert(
            title="MenuPing",
            message=(
                f"Version {__version__} - FEV 2023 by J. Bordet\n"
                "https://github.com/julienbordet/MenuPing\n"  # noqa: E127
                "\n"
                "Simple Menubar app to monitor Internet connexion through ping\n"
                "\n"
                "Licensed under MIT.\n"
                "rumps licensed under BSD 3-Clause.\n"
                "Framework7 icons licensed under MIT\n"
                ""
            ),
            ok=None,
            cancel=None,
        )

    def update_target_url(self, new_target_url: str) -> None:
        if "menuping" not in self.config.sections():
            self.config["menuping"] = {}

        self.config["menuping"]["target_url"] = new_target_url
        with open(pref_dir + "/" + pref_file, "w") as file:
            self.config.write(file)

        self.target_url = new_target_url

    def update_polling_freq(self, new_polling_freq: int) -> None:
        if "menuping" not in self.config.sections():
            self.config["menuping"] = {}

        self.config["menuping"]["polling_frequency"] = str(new_polling_freq)
        with open(pref_dir + "/" + pref_file, "w") as file:
            self.config.write(file)

        if new_polling_freq != self.polling_freq:
            self.polling_freq = new_polling_freq

            if self.timer:
                self.timer.stop()

            self.timer = rumps.Timer(self.on_tick, self.polling_freq)
            self.timer.start()

    def load_preferences(self) -> None:
        if not path.isdir(pref_dir):
            os.mkdir(pref_dir)

        self.config.read(pref_dir + "/" + pref_file)

        if (
            "menuping" in self.config.sections()
            and "target_url" in self.config["menuping"].keys()
        ):
            self.target_url = self.config["menuping"]["target_url"]
        else:
            self.update_target_url(self.target_url)

        if (
            "menuping" in self.config.sections()
            and "polling_frequency" in self.config["menuping"].keys()
        ):
            self.polling_freq = int(self.config["menuping"]["polling_frequency"])
        else:
            self.update_polling_freq(self.polling_freq)


if __name__ == "__main__":
    app = MenuPingApp()
    app.run()
