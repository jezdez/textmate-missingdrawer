//
//  NSWindowController+MDAdditions.m
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

#import "NSWindowController+MDAdditions.h"
#import "MDMissingDrawer.h"
#import "MDSplitView.h"
#import "MDSidebarBorderView.h"

@implementation NSWindowController (MDAdditions)

- (void)MD_splitWindowIfNeeded {
	NSWindow *window = [(NSWindowController *)self window];
	if (window) {
		NSView *contentView = [window contentView];
		
		if (contentView && ![contentView isKindOfClass:[MDSplitView class]]) {
			// If a drawer is displayed by TextMate, replace the contentView
			// with one that uses the MissingDrawer.
			NSDrawer *drawer = [[window drawers] objectAtIndex:0];
			if (drawer)	{
				NSView *leftView = [[drawer contentView] retain];
				[drawer setContentView:nil];
				[window setContentView:nil];
			
				MDSidebarBorderView *borderView = [[MDSidebarBorderView alloc] initWithFrame:[leftView frame]];
				[borderView addToSuperview:leftView];
			
				MDSplitView *splitView = [MDMissingDrawer makeSplitViewWithMainView:contentView sideView:leftView];
				MDLog(@"replacing current window with split view");
				[window setContentView:splitView];
			
				[borderView release];
				[leftView release];
				[splitView restoreLayout];
			}
		}
	}
}


- (NSOutlineView *)MD_outlineView {
	MDSplitView *contentView = (MDSplitView *)[[(NSWindowController *)self window] contentView];
	NSScrollView *scrollView = [[contentView.sideView subviews] objectAtIndex:0];
	NSClipView *clipView = [[scrollView subviews] objectAtIndex:0];
	return [[clipView subviews] lastObject];
}


- (void) MD_windowDidBecomeMain:(NSNotification *)notification {
	
	NSMutableDictionary *bindingOptions = [NSMutableDictionary dictionary];
	[bindingOptions setObject:NSUnarchiveFromDataTransformerName
					   forKey:@"NSValueTransformerName"];
	
	[[self MD_outlineView] bind:@"backgroundColor"
					   toObject:[NSUserDefaultsController sharedUserDefaultsController]
					withKeyPath:@"values.MDSideViewBgColorNew"
						options:bindingOptions];
}


- (void) MD_windowDidResignMain:(NSNotification *)notification {
	NSMutableDictionary *bindingOptions = [NSMutableDictionary dictionary];
	[bindingOptions setObject:NSUnarchiveFromDataTransformerName
					   forKey:@"NSValueTransformerName"];
	
	[[self MD_outlineView] bind:@"backgroundColor"
					   toObject:[NSUserDefaultsController sharedUserDefaultsController]
					withKeyPath:@"values.MDSideViewBgColorIdle"
						options:bindingOptions];
}

@end
