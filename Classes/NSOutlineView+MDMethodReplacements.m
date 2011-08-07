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
// This method gets called whenever the root directory or its descendants have changed.
// Only root directories that have changed will be reloaded.
- (void)MD_repl_reloadItem:(id)item reloadChildren:(BOOL)reloadChildren {
  // Reload the root directory as intended originally. We will get a fresh copy
  // of the filtered list from this.
  [self MD_repl_reloadItem:item reloadChildren:reloadChildren];
  
  // if item is nil, we called this method ourselves so don't recalculate.
  if (item == nil)
    return;
  
  // FIXME: this is inefficient because it recalculates the filtered outline for all
  // root directories, not just the one that has changed. Also, if multiple root
  // directories have changed, we will recalculate the filter tree for all of the root
  // directories multiple times.
  if ([self.dataSource isMemberOfClass:[MDOutlineViewDataSource class]]) {
    MDLog(@"Recalculating filtered tree for item %@", [item objectForKey:@"sourceDirectory"]);
    MDOutlineViewDataSource* dataSource = self.dataSource;
    // We cheat a little here to get at the dispatch queue
    dispatch_queue_t filterQueue = [(MDSplitView*)[[[[self superview] superview] superview] superview] filterQueue];
    dispatch_async(filterQueue, ^() {
      [dataSource recalculateTreeFilter];
      dispatch_async(dispatch_get_main_queue(), ^() {
        if (![dataSource.currentFilter isEqualToString:[NSString string]]) {
          [self reloadItem:nil reloadChildren:YES];
          [self expandItem:nil expandChildren:YES];
        }
        // If the filter is empty we should just leave it alone.
      });
    });
  }
}
@end
