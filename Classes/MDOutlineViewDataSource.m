//
//  MDOutlineViewDataSource.m
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

#import "MDOutlineViewDataSource.h"

@implementation MDOutlineViewDataSource
@synthesize currentFilter = _currentFilter;
@synthesize originalDataSource = _originalDataSource;
@synthesize rootDirectoryInfo = _rootDirectoryInfo;

- (id)initWithOriginalDataSource:(id<NSOutlineViewDataSource>)originalDataSource {
  self = [super init];
  if (!self)
    return self;
  
  _originalDataSource = originalDataSource;
  _currentFilter = nil;
  _rootDirectoryInfo = [[NSMutableDictionary alloc] init];
  return self;
}

- (void)dealloc {
  [_rootDirectoryInfo release];
  [_currentFilter release];
  [super dealloc];
}


- (void)setCurrentFilter:(NSString *)currentFilter {
  if ([_currentFilter isEqualToString:currentFilter])
    return;
  
  [self willChangeValueForKey:@"currentFilter"];
  [_currentFilter release];
  _currentFilter = [currentFilter retain];
  [self didChangeValueForKey:@"currentFilter"];
  [self recalculateTreeFilter];
}

- (BOOL)_recurse:(NSMutableDictionary*)node {
//  MDLog(@"looking at %@", [node objectForKey:@"displayName"]);
  BOOL isItselfOrHasChildrenThatPassesFilter = NO;
  NSArray* children = [node objectForKey:@"children"];
  if (children) {
//    MDLog(@"has children");
    NSMutableArray* newChildren = [children mutableCopy];
    [node setObject:newChildren forKey:@"children"];
    [newChildren release];
    
    int index = 0;
    while (index < [newChildren count]) {
      NSDictionary* item = [newChildren objectAtIndex:index];
      if ([item objectForKey:@"children"]) {
        /// this has children
        NSMutableDictionary* newItem = [item mutableCopy];
        if (![self _recurse:newItem]) {
          [newChildren removeObjectAtIndex:index];
          [newItem release];
          continue;
        }
        
        [newChildren replaceObjectAtIndex:index withObject:newItem];
        [newItem release];
        isItselfOrHasChildrenThatPassesFilter |= YES;
      }
      else {
        if ([(NSString*)[item objectForKey:@"displayName"] rangeOfString:_currentFilter options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)].location == NSNotFound ) {
          [newChildren removeObjectAtIndex:index];
          continue;
        }
        
        isItselfOrHasChildrenThatPassesFilter |= YES;
      }
      index++;
    }
  }
  
  isItselfOrHasChildrenThatPassesFilter |= [(NSString*)[node objectForKey:@"displayName"] rangeOfString:_currentFilter options:(NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch)].location != NSNotFound;
  return isItselfOrHasChildrenThatPassesFilter;
}

- (void)recalculateTreeFilter {
  if (_currentFilter == nil || [_currentFilter isEqualToString:[NSString string]]) {
    [_rootDirectoryInfo removeAllObjects];
    return;
  }
  
  int numberOfRootElements = [_originalDataSource outlineView:nil numberOfChildrenOfItem:nil];
  for (int i = 0; i < numberOfRootElements; ++i) {
    NSDictionary* root = [_originalDataSource outlineView:nil child:i ofItem:nil];
    NSMutableDictionary* newRoot = [root mutableCopy];
    [self _recurse:newRoot];
    [_rootDirectoryInfo setObject:newRoot forKey:[root objectForKey:@"sourceDirectory"]];
    [newRoot release];
  }
}

#pragma mark NSOutlineViewDataSource protocol
- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
  return [_originalDataSource outlineView:outlineView acceptDrop:info item:item childIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
  id child = [_originalDataSource outlineView:outlineView child:index ofItem:item];
//  MDLog(@"child: %d item: %@ is: %@", index, [item objectForKey:@"displayName"], [child objectForKey:@"displayName"]);
  if (_currentFilter == nil || [_currentFilter isEqualToString:[NSString string]])
    return child;
  if (item == nil) {
    return [_rootDirectoryInfo objectForKey:[child objectForKey:@"sourceDirectory"]];
  }
  return child;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
//  MDLog(@"%s item: %@", __FUNCTION__, [item objectForKey:@"displayName"]);
  return [_originalDataSource outlineView:outlineView isItemExpandable:item];
}

- (id)outlineView:(NSOutlineView *)outlineView itemForPersistentObject:(id)object {
  MDLog();
  return [_originalDataSource outlineView:outlineView itemForPersistentObject:object];
}

- (NSArray *)outlineView:(NSOutlineView *)outlineView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination forDraggedItems:(NSArray *)items {
  return [_originalDataSource outlineView:outlineView namesOfPromisedFilesDroppedAtDestination:dropDestination forDraggedItems:items];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
  NSInteger count = [_originalDataSource outlineView:outlineView numberOfChildrenOfItem:item];
//  MDLog(@"item: %@ num children: %d", [item objectForKey:@"displayName"], count);
  return count;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
  return [_originalDataSource outlineView:outlineView objectValueForTableColumn:tableColumn byItem:item];
}


- (id)outlineView:(NSOutlineView *)outlineView persistentObjectForItem:(id)item {
  MDLog();
  return [_originalDataSource outlineView:outlineView persistentObjectForItem:item];
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
  return [_originalDataSource outlineView:outlineView setObjectValue:object forTableColumn:tableColumn byItem:item];
}

- (void)outlineView:(NSOutlineView *)outlineView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
  return [_originalDataSource outlineView:outlineView sortDescriptorsDidChange:oldDescriptors];
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
  return [_originalDataSource outlineView:outlineView validateDrop:info proposedItem:item proposedChildIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard {
  return [_originalDataSource outlineView:outlineView writeItems:items toPasteboard:pasteboard];
}

@end
