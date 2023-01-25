from setuptools import setup

__version__ = '0.4.1'

if __name__ == "__main__":

    APP = ['app/menuping.py']
    DATA_FILES = [('resources')]
    OPTIONS = {
        'argv_emulation': True,
        'iconfile': 'icon.icns',
        'plist': {
            'CFBundleShortVersionString': __version__,
            'CFBundleIdentifier': 'info.bordet.menuping',
            'LSUIElement': True,
        },
        'packages': ['rumps', 'ping3', 'appdirs'],
    }

    setup(
        app=APP,
        name='MenuPing',
        data_files=DATA_FILES,
        options={'py2app': OPTIONS},
        setup_requires=['py2app'], install_requires=['rumps', 'ping3', 'appdirs']
    )
