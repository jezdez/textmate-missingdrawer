//
//  MDSettings.m
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

#import "MDSettings.h"

static MDSettings *_defaultSettings = nil;

NSString *const kMD_SideView_Frame = @"MDSideViewFrame";
NSString *const kMD_MainView_Frame = @"MDMainViewFrame";
NSString *const kMD_SideView_IsLeft = @"MDSideViewLeft";
NSString *const kMD_SideView_bgColor = @"MDSideViewBgColor";
NSString *const kMD_SideView_bgColorInactive = @"MDSideViewBgColorInactive";
NSString *const kMD_SideView_namedColors = @"MDSideViewNamedColors";
NSString *const kMD_TerminalLauncherAppName = @"TerminalLauncherAppName";

@implementation MDSettings

@synthesize showSideViewOnLeft = _showSideViewOnLeft;
@synthesize sideViewLayout = _sideViewLayout;
@synthesize mainViewLayout = _mainViewLayout;
@synthesize toggleSplitViewLayoutMenuItem = _toggleSplitViewLayoutMenuItem;
@synthesize focusSideViewMenuItem = _focusSideViewMenuItem;
@synthesize bgColor = _bgColor;
@synthesize bgColorInactive = _bgColorInactive;
@synthesize namedColors = _namedColors; 
@synthesize terminalLauncherAppName = _terminalLauncherAppName;

NSColor* NSColorFromRGBString(NSString* colorString) {
	
	// TODO: add named colors to dict in bundledDefaults
	if([colorString isEqualToString:@"white"]) {
		return [NSColor whiteColor];
	}
	
	if([colorString isEqualToString:@"blue"]) {
		return [NSColor colorWithCalibratedRed:0.871 green:0.894 blue:0.918 alpha:1.0];
	}
	
	NSArray *rgb = [colorString componentsSeparatedByString:@";"];
	
	if([rgb count]!=3) 
		return nil;
	
	return [NSColor colorWithDeviceRed:[[rgb objectAtIndex:0] floatValue]
								 green:[[rgb objectAtIndex:1] floatValue]
								  blue:[[rgb objectAtIndex:2] floatValue]
								 alpha:1];
}

NSString* NSColorToRGBString(NSColor* color) {
	return [NSString stringWithFormat:@"%f;%f;%f", [color redComponent], [color greenComponent], [color blueComponent]];
}

- (id) init {
	if ((self = [super init])) {
		
		//	self.sideViewLayout = NSRectFromCGRect(CGRectMake(0, 0, 135, 500)); -> {{0, 0}, {135, 500}}
		//	self.mainViewLayout = NSRectFromCGRect(CGRectMake(135, 0, 300, 500)); -> {{135, 0}, {300, 500}}
		//	self.showSideViewOnLeft = YES;
		//	self.bgColor = [NSColor colorWithCalibratedRed:0.871 green:0.894 blue:0.918 alpha:1.0];
		//	self.bgColorInactive = [NSColor colorWithDeviceRed:0.929 green:0.929 blue:0.929 alpha:1];
		
		NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
		
		// initially register defaults from bundled defaultSettings.plist file
		NSBundle *pluginBundle = [NSBundle bundleForClass:[self class]];
		NSDictionary *bundledDefaultSettings = [[NSDictionary alloc] initWithContentsOfFile:[pluginBundle pathForResource:@"defaultSettings" ofType:@"plist"]];
		
		[defaults registerDefaults:bundledDefaultSettings];
		
		// clean up older settings
		[defaults removeObjectForKey:@"MDSplitViewLayoutPanels"];
		[defaults removeObjectForKey:@"HTMDSplitViewLayoutPanels"];
		[defaults synchronize];
		
		self.sideViewLayout = NSRectFromString([defaults objectForKey:kMD_SideView_Frame]);
		self.mainViewLayout = NSRectFromString([defaults objectForKey:kMD_MainView_Frame]);
		self.showSideViewOnLeft = [defaults boolForKey:kMD_SideView_IsLeft];
		self.bgColor = NSColorFromRGBString([defaults objectForKey:kMD_SideView_bgColor]);
		self.bgColorInactive = NSColorFromRGBString([defaults objectForKey:kMD_SideView_bgColorInactive]);
		self.terminalLauncherAppName = [defaults objectForKey:kMD_TerminalLauncherAppName];
		
		// reset colors to bundledDefaults if something ain't right
		if (!self.bgColor || !self.bgColorInactive) {
			if (!self.bgColor) {
				self.bgColor = NSColorFromRGBString([bundledDefaultSettings objectForKey:kMD_SideView_bgColor]);
			} 
			if (!self.bgColorInactive) {
				self.bgColorInactive = NSColorFromRGBString([bundledDefaultSettings objectForKey:kMD_SideView_bgColorInactive]);
			} 			
			[self save];
		}
		[bundledDefaultSettings release];
		
		NSString *menuTitle = self.showSideViewOnLeft ? @"Toggle Sideview Right" : @"Toggle Sideview Left";
		_toggleSplitViewLayoutMenuItem = [[NSMenuItem alloc] initWithTitle:menuTitle action:@selector(toggleSideViewLayout:) keyEquivalent:@""];
		[_toggleSplitViewLayoutMenuItem setTarget:self];
		[_toggleSplitViewLayoutMenuItem setEnabled:YES];

		_focusSideViewMenuItem = [[NSMenuItem alloc] initWithTitle:@"Focus Sideview" action:@selector(focusSideView:) keyEquivalent:@"["];
		[_focusSideViewMenuItem setKeyEquivalentModifierMask:(NSShiftKeyMask | NSCommandKeyMask)];
		[_focusSideViewMenuItem setTarget:self];
		[_focusSideViewMenuItem setEnabled:YES];
	}
	return self;
}

- (IBAction)toggleSideViewLayout:(id)sender {
	MDLog();
	self.showSideViewOnLeft = !self.showSideViewOnLeft;
	[self save];
	
	if ([sender isKindOfClass:[NSMenuItem class]]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MDSideviewLayoutHasBeenChangedNotification" object:nil];
		[(NSMenuItem*)sender setTitle:self.showSideViewOnLeft ? @"Toggle Sideview Right" : @"Toggle Sideview Left"];
	}
}

- (IBAction)focusSideView:(id)sender{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MDFocusSideViewPressed" object:nil];
}

- (void)save {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:NSStringFromRect(self.sideViewLayout) forKey:kMD_SideView_Frame];
	[defaults setObject:NSStringFromRect(self.mainViewLayout) forKey:kMD_MainView_Frame];
	[defaults setBool:self.showSideViewOnLeft forKey:kMD_SideView_IsLeft];
	[defaults setObject:NSColorToRGBString(self.bgColor) forKey:kMD_SideView_bgColor];
	[defaults setObject:NSColorToRGBString(self.bgColorInactive) forKey:kMD_SideView_bgColorInactive];
	[defaults synchronize];
}

#pragma mark Singleton

+ (MDSettings *)defaultSettings {
    if (_defaultSettings == nil) {
        _defaultSettings = [[super allocWithZone:NULL] init];
    }
    return _defaultSettings;
}


+ (id)allocWithZone:(NSZone *)zone {
    return [[self defaultSettings] retain];
}


- (id)copyWithZone:(NSZone *)zone {
    return self;
}


- (id)retain {
    return self;
}


- (NSUInteger)retainCount {
    return NSUIntegerMax;
}


- (void)release {
    // Do nothing
}


- (id)autorelease {
    return self;
}

@end
