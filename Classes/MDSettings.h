//
//  MDSettings.h
//  MissingDrawer
//
//	Copyright (c) 2006 hetima computer, 
//                2008, 2009 Jannis Leidel, 
//                2010 Christoph Meißner
//                2010 Sam Soffes
//
//	Permission is hereby granted, free of charge, to any person
//	obtaining a copy of this software and associated documentation
//	files (the "Software"), to deal in the Software without
//	restriction, including without limitation the rights to use,
//	copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the
//	Software is furnished to do so, subject to the following
//	conditions:
//
//	The above copyright notice and this permission notice shall be
//	included in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//	OTHER DEALINGS IN THE SOFTWARE.
//

extern NSString *const kMD_SideView_Frame;
extern NSString *const kMD_MainView_Frame;
extern NSString *const kMD_SideView_IsLeft;
extern NSString *const kMD_SideView_bgColor;
extern NSString *const kMD_SideView_bgColorInactive;
extern NSString *const kMD_SideView_namedColors;
extern NSString *const kMD_TerminalLauncherAppName;

@interface MDSettings : NSObject {
	BOOL _showSideViewOnLeft;
	NSRect _sideViewLayout;
	NSRect _mainViewLayout;
	NSMenuItem *_toggleSplitViewLayoutMenuItem;
	NSMenuItem *_focusSideViewMenuItem;
	NSColor *_bgColor;
	NSColor *_bgColorInactive;
	NSDictionary *_namedColors;
	NSString *_terminalLauncherAppName;
}

@property (nonatomic, readonly) NSMenuItem *toggleSplitViewLayoutMenuItem;
@property (nonatomic, readonly) NSMenuItem *focusSideViewMenuItem;
@property BOOL showSideViewOnLeft;
@property NSRect sideViewLayout;
@property NSRect mainViewLayout;
@property (nonatomic, retain) NSColor *bgColor;
@property (nonatomic, retain) NSColor *bgColorInactive;
@property (nonatomic, readonly) NSDictionary *namedColors;
@property (nonatomic, retain) NSString *terminalLauncherAppName;

+ (MDSettings *)defaultSettings;

- (void)save;
- (IBAction)toggleSideViewLayout:(id)sender;
- (IBAction)focusSideView:(id)sender;

@end
