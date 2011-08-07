//
//  MDSearchFieldCell.m
//  MissingDrawer
//
//  Created by Jon Lee on 8/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MDSearchFieldCell.h"

@implementation MDSearchFieldCell
- (NSRect)searchButtonRectForBounds:(NSRect)rect {
  NSRect newRect = [super searchButtonRectForBounds:rect];
  newRect.origin.x -= 2;
  return newRect;
}
@end
