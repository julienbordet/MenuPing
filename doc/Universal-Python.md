# Installing Universal Python3

### Introduction

In order to create a py2app that work on both x86 and arm platforms, we need to first get a python3 that is universal. Two choices :

* Either recompiling it. Not easy on macOS, especially with the openssl dependancy that requires to do the same with it.
* Finding a source that is already universal.

For my packages, I used `brew`, that is a very convenient and efficient macOS package manager. However, there are no "universal" python package with this package manager.

So I had to use macports.

### Installation

macports can be downloaded from this page : [https://www.macports.org/install.php](https://www.macports.org/install.php).

Then one just need to launch the following command :

```shell
$ sudo port install python39 +universal
```

It will download and get the required **universal** dependancy package for you and install the python3 program in the default directory `/opt/local/bin`.

### Setup venv with the downloaded python

To use the new python, one just have to launch :

```shell
$ virtualenv -p /opt/local/bin/python3.9 venv
```
