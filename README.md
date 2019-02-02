[![Build Status](https://travis-ci.com/jeremyvaartjes/ping.svg?branch=master)](https://travis-ci.com/jeremyvaartjes/ping)

![Ping! Icon](https://raw.githubusercontent.com/jeremyvaartjes/ping/master/ping.png)
Ping!
=====

Ping lets you test your web API with some example data. A helpful tool that lets you degug what part of your API is causing you issues.

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.jeremyvaartjes.ping)﻿

![Ping! Screenshot](https://raw.githubusercontent.com/jeremyvaartjes/ping/master/data/screenshot-2.png)

Developing and Building
=======================

If you want to hack on and build Comgen yourself, you'll need the following dependencies:

* libgtk-3-dev
* meson
* valac
* libgtksourceview-3.0-dev
* libsoup2.4-dev
* libjson-glib-dev
* libgranite-dev
* libgee-0.8-dev

Run `meson build` to configure the build environment and run `ninja test` to build and run automated tests

```
meson build --prefix=/usr
cd build
ninja test
```

To install, use `ninja install`, then execute with `com.github.jeremyvaartjes.ping`

```
sudo ninja install
com.github.jeremyvaartjes.ping
```
