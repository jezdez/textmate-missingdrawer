### 2011-05-28

* Added version to Missing Drawer and display it in preferences
* Added preferences UI for colors, the Terminal button, and the git button. Thanks [@shell](http://github.com/shell) for the initial work on this and the git button.

### 2010-11-28

* Fixed focus sideview shortcut regarding the recent tab select shortcut changes.
* Limit cell spacing of sidebar again to Xcode-like values.
* If there is no selection, then the "Terminal Button" opens the terminal with the path of the first item in the sidebar.

### 2010-10-29

* Target 10.5 SDK
* Remove NSSplitViewDelegate (10.6 only) dependency
* Updated split view initialization logic so it works with 10.5

### 2010-07-08

* Added a "Open Terminal Here" button to the drawer's button panel
* Fixed the issue of an actual missing drawer when opening a TextMate project (``*.tmproj``) by double clicking it or a directory by dragging it to the dock icon when TextMate is not running already 
* Added lefty support for toggling the file list to be displayed left or right to edit window

### 2009-01-27

* The Reveal in Project menu item is working again, thanks to fixes from the
community
* I've decided to remove the fake blue-ish background color again because it not only had poor contrast but also isn't really something like iTunes sidebar but rather a Finder link list view. I hope you enjoy.

### 2008-06-10

* The drawer is now saved with a minimal width if it's collapsed
* The Reveal in Project menu item is now disabled since I don't know how to fix it
* The weird looking background in Tiger is fixed

### 2008-02-14

* Added missing functionality and modified appearance

### 2006-11-08

* Initial release
