//
//  NSWindowController+MDMethodReplacements.m
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

#import "NSWindowController+MDMethodReplacements.h"
#import "NSWindowController+MDAdditions.h"
#import "MDMissingDrawer.h"
#import "MDSplitView.h"
#import "MDSettings.h"
#import <objc/objc-runtime.h>

@implementation NSWindowController (MDMethodReplacements)

- (void) MD_repl_windowDidLoad {
    MDLog();
    
	// call original
    [(NSWindowController *)self MD_repl_windowDidLoad];
	[(NSWindowController *)self MD_splitWindowIfNeeded];

	NSWindow *window = [(NSWindowController *)self window];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MD_windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:window];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MD_windowDidResignMain:) name:NSWindowDidResignMainNotification object:window];
}


- (void) MD_repl_windowWillClose:(NSNotification*)notification {
    MDLog();
	
    NSWindow *window = [notification object];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeMainNotification object:window];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignMainNotification object:window];
	
    id splitView = [window contentView];
    if ([splitView isKindOfClass:[MDSplitView class]]) {
        [splitView windowWillCloseWillCall];
    }
	
    // call original
    [self MD_repl_windowWillClose:notification];
}


- (void) MD_repl_openProjectDrawer:(id)sender {
	MDLog();
	
    NSWindow *window = [(NSWindowController*)self window];
    
	if ([[window contentView] isKindOfClass:[MDSplitView class]]) {
        
		MDLog(@"panel exists and menu item was clicked");
		
		MDSplitView *contentView = (MDSplitView *)[window contentView];
		
		NSView *sideView = contentView.sideView; //[[contentView subviews]objectAtIndex:0];
        NSRect sideViewFrame = [sideView frame];
		
        if (sideViewFrame.size.width == 0) {
            MDLog(@"show hidden panel");
			[contentView restoreLayout];
            [contentView adjustSubviews];
        } else {
            MDLog(@"hide visible panel");
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
	
    NSWindow *window = [(NSWindowController*)self window];
    NSView *contentView = [window contentView];
	
    if ([[contentView className] isEqualToString:@"MDSplitView"]) {
        NSView *leftView = [[contentView subviews] objectAtIndex:0];
        NSRect leftFrame = [leftView frame];
        if (leftFrame.size.width == 0) {
            [self MD_repl_openProjectDrawer:sender];
        }
    }
}

@end
