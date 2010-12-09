// This reuses a lot of code from Julian Eberius's Textmate-Minimap ( http://github.com/JulianEberius/Textmate-Minimap )

#import <Cocoa/Cocoa.h>

@interface NSWindowController (MD_Preferences)

- (NSArray*)MD_toolbarAllowedItemIdentifiers:(id)sender;

- (NSArray*)MD_toolbarDefaultItemIdentifiers:(id)sender;

- (NSArray*)MD_toolbarSelectableItemIdentifiers:(id)sender;

- (NSToolbarItem*)MD_toolbar:(NSToolbar*)toolbar 
			itemForItemIdentifier:(NSString*)itemIdentifier 
		willBeInsertedIntoToolbar:(BOOL)flag;

- (void)MD_selectToolbarItem:(id)item;

@end