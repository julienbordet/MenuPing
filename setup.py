from setuptools import setup

APP = ['menuping.py']
DATA_FILES = [ ('resources') ]
OPTIONS = {
    'argv_emulation': True,
    'iconfile': 'icon.icns',
    'plist': {
        'CFBundleShortVersionString': '0.2',
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
    setup_requires=['py2app'], install_requires=['rumps', 'ping3']
)