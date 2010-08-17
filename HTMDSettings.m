//
//  HTMDSettings.m
//  MissingDrawer
//
//	Copyright (c) 2006 hetima computer, 
//                2008, 2009 Jannis Leidel, 
//                2010 Christoph Meißner
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


#import "HTMDSettings.h"

@implementation HTMDSettings

@synthesize showSideViewOnLeft	= _showSideViewOnLeft;
@synthesize sideViewLayout		= _sideViewLayout;
@synthesize mainViewLayout		= _mainViewLayout;
@synthesize toggleSplitViewLayoutMenuItem = _toggleSplitViewLayoutMenuItem;

static NSString* const kMD_Settings_key		= @"HTMDSplitViewLayoutPanels";
static NSString* const kMD_SideView_Frame	= @"SideViewFrame";
static NSString* const kMD_MainView_Frame	= @"MainViewFrame";
static NSString* const kMD_SideView_IsLeft	= @"SideViewIsLeft";

- (id) init {
	if(self = [super init]) {
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
		NSMenuItem* t_toggleSplitViewLayoutMenuItem = [[NSMenuItem alloc] initWithTitle:self.showSideViewOnLeft?@"Toggle Sideview Right":@"Toggle Sideview Left" 
																	   action:@selector(toggleSideViewLayout:) 
																keyEquivalent:@""];
		[t_toggleSplitViewLayoutMenuItem setTarget:self];
		[t_toggleSplitViewLayoutMenuItem setEnabled:YES];
		_toggleSplitViewLayoutMenuItem = [t_toggleSplitViewLayoutMenuItem retain];
		[t_toggleSplitViewLayoutMenuItem release];
	}
	return self;
}

- (IBAction) toggleSideViewLayout:(id)sender {
	debug();
	self.showSideViewOnLeft = !self.showSideViewOnLeft;
	[self save];
	if([sender isKindOfClass:[NSMenuItem class]]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MDSideviewLayoutHasBeenChangedNotification" object:nil];
		[(NSMenuItem*)sender setTitle:self.showSideViewOnLeft?@"Toggle Sideview Right":@"Toggle Sideview Left"];
	}
}

- (void) save {
	NSMutableDictionary* layout = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
								   NSStringFromRect(self.sideViewLayout), kMD_SideView_Frame,
								   NSStringFromRect(self.mainViewLayout), kMD_MainView_Frame,
								   [NSNumber numberWithBool:self.showSideViewOnLeft], kMD_SideView_IsLeft, 
								   nil];
	
	[[NSUserDefaults standardUserDefaults] setObject:layout forKey:kMD_Settings_key];
	[layout release];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark Singleton

static HTMDSettings* _defaultSettings = nil;

+ (HTMDSettings *)defaultSettings {
	@synchronized(self) {
		if (_defaultSettings == nil) {
			[[[self alloc] init] release]; // release to trick Xcode's "Build and Analyze". release actually does nothing.
		}
	}
	return _defaultSettings;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (_defaultSettings == nil) {
			_defaultSettings = [super allocWithZone:zone];
			return _defaultSettings;
		}
	}
	// on subsequent allocation attempts return nil
	return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
	//do nothing
}

- (id)autorelease {
	return self;
}

@end
