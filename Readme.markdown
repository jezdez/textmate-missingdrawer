# MissingDrawer.tmplugin

This plugin provides Xcode-like project window interface without drawer and adds "Open Terminal Here" button to the file list's button panel.

![Screenshot](http://github.com/downloads/jezdez/textmate-missingdrawer/Screen%20shot%202010-08-20.png)

## Installation

Run the following command to install into TextMate:

    $ curl -Lo MissingDrawer.zip http://github.com/downloads/jezdez/textmate-missingdrawer/MissingDrawer_2010-08-20.zip; unzip MissingDrawer.zip; open MissingDrawer.tmplugin; rm -f MissingDrawer.zip

Rather like a white sidebar background color? Just run this (for white):

    $ defaults write com.macromates.TextMate MDSideViewBgColor "1.0;1.0;1.0"

or simply 

    $ defaults write com.macromates.TextMate MDSideViewBgColor "white"

Change the `"white"` to `"blue"` if you changed your mind.

A preferences UI for that setting is planned, meanwhile set any RGB color you prefer like above.

## Authors

The source code is released under the MIT license. Please see LICENSE for more information.

* [hetima computer](http://hetima.com/) -  hetima@hetima.com
* [Jannis Leidel](http://jannisleidel.com) - jannis@leidel.info
* [Christoph Meißner](http://christophmeissner.wordpress.com) - post@christophmeissner.de
* [Sam Soffes](http://samsoff.es) - sam@samsoff.es
