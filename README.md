# Wingpanel Input Method Indicator

![Screenshot](data/screenshot.png?raw=true)

Wingpanel Input Method Indicator is an additional Indicator for [Wingpanel](https://github.com/elementary/wingpanel) that allows you to choose current input method engine, which should be useful when you'd like to type Chinese, Japanese, and Korean.

This project tries to address https://github.com/elementary/os/issues/103.

## Installation

### For Users

    sudo add-apt-repository ppa:ryonakaknock3/ele-l10n-cjk
    sudo apt install wingpanel-indicator-inputmethod

If you have never added a PPA before, you might need to run this command first: 

    sudo apt install software-properties-common

### For Developers

You'll need the following dependencies:

* gobject-introspection
* libglib2.0-dev
* libgranite-dev
* libwingpanel-2.0-dev
* libibus-1.0-dev
* meson
* valac

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`

    sudo ninja install

## Contributing

There are many ways you can contribute, even if you don't know how to code.

### Reporting Bugs or Suggesting Improvements

Simply [create a new issue](https://github.com/ele-l10n-cjk/wingpanel-indicator-inputmethod/issues/new) describing your problem and how to reproduce or your suggestion. If you are not used to do, [this section](https://elementary.io/docs/code/reference#reporting-bugs) is for you.

### Writing Some Code

We follow the [coding style of elementary OS](https://elementary.io/docs/code/reference#code-style) and [its Human Interface Guidelines](https://elementary.io/docs/human-interface-guidelines#human-interface-guidelines), please try to respect them.

### Translating This App

I accept translations through Pull Requests. If you're not sure how to do, [the guideline I made](po/README.md) might be helpful.
