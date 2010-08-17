//
//  HTMDMissingDrawer.m
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

#import <objc/objc-runtime.h>
#import "HTMDMissingDrawer.h"
#import "HTMDSplitView.h"
#import "HTMDSidebarBorderView.h"
#import "HTMDSettings.h"

#pragma mark -
#pragma mark Class method replacement support

void swapClassMethods(Class cls, SEL originalSel, SEL newSel) {
    Method originalMethod = class_getInstanceMethod(cls, originalSel);
    Method newMethod = class_getInstanceMethod(cls, newSel);
    method_exchangeImplementations(originalMethod, newMethod);
}

#pragma mark -
#pragma mark OakProjectController replacement methods category

@interface NSObject (MD_OakProjectController_MethodReplacements)

- (void) MD_repl_windowDidLoad;
- (void) MD_repl_windowWillClose:(NSNotification*)notification;
- (void) MD_repl_revealInProject:(id)sender;
- (void) MD_repl_openProjectDrawer:(id)sender;

@end

@implementation NSObject (MD_OakProjectController_MethodReplacements)

- (void) MD_splitWindowIfNeeded {
	NSWindow* window = [(NSWindowController*)self window];
	if (window) {
		NSView* contentView = [window contentView];
		
		if (contentView && ![contentView isKindOfClass:[HTMDSplitView class]]) {
			NSDrawer* drawer = [[window drawers] objectAtIndex:0];
			NSView* leftView = [[drawer contentView] retain];
			[drawer setContentView:nil];
			[window setContentView:nil];
			
			HTMDSidebarBorderView* borderView = [[HTMDSidebarBorderView alloc] initWithFrame:[leftView frame]];
			[borderView addToSuperview:leftView];
			
			HTMDSplitView* splitView = [HTMDMissingDrawer makeSplitViewWithMainView:contentView sideView:leftView];
			debug("replacing current window with split view");
			[window setContentView:splitView];
			
			[borderView release];
			[leftView release];
			[splitView restoreLayout];
		}
	}
}

- (void) MD_repl_windowDidLoad {
    debug();
    
	// call original
    [self MD_repl_windowDidLoad];
	[self MD_splitWindowIfNeeded];
}

- (void) MD_repl_windowWillClose:(NSNotification*)notification {
    debug();
	
    id window=[notification object];
    id splitView=[window contentView];
    if([splitView isKindOfClass:[HTMDSplitView class]]) {
        [splitView windowWillCloseWillCall];
    }

    // call original
    [self MD_repl_windowWillClose:notification];
}

- (void) MD_repl_openProjectDrawer:(id)sender {
	debug();
	
    NSWindow* window = [(NSWindowController*)self window];
    
	if ([[window contentView] isKindOfClass:[HTMDSplitView class]]) {
        
		debug("panel exists and menu item was clicked");
		
		HTMDSplitView* contentView = (HTMDSplitView*)[window contentView];
		
		NSView* sideView = contentView.sideView; //[[contentView subviews]objectAtIndex:0];
        NSRect sideViewFrame = [sideView frame];

        if (sideViewFrame.size.width == 0) {
            debug("show hidden panel");
			[contentView restoreLayout];
            [contentView adjustSubviews];
        } else {
            debug("hide visible panel");
			[contentView saveLayout];
            sideViewFrame.size.width = 0;
            [sideView setFrame:sideViewFrame];
            [contentView adjustSubviews];
        }
    } 
}

- (void) MD_repl_revealInProject:(id)sender {
	debug();
    [self MD_repl_revealInProject:sender];
    [self MD_repl_revealInProject:sender]; //TODO: twice?

    NSWindow* window= [(NSWindowController*)self window];
    NSView* contentView = [window contentView];

    if ([[contentView className] isEqualToString:@"HTMDSplitView"]) {
        NSView* leftView = [[contentView subviews] objectAtIndex:0];
        NSRect leftFrame = [leftView frame];
        if (leftFrame.size.width == 0) {
            [self MD_repl_openProjectDrawer:sender];
        }
    }
}

@end

@interface HTMDMissingDrawer (private)

- (void) injectPluginMethods;
- (void) installMenuItems;

@end

@implementation HTMDMissingDrawer

- (id) initWithPlugInController:(id<TMPlugInController>)aController {
	if (self = [super init]) {
		debug("initializing 'MissingDrawer' plugin");
        [self injectPluginMethods];
		[[[NSApp mainWindow] windowController] MD_splitWindowIfNeeded];
		[self installMenuItems];
    }
    return self;
}

- (void) toggleSplitViewLayout:(id)sender {
	debug("Toggle Left/Right");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MDToggleSplitViewLayout" object:nil];
}

- (void) installMenuItems {
	NSMenu* viewMenu = [[[NSApp mainMenu] itemWithTitle:@"View"] submenu];
	
	NSMenuItem* showHideDrawerMenuItem = nil;
	NSInteger drawerMenuItemIndex = 0;
	
	HTMDSettings* settings = [HTMDSettings defaultSettings];
	
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
	debug("swapping OakProjectController methods");
	
    Class oakProjectController = NSClassFromString(@"OakProjectController");
	// is subclass of NSWindowController
	
    swapClassMethods(oakProjectController, @selector(windowDidLoad),		@selector(MD_repl_windowDidLoad));
    swapClassMethods(oakProjectController, @selector(windowWillClose:),		@selector(MD_repl_windowWillClose:));
    swapClassMethods(oakProjectController, @selector(openProjectDrawer:),	@selector(MD_repl_openProjectDrawer:));
    swapClassMethods(oakProjectController, @selector(revealInProject:),		@selector(MD_repl_revealInProject:));
}

+ (HTMDSplitView*) makeSplitViewWithMainView:(NSView*)contentView sideView:(NSView*)sideView {
	debug();
    HTMDSplitView* splitView= [[HTMDSplitView alloc] initWithFrame:[contentView frame] andMainView:contentView andSideView:sideView];
    [splitView setVertical:YES];
    return [splitView autorelease];
}

@end