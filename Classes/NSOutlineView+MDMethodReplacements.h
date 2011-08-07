//
//  NSOutlineView+MDMethodReplacements.h
//  MissingDrawer
//
//  Created by Jon Lee on 8/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

@interface NSOutlineView (MDOakOutlineViewMethodReplacements)

- (void)MD_repl_reloadItem:(id)item;
- (void)MD_repl_reloadItem:(id)item reloadChildren:(BOOL)reloadChildren;
@end
