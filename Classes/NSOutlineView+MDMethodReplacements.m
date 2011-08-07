//
//  NSOutlineView+MDMethodReplacements.m
//  MissingDrawer
//
//  Created by Jon Lee on 8/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSOutlineView+MDMethodReplacements.h"
#import "MDOutlineViewDataSource.h"
#import "MDSplitView.h"

@implementation NSOutlineView (MDOakOutlineViewMethodReplacements)
- (void)MD_repl_reloadItem:(id)item {
  MDLog();
  [self MD_repl_reloadItem:item];
}

// This method gets called whenever the root directory or its descendants have changed.
// For a given .tmproj each root directory has this called.
- (void)MD_repl_reloadItem:(id)item reloadChildren:(BOOL)reloadChildren {
  [self MD_repl_reloadItem:item reloadChildren:reloadChildren];
  
  // if item is nil, we called it ourselves so don't recalculate.
  if (item == nil)
    return;
  
  // FIXME: this is inefficient in a case of a project that
  // has multiple root level directories, since we will
  // recalculate all of the trees repeatedly for each
  // call to an individual root directory.
  MDLog(@"Recalculating filtered tree for item %@", [item objectForKey:@"sourceDirectory"]);
  if ([self.dataSource isMemberOfClass:[MDOutlineViewDataSource class]]) {
    MDOutlineViewDataSource* dataSource = self.dataSource;
    dispatch_queue_t filterQueue = [(MDSplitView*)[[[[self superview] superview] superview] superview] filterQueue];
    dispatch_async(filterQueue, ^() {
      [dataSource recalculateTreeFilter];
      dispatch_async(dispatch_get_main_queue(), ^() {
        [self reloadItem:nil reloadChildren:YES];
        if (![dataSource.currentFilter isEqualToString:[NSString string]])
          [self expandItem:nil expandChildren:YES];
        else
          [self expandItem:nil expandChildren:NO];
      });
    });
  }
}
@end
