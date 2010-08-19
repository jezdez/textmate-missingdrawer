//
//  MDMissingDrawer.m
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

#import <objc/objc-runtime.h>
#import "MDMissingDrawer.h"
#import "MDSplitView.h"
#import "MDSidebarBorderView.h"
#import "MDSettings.h"

#pragma mark Instance method replacement support

void swapInstanceMethods(Class cls, SEL originalSel, SEL newSel) {
    Method originalMethod = class_getInstanceMethod(cls, originalSel);
    Method newMethod = class_getInstanceMethod(cls, newSel);
    method_exchangeImplementations(originalMethod, newMethod);
}

#pragma mark OakProjectController replacement methods category

@interface NSObject (MD_OakProjectController_MethodReplacements)

- (void) MD_repl_windowDidLoad;
- (void) MD_repl_windowWillClose:(NSNotification*)notification;
- (void) MD_repl_revealInProject:(id)sender;
- (void) MD_repl_openProjectDrawer:(id)sender;

- (NSOutlineView *) MD_outlineView;
- (void) MD_windowDidBecomeMain:(NSNotification *)notification;
- (void) MD_windowDidResignMain:(NSNotification *)notification;

@end

@implementation NSObject (MD_OakProjectController_MethodReplacements)

- (void) MD_splitWindowIfNeeded {
	NSWindow* window = [(NSWindowController*)self window];
	if (window) {
		NSView* contentView = [window contentView];
		
		if (contentView && ![contentView isKindOfClass:[MDSplitView class]]) {
			NSDrawer* drawer = [[window drawers] objectAtIndex:0];
			NSView* leftView = [[drawer contentView] retain];
			[drawer setContentView:nil];
			[window setContentView:nil];
			
			MDSidebarBorderView* borderView = [[MDSidebarBorderView alloc] initWithFrame:[leftView frame]];
			[borderView addToSuperview:leftView];
			
			MDSplitView* splitView = [MDMissingDrawer makeSplitViewWithMainView:contentView sideView:leftView];
			MDLog("replacing current window with split view");
			[window setContentView:splitView];
			
			[borderView release];
			[leftView release];
			[splitView restoreLayout];
		}
	}
}

- (void) MD_repl_windowDidLoad {
    MDLog();
    
	// call original
    [self MD_repl_windowDidLoad];
	[self MD_splitWindowIfNeeded];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kMD_SideView_IsBlue]) {
		NSWindow *window = [(NSWindowController *)self window];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MD_windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:window];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MD_windowDidResignMain:) name:NSWindowDidResignMainNotification object:window];
	}
}

- (void) MD_repl_windowWillClose:(NSNotification*)notification {
    MDLog();
	
    NSWindow *window = [notification object];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kMD_SideView_IsBlue]) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeMainNotification object:window];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignMainNotification object:window];
	}
	
    id splitView = [window contentView];
    if ([splitView isKindOfClass:[MDSplitView class]]) {
        [splitView windowWillCloseWillCall];
    }

    // call original
    [self MD_repl_windowWillClose:notification];
}

- (void) MD_repl_openProjectDrawer:(id)sender {
	MDLog();
	
    NSWindow* window = [(NSWindowController*)self window];
    
	if ([[window contentView] isKindOfClass:[MDSplitView class]]) {
        
		MDLog("panel exists and menu item was clicked");
		
		MDSplitView* contentView = (MDSplitView*)[window contentView];
		
		NSView* sideView = contentView.sideView; //[[contentView subviews]objectAtIndex:0];
        NSRect sideViewFrame = [sideView frame];

        if (sideViewFrame.size.width == 0) {
            MDLog("show hidden panel");
			[contentView restoreLayout];
            [contentView adjustSubviews];
        } else {
            MDLog("hide visible panel");
			[contentView saveLayout];
            sideViewFrame.size.width = 0;
            [sideView setFrame:sideViewFrame];
            [contentView adjustSubviews];
        }
    } 
}

- (void) MD_repl_revealInProject:(id)sender {
	MDLog();
    [self MD_repl_revealInProject:sender];
    [self MD_repl_revealInProject:sender]; //TODO: twice?

    NSWindow* window= [(NSWindowController*)self window];
    NSView* contentView = [window contentView];

    if ([[contentView className] isEqualToString:@"MDSplitView"]) {
        NSView* leftView = [[contentView subviews] objectAtIndex:0];
        NSRect leftFrame = [leftView frame];
        if (leftFrame.size.width == 0) {
            [self MD_repl_openProjectDrawer:sender];
        }
    }
}

- (NSOutlineView *)MD_outlineView {
	MDSplitView* contentView = (MDSplitView *)[[(NSWindowController *)self window] contentView];
	NSScrollView *scrollView = [[contentView.sideView subviews] objectAtIndex:0];
	NSClipView *clipView = [[scrollView subviews] objectAtIndex:0];
	return [[clipView subviews] lastObject];
}

- (void) MD_windowDidBecomeMain:(NSNotification *)notification {
	[[self MD_outlineView] setBackgroundColor:[NSColor colorWithCalibratedRed:0.871 green:0.894 blue:0.918 alpha:1.0]];	
}

- (void) MD_windowDidResignMain:(NSNotification *)notification {
	[[self MD_outlineView] setBackgroundColor:[NSColor colorWithCalibratedWhite:0.929 alpha:1.0]];		
}

@end

@interface MDMissingDrawer (private)

- (void) injectPluginMethods;
- (void) installMenuItems;

@end

@implementation MDMissingDrawer

- (id) initWithPlugInController:(id<TMPlugInController>)aController {
	if (self = [super init]) {
		MDLog("initializing 'MissingDrawer' plugin");
        [self injectPluginMethods];
		[[[NSApp mainWindow] windowController] MD_splitWindowIfNeeded];
		[self installMenuItems];
    }
    return self;
}

- (void) toggleSplitViewLayout:(id)sender {
	MDLog("Toggle Left/Right");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MDToggleSplitViewLayout" object:nil];
}

- (void) installMenuItems {
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
	[showHideDrawerMenuItem retain];
	[viewMenu removeItemAtIndex:drawerMenuItemIndex];
	[drawerMenu insertItem:showHideDrawerMenuItem atIndex:0];
	[viewMenu insertItem:drawerSubmenuItem atIndex:drawerMenuItemIndex];
	
	[drawerSubmenuItem release];
	[drawerMenu release];
	[showHideDrawerMenuItem release];
}

- (void) injectPluginMethods {
	MDLog("swapping OakProjectController methods");
	
    Class oakProjectController = NSClassFromString(@"OakProjectController");
    swapInstanceMethods(oakProjectController, @selector(windowDidLoad),      @selector(MD_repl_windowDidLoad));
    swapInstanceMethods(oakProjectController, @selector(windowWillClose:),   @selector(MD_repl_windowWillClose:));
    swapInstanceMethods(oakProjectController, @selector(openProjectDrawer:), @selector(MD_repl_openProjectDrawer:));
    swapInstanceMethods(oakProjectController, @selector(revealInProject:),   @selector(MD_repl_revealInProject:));
}

+ (MDSplitView*) makeSplitViewWithMainView:(NSView*)contentView sideView:(NSView*)sideView {
	MDLog();
    MDSplitView* splitView= [[MDSplitView alloc] initWithFrame:[contentView frame] mainView:contentView sideView:sideView];
    [splitView setVertical:YES];
    return [splitView autorelease];
}

@end