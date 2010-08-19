//
//  NSObject+MDOakProjectControllerMethodAdditions.h
//  MissingDrawer
//
//  Created by Sam Soffes on 8/18/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

@interface NSObject (MDOakProjectControllerMethodAdditions)

- (void)MD_splitWindowIfNeeded;
- (NSOutlineView *)MD_outlineView;
- (void)MD_windowDidBecomeMain:(NSNotification *)notification;
- (void)MD_windowDidResignMain:(NSNotification *)notification;

@end
