// This reuses a lot of code from Ciarán Walsh's ProjectPlus ( http://ciaranwal.sh/2008/08/05/textmate-plug-in-projectplus )
// Source: git://github.com/ciaran/projectplus.git

#import "NSWindowController+Preferences.h"
#import "MDMissingDrawer.h"
#import "MDPreferenceController.h"

float ToolbarHeightForWindow(NSWindow *window)
{
	NSToolbar *toolbar;
	float toolbarHeight = 0.0;
	NSRect windowFrame;
	
	toolbar = [window toolbar];
	
	if(toolbar && [toolbar isVisible])
	{
		windowFrame   = [NSWindow contentRectForFrameRect:[window frame] styleMask:[window styleMask]];
		toolbarHeight = NSHeight(windowFrame) - NSHeight([[window contentView] frame]);
	}
	
	return toolbarHeight;
}

static NSString* MD_PREFERENCES_LABEL = @"Missing Drawer";

@implementation NSWindowController (MD_Preferences)

- (NSArray*)MD_toolbarAllowedItemIdentifiers:(id)sender
{
	return [[self MD_toolbarAllowedItemIdentifiers:sender] arrayByAddingObject:MD_PREFERENCES_LABEL];
}
- (NSArray*)MD_toolbarDefaultItemIdentifiers:(id)sender
{
	return [[self MD_toolbarDefaultItemIdentifiers:sender] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:MD_PREFERENCES_LABEL,nil]];
}
- (NSArray*)MD_toolbarSelectableItemIdentifiers:(id)sender
{
	return [[self MD_toolbarSelectableItemIdentifiers:sender] arrayByAddingObject:MD_PREFERENCES_LABEL];
}

- (NSToolbarItem*)MD_toolbar:(NSToolbar*)toolbar 
	   itemForItemIdentifier:(NSString*)itemIdentifier 
   willBeInsertedIntoToolbar:(BOOL)flag 
{
	NSToolbarItem *item = [self MD_toolbar:toolbar itemForItemIdentifier:itemIdentifier willBeInsertedIntoToolbar:flag];
	//  if([itemIdentifier isEqualToString:MD_PREFERENCES_LABEL])
	//	   At some point add a picture here
	return item;
}

- (void)MD_selectToolbarItem:(id)item
{
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