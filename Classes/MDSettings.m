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

NSString *const kMD_Settings_key	= @"HTMDSplitViewLayoutPanels";
NSString *const kMD_SideView_Frame	= @"SideViewFrame";
NSString *const kMD_MainView_Frame	= @"MainViewFrame";
NSString *const kMD_SideView_IsLeft	= @"SideViewIsLeft";
NSString *const kMD_SideView_IsBlue	= @"MDBlueSidebar";

@implementation MDSettings

@synthesize showSideViewOnLeft = _showSideViewOnLeft;
@synthesize sideViewLayout = _sideViewLayout;
@synthesize mainViewLayout = _mainViewLayout;
@synthesize toggleSplitViewLayoutMenuItem = _toggleSplitViewLayoutMenuItem;

- (id) init {
	if ((self = [super init])) {
		NSDictionary* layout = [[NSUserDefaults standardUserDefaults] objectForKey:kMD_Settings_key];
		if (layout && [layout isKindOfClass:[NSDictionary class]]) {
			self.sideViewLayout = NSRectFromString([layout objectForKey:kMD_SideView_Frame]);
			self.mainViewLayout = NSRectFromString([layout objectForKey:kMD_MainView_Frame]);
			self.showSideViewOnLeft = [layout objectForKey:kMD_SideView_IsLeft]?[[layout objectForKey:kMD_SideView_IsLeft] boolValue]:YES;
		} else {
			self.sideViewLayout = NSRectFromCGRect(CGRectMake(0, 0, 135, 500));
			self.mainViewLayout = NSRectFromCGRect(CGRectMake(135, 0, 300, 500));
			self.showSideViewOnLeft = YES;
			[self save];
		}
		
		NSString *menuTitle = self.showSideViewOnLeft ? @"Toggle Sideview Right" : @"Toggle Sideview Left";
		_toggleSplitViewLayoutMenuItem = [[NSMenuItem alloc] initWithTitle:menuTitle action:@selector(toggleSideViewLayout:) keyEquivalent:@""];
		[_toggleSplitViewLayoutMenuItem setTarget:self];
		[_toggleSplitViewLayoutMenuItem setEnabled:YES];
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


- (void)save {
	NSMutableDictionary* layout = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
								   NSStringFromRect(self.sideViewLayout), kMD_SideView_Frame,
								   NSStringFromRect(self.mainViewLayout), kMD_MainView_Frame,
								   [NSNumber numberWithBool:self.showSideViewOnLeft], kMD_SideView_IsLeft, 
								   nil];
	
	[[NSUserDefaults standardUserDefaults] setObject:layout forKey:kMD_Settings_key];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[layout release];
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
