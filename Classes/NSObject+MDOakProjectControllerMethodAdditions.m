//
//  NSObject+MDOakProjectControllerMethodAdditions.m
//  MissingDrawer
//
//  Created by Sam Soffes on 8/18/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

#import "NSObject+MDOakProjectControllerMethodAdditions.h"
#import "MDMissingDrawer.h"
#import "MDSplitView.h"
#import "MDSidebarBorderView.h"

@implementation NSObject (MDOakProjectControllerMethodAdditions)

- (void)MD_splitWindowIfNeeded {
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
