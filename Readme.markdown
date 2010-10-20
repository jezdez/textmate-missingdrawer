# MissingDrawer.tmplugin

This plugin provides Xcode-like project window interface without drawer and adds "Open Terminal Here" button to the file list's button panel.

![Screenshot](http://github.com/downloads/jezdez/textmate-missingdrawer/Screen%20shot%202010-08-20.png)

## Installation
To install the plugin to TextMate, download the latest version from the [Project download page](http://github.com/jezdez/textmate-missingdrawer/downloads) and double click the MissingDrawer.plugin file contained or simply run the following commands in Terminal:

    $ curl -Lo MissingDrawer.zip http://github.com/downloads/jezdez/textmate-missingdrawer/MissingDrawer_2010-08-23.zip
    $ unzip MissingDrawer.zip
    $ open MissingDrawer/MissingDrawer.tmplugin

## Changing the sidebar background color
Rather like a white sidebar background color instead of the cool new default blue? Just run this (for white):

    $ defaults write com.macromates.TextMate MDSideViewBgColor "1.0;1.0;1.0"

or simply 

    $ defaults write com.macromates.TextMate MDSideViewBgColor "white"

Change the `"white"` to `"blue"` if you changed your mind.

A preferences UI for that setting is planned, meanwhile set any RGB color you prefer like above.

By default, the "open terminal window" button launches the Terminal application. To use iTerm, run
    
    $ defaults write com.macromates.TextMate TerminalLauncherAppName "iTerm"

To reset back to Terminal, run

    $ defaults write com.macromates.TextMate TerminalLauncherAppName "Terminal"

## Authors

The source code is released under the MIT license. Please see LICENSE for more information.

* [hetima computer](http://hetima.com/) -  hetima@hetima.com
* [Jannis Leidel](http://jannisleidel.com) - jannis@leidel.info
* [Christoph Meißner](http://christophmeissner.wordpress.com) - post@christophmeissner.de
* [Sam Soffes](http://samsoff.es) - sam@samsoff.es
