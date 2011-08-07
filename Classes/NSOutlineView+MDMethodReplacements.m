//
//  NSOutlineView+MDMethodReplacements.m
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
