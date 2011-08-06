//
//  MDSettings.m
//  MissingDrawer
//
//	Copyright (c) The MissingDrawer authors.
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

@implementation MDSettings

@synthesize showSideViewOnLeft = _showSideViewOnLeft;
@synthesize sideViewLayout = _sideViewLayout;
@synthesize mainViewLayout = _mainViewLayout;
@synthesize toggleSplitViewLayoutMenuItem = _toggleSplitViewLayoutMenuItem;
@synthesize focusSideViewMenuItem = _focusSideViewMenuItem;
@synthesize bgColor = _bgColor;
@synthesize bgColorInactive = _bgColorInactive;
@synthesize namedColors = _namedColors; 

- (id)init {
	if ((self = [super init])) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		// initially register defaults from bundled defaultSettings.plist file
		NSBundle *pluginBundle = [NSBundle bundleForClass:[self class]];
		NSDictionary *bundledDefaultSettings = [[NSDictionary alloc] initWithContentsOfFile:[pluginBundle pathForResource:@"defaultSettings" ofType:@"plist"]];
		[defaults registerDefaults:bundledDefaultSettings];
		[bundledDefaultSettings release];
		[defaults synchronize];
		
		self.sideViewLayout = NSRectFromString([defaults objectForKey:kMDSideViewFrameKey]);
		self.mainViewLayout = NSRectFromString([defaults objectForKey:kMDMainViewFrameKey]);
		self.showSideViewOnLeft = [defaults boolForKey:kMDSideViewLeftKey];
		
		NSString *menuTitle = self.showSideViewOnLeft ? @"Show on the Right" : @"Show on the Left";
		_toggleSplitViewLayoutMenuItem = [[NSMenuItem alloc] initWithTitle:menuTitle action:@selector(toggleSideViewLayout:) keyEquivalent:@""];
		[_toggleSplitViewLayoutMenuItem setTarget:self];
		[_toggleSplitViewLayoutMenuItem setEnabled:YES];

		_focusSideViewMenuItem = [[NSMenuItem alloc] initWithTitle:@"Focus Sideview" action:@selector(focusSideView:) keyEquivalent:@"["];
		[_focusSideViewMenuItem setKeyEquivalentModifierMask:(NSControlKeyMask | NSAlternateKeyMask | NSCommandKeyMask)];
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
		[(NSMenuItem*)sender setTitle:self.showSideViewOnLeft ? @"Show on the Right" : @"Show on the Left"];
	}
}

- (IBAction)focusSideView:(id)sender{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MDFocusSideViewPressed" object:nil];
}

- (void)save {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:NSStringFromRect(self.sideViewLayout) forKey:kMDSideViewFrameKey];
	[defaults setObject:NSStringFromRect(self.mainViewLayout) forKey:kMDMainViewFrameKey];
	[defaults setBool:self.showSideViewOnLeft forKey:kMDSideViewLeftKey];
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


- (oneway void)release {
    // Do nothing
}


- (id)autorelease {
    return self;
}

@end
