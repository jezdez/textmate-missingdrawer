# MissingDrawer.tmplugin

This plugin provides Xcode-like project window interface without drawer and adds "Open Terminal Here" button to the file list's button panel.

![Screenshot](http://github.com/downloads/jezdez/textmate-missingdrawer/Screen%20shot%202010-08-20.png)

## Installation

Run the following command to install into TextMate:

    $ curl -Lo MissingDrawer.zip http://github.com/downloads/jezdez/textmate-missingdrawer/MissingDrawer_2010-08-20.zip; unzip MissingDrawer.zip; open MissingDrawer.tmplugin; rm -f MissingDrawer.zip

Want a blue sidebar? Just run this:

    $ defaults write com.macromates.TextMate MDBlueSidebar 1

Change the `1` to a `0` if you change your mind. Preferences UI is planned for the future.

## Authors

The source code is released under the MIT license. Please see LICENSE for more information.

* [hetima computer](http://hetima.com/) -  hetima@hetima.com
* [Jannis Leidel](http://jannisleidel.com) - jannis@leidel.info
* Christoph Meißner - post@christophmeissner.de
* [Sam Soffes](http://samsoff.es) - sam@samsoff.es
