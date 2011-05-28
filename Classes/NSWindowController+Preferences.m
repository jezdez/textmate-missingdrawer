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
//  This reuses a lot of code from Ciarán Walsh's ProjectPlus ( http://ciaranwal.sh/2008/08/05/textmate-plug-in-projectplus )
//  Source: git://github.com/ciaran/projectplus.git
//

#import "NSWindowController+Preferences.h"
#import "MDMissingDrawer.h"
#import "MDPreferenceController.h"

float ToolbarHeightForWindow(NSWindow *window) {
	NSToolbar *toolbar;
	float toolbarHeight = 0.0;
	NSRect windowFrame;
	
	toolbar = [window toolbar];
	
	if (toolbar && [toolbar isVisible]) {
		windowFrame   = [NSWindow contentRectForFrameRect:[window frame] styleMask:[window styleMask]];
		toolbarHeight = NSHeight(windowFrame) - NSHeight([[window contentView] frame]);
	}
	
	return toolbarHeight;
}

static NSString* MD_PREFERENCES_LABEL = @"Missing Drawer";

@implementation NSWindowController (MD_Preferences)

- (NSArray *)MD_toolbarAllowedItemIdentifiers:(id)sender {
	return [[self MD_toolbarAllowedItemIdentifiers:sender] arrayByAddingObject:MD_PREFERENCES_LABEL];
}

- (NSArray *)MD_toolbarDefaultItemIdentifiers:(id)sender {
	return [[self MD_toolbarDefaultItemIdentifiers:sender] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:MD_PREFERENCES_LABEL,nil]];
}

- (NSArray *)MD_toolbarSelectableItemIdentifiers:(id)sender {
	return [[self MD_toolbarSelectableItemIdentifiers:sender] arrayByAddingObject:MD_PREFERENCES_LABEL];
}

- (NSToolbarItem *)MD_toolbar:(NSToolbar*)toolbar 
	   itemForItemIdentifier:(NSString*)itemIdentifier 
   willBeInsertedIntoToolbar:(BOOL)flag  {
	NSToolbarItem *item = [self MD_toolbar:toolbar itemForItemIdentifier:itemIdentifier willBeInsertedIntoToolbar:flag];
	//  if([itemIdentifier isEqualToString:MD_PREFERENCES_LABEL])
	//	   At some point add a picture here
	return item;
}

- (void)MD_selectToolbarItem:(id)item {
	if ([[item label] isEqualToString:MD_PREFERENCES_LABEL]) {
		if ([[self valueForKey:@"selectedToolbarItem"] isEqualToString:[item label]]) return;
		[[self window] setTitle:[item label]];
		[self setValue:[item label] forKey:@"selectedToolbarItem"];
		
		NSSize prefsSize = [[[MDPreferenceController instance] preferencesView] frame].size;
		NSRect frame = [[self window] frame];
		prefsSize.width = [[self window] contentMinSize].width;
		
		[[self window] setContentView:[[MDPreferenceController instance] preferencesView]];
		
		float newHeight = prefsSize.height + ToolbarHeightForWindow([self window]) + 22;
		frame.origin.y += frame.size.height - newHeight;
		frame.size.height = newHeight;
		frame.size.width = prefsSize.width;
		[[self window] setFrame:frame display:YES animate:YES];
	} else {
		[self MD_selectToolbarItem:item];
	}
}

@end
