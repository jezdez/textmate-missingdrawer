//
//  MDOutlineViewDataSource.h
//  MissingDrawer
//
//  Created by Jon Lee on 8/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

@interface MDOutlineViewDataSource : NSObject <NSOutlineViewDataSource> {
@private
  id<NSOutlineViewDataSource> _originalDataSource;
  NSString* _currentFilter;
  NSMutableDictionary* _rootDirectoryInfo;
}

- (id)initWithOriginalDataSource:(id<NSOutlineViewDataSource>)originalDataSource;

@property (nonatomic, readonly) id<NSOutlineViewDataSource> originalDataSource;
@property (nonatomic, retain) NSString* currentFilter;
@property (nonatomic, readonly) NSMutableDictionary* rootDirectoryInfo;

- (void)recalculateTreeFilter;
@end
