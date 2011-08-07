//
//  MDSearchField.m
//  MissingDrawer
//
//  Created by Jon Lee on 8/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MDSearchField.h"
#import "MDSearchFieldCell.h"

@implementation MDSearchField
+ (Class)cellClass {
  return [MDSearchFieldCell class];
}
@end
