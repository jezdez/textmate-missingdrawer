//
//  MDSplitView.m
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

#import "MDSplitView.h"

#import "MDOutlineViewDataSource.h"
#import "MDResizer.h"
#import "MDSettings.h"
#import "MDSidebarBorderView.h"

#define MIN_SIDEVIEW_WIDTH 170.0
#define MAX_SIDEVIEW_WIDTH 450.0

@implementation MDSplitView

@synthesize sideView = _sideView;
@synthesize mainView = _mainView;
@synthesize borderView = _borderView;
@synthesize filterQueue = _filterQueue;

#pragma mark NSObject

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
  
  self.borderView = nil;
  
  dispatch_release(_filterQueue);
  [_fullOutlineViewExpandedItems release];
  
  [_outlineViewDataSource release];
  [_outlineView release];
  
	[_sideView release];
	[_mainView release];
	[super dealloc];
}


#pragma mark NSSplitView

- (void)drawDividerInRect:(NSRect)aRect {
  [[NSColor colorWithDeviceWhite:0.625 alpha:1] setFill];
  [NSBezierPath fillRect:aRect];
}


#pragma mark Initializer

- (id)initWithFrame:(NSRect)frame mainView:(NSView *)aMainView sideView:(NSView *)aSideView {
  if ((self = [super initWithFrame:frame])) {
		[self setDelegate:self];
		
		_mainView = [aMainView retain];
		_sideView = [aSideView retain];
    _outlineView = [[[[_sideView subviews] objectAtIndex:0] documentView] retain];
    _fullOutlineViewExpandedItems = [[NSMutableArray alloc] init];
    
    // swap the original data source with ours
    _outlineViewDataSource = [[MDOutlineViewDataSource alloc] initWithOriginalDataSource:_outlineView.dataSource];
    _outlineView.dataSource = _outlineViewDataSource;
    
    [self.sideView setAutoresizingMask:NSViewHeightSizable];
    [self setVertical:YES];
    
    if([MDSettings defaultSettings].showSideViewOnLeft) {
      [self addSubview:self.sideView];
      [self addSubview:self.mainView];
    } else {
      [self addSubview:self.mainView];
      [self addSubview:self.sideView];
    }
    
    _filterQueue = dispatch_queue_create("com.macromates.textmate.missingdrawer", NULL);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleLayout) name:@"MDSideviewLayoutHasBeenChangedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(focusSideView) name:@"MDFocusSideViewPressed" object:nil];
  }
  return self;
}

#pragma mark -

- (void)focusSideView {
  if([_sideView acceptsFirstResponder]){
    [_sideView becomeFirstResponder];
  } else {
    for(NSView *view in [_sideView subviews]){
      if([view acceptsFirstResponder]){
        [view becomeFirstResponder];
        break;
      }
    }
  }
}

#pragma mark Drawing

- (void)toggleLayout {
  MDLog(@"toggling views");
  NSView *leftView = [[[self subviews] objectAtIndex:0] retain];
  [leftView removeFromSuperview];
  [self addSubview:leftView];
  [leftView release];
  [self adjustSubviews];
  [_borderView setNeedsLayout];
  [_borderView setNeedsDisplay:YES];
}

#pragma mark Layout

- (void)windowWillCloseWillCall {
  MDLog(@"windowWillCloseWillCall");
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  if ([self.sideView frame].size.width <= 0) {
    MDLog(@"save only when frame not collapsed");
    NSRect sideViewFrame = [self.sideView frame];
    sideViewFrame.size.width = MIN_SIDEVIEW_WIDTH;
    [self.sideView setFrame:sideViewFrame];
    [self adjustSubviews];
  }
  [self saveLayout];
  
  if (self.sideView){
    NSDrawer *drawer = [[[self window] drawers] objectAtIndex:0];
    [self.sideView removeFromSuperview];
    [drawer setContentView:self.sideView];
    [_sideView release], _sideView = nil;
  }
}


- (void)applyLayout:(NSRect)layout toView:(NSView *)view {
  NSRect newFrame = layout;
  if(NSIsEmptyRect(newFrame)) {
    newFrame = [view frame];
    if([self isVertical]) {
      newFrame.size.width = 0;
    } else {
      newFrame.size.height = 0;
    }
  }
  [view setFrame:newFrame];
}


- (void)saveLayout {
  MDSettings *settings = [MDSettings defaultSettings];
  settings.sideViewLayout = [self.sideView frame];
  settings.mainViewLayout = [self.mainView frame];
  [settings save];
}


- (void)restoreLayout {
  MDSettings *settings = [MDSettings defaultSettings];
  [self applyLayout:settings.sideViewLayout toView:self.sideView];
  [self applyLayout:settings.mainViewLayout toView:self.mainView];
}


#pragma mark NSSplitView Delegate

- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview {
  return NO;
}


- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset {
  if ([[self subviews] objectAtIndex:offset] == self.sideView) {
    return MIN_SIDEVIEW_WIDTH;
  } else {
    return [self frame].size.width - MAX_SIDEVIEW_WIDTH;
  }
  
}


- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset {
  if ([[self subviews] objectAtIndex:offset] == self.sideView) {
    return MAX_SIDEVIEW_WIDTH;
  } else {
    return [self frame].size.width - MIN_SIDEVIEW_WIDTH;
  }
}


- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize {
  MDLog();
  
  [self setDividerStyle:NSSplitViewDividerStyleThin];
  
  CGFloat dividerThickness = [self dividerThickness];
  
  NSRect windowFrame = [[NSApp mainWindow] frame];
  windowFrame.size.width = MAX(3 * MIN_SIDEVIEW_WIDTH + dividerThickness, windowFrame.size.width);
  [[NSApp mainWindow] setFrame:windowFrame display:YES];
  
  NSRect splitViewFrame = [self frame];
  splitViewFrame.size.width = MAX(3 * MIN_SIDEVIEW_WIDTH + dividerThickness, splitViewFrame.size.width);
  [splitView setFrame:splitViewFrame];
  
  NSRect sideViewFrame = [self.sideView frame];
  NSRect mainViewFrame = [self.mainView frame];
  
  sideViewFrame.size.height = splitViewFrame.size.height;
  mainViewFrame.size.height = splitViewFrame.size.height;
  
  mainViewFrame.size.width = splitViewFrame.size.width - sideViewFrame.size.width - dividerThickness;
  
  if ([MDSettings defaultSettings].showSideViewOnLeft) {
    mainViewFrame.origin.x = sideViewFrame.size.width + dividerThickness;
    sideViewFrame.origin.x = 0;
  } else {
    mainViewFrame.origin.x = 0;
    sideViewFrame.origin.x = mainViewFrame.size.width + dividerThickness;
  }
  
  [self.sideView setFrame:sideViewFrame];
  [self.mainView setFrame:mainViewFrame];
}


- (void)resetCursorRects {
  MDLog();
  [super resetCursorRects];
  
  NSRect location = [resizeSlider frame];
  location.origin.y = [self frame].size.height - location.size.height;
  
  [self addCursorRect:location cursor:[NSCursor resizeLeftRightCursor]];
}

- (void)mouseDown:(NSEvent *)theEvent {
  MDLog();
  NSPoint clickLocation = [theEvent locationInWindow];
  NSView *clickReceiver = [self hitTest:clickLocation];
  if ([clickReceiver isKindOfClass:[MDResizer class]]) {
    _inResizeMode = YES;
  } else {
    _inResizeMode = NO;
    [super mouseDown:theEvent];
  }
}

- (void)mouseUp:(NSEvent *)theEvent {
  MDLog();
  _inResizeMode = NO;
}

- (void)mouseDragged:(NSEvent *)theEvent {
  MDLog();
  
  if (_inResizeMode == NO) {
    [super mouseDragged:theEvent];
    return;
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:NSSplitViewWillResizeSubviewsNotification object:self];
  
  NSPoint clickLocation = [theEvent locationInWindow];
  NSView *leftView = [[self subviews] objectAtIndex:0];
  NSRect newFrame = [leftView frame];
  newFrame.size.width = clickLocation.x;
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(splitView:constrainSplitPosition:ofSubviewAt:)]) {
    float new = [self.delegate splitView:self constrainSplitPosition:newFrame.size.width ofSubviewAt:0];
    newFrame.size.width = new;
  }
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(splitView:constrainMinCoordinate:ofSubviewAt:)]) {
    float min = [self.delegate splitView:self constrainMinCoordinate:0. ofSubviewAt:0];
    newFrame.size.width = MAX(min, newFrame.size.width);
  }
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(splitView:constrainMaxCoordinate:ofSubviewAt:)]) {
    float max = [self.delegate splitView:self constrainMaxCoordinate:0. ofSubviewAt:0];
    newFrame.size.width = MIN(max, newFrame.size.width);
  }
  
  [leftView setFrame:newFrame];
  
  [self setNeedsDisplay:YES];
  [self adjustSubviews];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:NSSplitViewDidResizeSubviewsNotification object:self];
}

#pragma mark Outline view filtering
- (void)filterOutlineView:(NSNotification *)notification {
  NSSearchField* searchField = [notification object];
  
  NSString* desiredFilter = [searchField stringValue];
  // We are about to switch from an unfiltered to filtered tree.
  // Go through the rows of the outline view and keep track of
  // the items that have been expanded.
  if (_outlineViewDataSource.currentFilter == nil || [_outlineViewDataSource.currentFilter isEqualToString:[NSString string]]) {
    [_fullOutlineViewExpandedItems removeAllObjects];
    int numRows = [_outlineView numberOfRows];
    for (int i = 0; i < numRows; ++i) {
      id item = [_outlineView itemAtRow:i];
      if ([_outlineView isItemExpanded:item]) {
        [_fullOutlineViewExpandedItems addObject:item];
      }
    }
  }
  
  dispatch_async(_filterQueue, ^() {
    // If the project has a particularly extensive directory structure,
    // the user might have typed a few characters while the queue
    // was processing one of the events. We do a sanity check against
    // the string currently entered in the search field. If it's not
    // the same, we can throw away this one, since we can assume that
    // eventually we will get a queue task that does have the right
    // desired filter string. This essentially coalesces the filter
    // events.
    if (![[searchField stringValue] isEqualToString:desiredFilter])
      return;
    
    _outlineViewDataSource.currentFilter = desiredFilter;
    [_outlineViewDataSource recalculateTreeFilter];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
      [_outlineView reloadItem:nil reloadChildren:YES];
      if (![desiredFilter isEqualToString:[NSString string]])
        [_outlineView expandItem:nil expandChildren:YES];
      else {
        // We switched from a filtered to an unfiltered tree. We
        // restore the expanded state of the items.
        for (id item in _fullOutlineViewExpandedItems) {
          [_outlineView expandItem:item];
        }
      }
    });
  });
}

@end
