//
//  MDMissingDrawer.m
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

#import "MDMissingDrawer.h"
#import "MDSplitView.h"
#import "MDSidebarBorderView.h"
#import "MDSettings.h"
#import "NSWindowController+MDMethodReplacements.h"
#import "NSWindowController+MDAdditions.h"
#import <objc/objc-runtime.h>

void swapInstanceMethods(Class cls, SEL originalSel, SEL newSel) {
    Method originalMethod = class_getInstanceMethod(cls, originalSel);
    Method newMethod = class_getInstanceMethod(cls, newSel);
    method_exchangeImplementations(originalMethod, newMethod);
}


@interface MDMissingDrawer (PrivateMethods)
- (void)_injectPluginMethods;
- (void)_installMenuItems;
- (void)_injectPreferenceMethods;
@end

@implementation MDMissingDrawer

#pragma mark Class Methods

+ (MDSplitView *)makeSplitViewWithMainView:(NSView*)contentView sideView:(NSView*)sideView {
	MDLog();
    MDSplitView *splitView = [[MDSplitView alloc] initWithFrame:[contentView frame] mainView:contentView sideView:sideView];
    [splitView setVertical:YES];
    return [splitView autorelease];
}


#pragma mark Plugin Hook

- (id)initWithPlugInController:(id<TMPlugInController>)aController {
	if (self = [super init]) {
		MDLog("initializing 'MissingDrawer' plugin");
        [self _injectPluginMethods];
		[[[NSApp mainWindow] windowController] MD_splitWindowIfNeeded];
		[self _installMenuItems];
		[self _injectPreferenceMethods];
    }	
    return self;
}


#pragma mark Actions

- (void)toggleSplitViewLayout:(id)sender {
	MDLog("Toggle Left/Right");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MDToggleSplitViewLayout" object:nil];
}


#pragma mark Private Methods

- (void)_installMenuItems {
	NSMenu* viewMenu = [[[NSApp mainMenu] itemWithTitle:@"View"] submenu];
	
	NSMenuItem* showHideDrawerMenuItem = nil;
	NSInteger drawerMenuItemIndex = 0;
	
	MDSettings* settings = [MDSettings defaultSettings];
	
	for (NSMenuItem* menuItem in [viewMenu itemArray]) {
		if ([[menuItem title] isEqualToString:@"Show/Hide Project Drawer"]) {
			showHideDrawerMenuItem = menuItem;
			drawerMenuItemIndex = [[viewMenu itemArray] indexOfObject:menuItem];
		}
	}
	
	NSMenuItem* drawerSubmenuItem =  [[NSMenuItem alloc] initWithTitle:@"Project Drawer" action:nil keyEquivalent:@""];
	NSMenu* drawerMenu = [[NSMenu alloc] initWithTitle:@"Project Drawer"];
	[drawerSubmenuItem setSubmenu:drawerMenu];
	[drawerMenu addItem:settings.toggleSplitViewLayoutMenuItem];
	[drawerMenu addItem:settings.focusSideViewMenuItem];
	[showHideDrawerMenuItem retain];
	[viewMenu removeItemAtIndex:drawerMenuItemIndex];
	[drawerMenu insertItem:showHideDrawerMenuItem atIndex:0];
	[viewMenu insertItem:drawerSubmenuItem atIndex:drawerMenuItemIndex];
	
	[drawerSubmenuItem release];
	[drawerMenu release];
	[showHideDrawerMenuItem release];
}


- (void)_injectPluginMethods {
	MDLog("swapping OakProjectController methods");
	
    Class oakProjectController = NSClassFromString(@"OakProjectController");
    swapInstanceMethods(oakProjectController, @selector(windowDidLoad),      @selector(MD_repl_windowDidLoad));
    swapInstanceMethods(oakProjectController, @selector(windowWillClose:),   @selector(MD_repl_windowWillClose:));
    swapInstanceMethods(oakProjectController, @selector(openProjectDrawer:), @selector(MD_repl_openProjectDrawer:));
    swapInstanceMethods(oakProjectController, @selector(revealInProject:),   @selector(MD_repl_revealInProject:));
}

- (void)_injectPreferenceMethods {
	MDLog("swapping OakPreferencesManager methods");
	
	Class oakPreferenceController = NSClassFromString(@"OakPreferencesManager");
	swapInstanceMethods(oakPreferenceController, @selector(toolbarAllowedItemIdentifiers:),		@selector(MD_toolbarAllowedItemIdentifiers:));
	swapInstanceMethods(oakPreferenceController, @selector(toolbarDefaultItemIdentifiers:),		@selector(MD_toolbarDefaultItemIdentifiers:));
	swapInstanceMethods(oakPreferenceController, @selector(toolbarSelectableItemIdentifiers:),  @selector(MD_toolbarSelectableItemIdentifiers:));
	swapInstanceMethods(oakPreferenceController, @selector(selectToolbarItem:),					@selector(MD_selectToolbarItem:));
	
	swapInstanceMethods(oakPreferenceController, @selector(toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:),   
												 @selector(MD_toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:));
}

@end