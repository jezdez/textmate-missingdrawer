//
//  NSObject+MDOakProjectControllerMethodReplacements.m
//  MissingDrawer
//
//  Created by Sam Soffes on 8/18/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import "NSObject+MDOakProjectControllerMethodReplacements.h"
#import "NSObject+MDOakProjectControllerMethodAdditions.h"
#import "MDMissingDrawer.h"
#import "MDSplitView.h"
#import "MDSettings.h"
#import <objc/objc-runtime.h>

@implementation NSObject (MDOakProjectControllerMethodReplacements)

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

@end
