//
//  MDSidebarBorderView.m
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

#import "MDSidebarBorderView.h"

#import "MDMissingDrawer.h"
#import "MDResizer.h"
#import "MDSearchField.h"
#import "MDSettings.h"

#define SEARCH_FIELD_LEFT_PADDING 5
#define SEARCH_FIELD_RIGHT_PADDING 9

NSComparisonResult compareFrameOriginX(id viewA, id viewB, void *context) {
  float v1 = [viewA frame].origin.x;
  float v2 = [viewB frame].origin.x;
  
	if (v1 < v2) {
    return NSOrderedAscending;
	} else if (v1 > v2) {
    return NSOrderedDescending;
	}
	
	return NSOrderedSame;
}

@interface MDSidebarBorderView (PrivateMethods)
- (NSString *)_selectedFilePath;
- (void)_focusSearchField;
- (NSRect)_searchFieldRectForFrame:(NSRect)frame;
@end


@implementation MDSidebarBorderView
@synthesize searchField = _searchField;

- (id)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (!self)
    return self;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_focusSearchField) name:@"MDFilterInDrawerNotification" object:nil];
  return self;
}

- (void)dealloc {
  [_searchField release];
  [_buttons release];
  [_resizer release];
  [super dealloc];
}

#pragma mark NSView

- (BOOL)mouseDownCanMoveWindow {
  return YES;
}


- (void)drawRect:(NSRect)rect {
  NSRect fromRect = NSZeroRect;
  NSImage *image = [MDMissingDrawer bundledImageWithName:@"DrawerBorder"];
  fromRect.size = [image size];
	
  [image drawInRect:[self frame] fromRect:fromRect operation:NSCompositeSourceOver fraction:1.0];
}


#pragma mark Drawing

- (void)addToSuperview:(NSView *)superview {
  NSScrollView *outlineView = nil;
  int i, cnt;
	
	BOOL showSidebarOnLeft = [[MDSettings defaultSettings] showSideViewOnLeft];

  // Adjust frame
  NSImage *image = [MDMissingDrawer bundledImageWithName:@"DrawerBorder"];
  NSRect borderRect = NSZeroRect;
	borderRect.origin.x = showSidebarOnLeft ? -1.0 : 1.0;
  borderRect.size.height = [image size].height;
  borderRect.size.width = [superview frame].size.width + 2;
	
  // Add resizer image
  NSRect handleRect = NSZeroRect;
  NSImage *sidebarResizerImage = [MDMissingDrawer bundledImageWithName:@"DrawerResizeHandle"];
  handleRect.size = [sidebarResizerImage size];
  
  _resizer = [[MDResizer alloc] initWithFrame:handleRect];
  [_resizer setImage: sidebarResizerImage];
  [self addSubview:_resizer];
	
  [self setAutoresizingMask:(NSViewWidthSizable | NSViewMaxYMargin)];
	
  // Add self to superview
  [superview addSubview:self];
  [self setFrame:borderRect];
	
  // Gather buttons
  NSMutableArray *btns = [[NSMutableArray alloc] init];
  _buttons = btns;
  
  NSArray *subviews = [superview subviews];
  cnt = [subviews count];
  for (i = 0; i < cnt; i++) {
    id aView = [subviews objectAtIndex:i];
    if ([aView isKindOfClass:[NSButton class]] && [aView frame].origin.y < 1) {
      [btns addObject:aView];
    } else if ([aView isKindOfClass:[NSScrollView class]]) {
      outlineView = (NSScrollView *)aView;
      _projectFileOutlineView = [[outlineView contentView] documentView];
    }
  }
	
  [btns sortUsingFunction:(NSInteger (*)(id, id, void *))compareFrameOriginX context:nil];
	
	// Terminal button
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kMDTerminalButtonEnabledKey]) {
		NSRect tmButtonFrame = [[btns lastObject] frame];
		NSRect buttonFrame = NSMakeRect(tmButtonFrame.origin.x + tmButtonFrame.size.width, tmButtonFrame.origin.y,
                                    23.0f, tmButtonFrame.size.height);
    
		NSButton *terminalButton = [[NSButton alloc] initWithFrame:buttonFrame];
		
		NSImage *buttonImage = [MDMissingDrawer bundledImageWithName:@"ButtonTerminal"];
		NSImage *buttonImagePressed = [MDMissingDrawer bundledImageWithName:@"ButtonTerminalPressed"]; 
		
		[terminalButton setToolTip:@"Open Terminal window and 'cd' to selected file/folder"];
		[terminalButton setImage:buttonImage];
		[terminalButton setAlternateImage:buttonImagePressed];
		[terminalButton setAction:@selector(terminalButtonPressed:)];
		[terminalButton setTarget:self];
		
		[terminalButton setBordered:NO];
		[btns addObject:terminalButton];
		[terminalButton release];
	}
	
	// Adjust outlineView frame
  if (outlineView) {
    NSRect aRect = [superview frame];
    aRect.origin.x = -1.0;
    aRect.origin.y = [self frame].size.height;
    aRect.size.height = aRect.size.height-aRect.origin.y+1;
    aRect.size.width = aRect.size.width+2;
    [outlineView setFrame:aRect];
		
    NSOutlineView *realOutlineView = [outlineView documentView];
    NSFont *font = [NSFont fontWithName:@"Lucida Grande" size:12];
    NSLayoutManager *layoutManager = [NSLayoutManager new]; 
    [realOutlineView setRowHeight:[layoutManager defaultLineHeightForFont:font]];
		[realOutlineView setIntercellSpacing:NSMakeSize (4.0, 2.0)];
    [layoutManager release];
    [realOutlineView reloadData];
  }
	
  for (NSView *button in btns) {
		[button setAutoresizingMask:NSViewMaxXMargin];
		[button removeFromSuperview];
		[self addSubview:button];
  }
  
  _searchField = [[MDSearchField alloc] initWithFrame:NSMakeRect(0, 1, 10, handleRect.size.height - 4)];
  NSSearchFieldCell* cell = [_searchField cell];
  [cell setMaximumRecents:0];
  [cell setFont:[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
  [cell setControlSize:NSMiniControlSize];
  [cell setFocusRingType:NSFocusRingTypeNone];
  [cell setScrollable:YES];
  [[cell searchButtonCell] setImage:[MDMissingDrawer bundledImageWithName:@"FilterIcon"]];
  
  [_searchField setAutoresizingMask:NSViewWidthSizable];
  [_searchField sizeToFit];
  [self addSubview:_searchField];

  _needsLayout = YES;
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
  [super resizeSubviewsWithOldSize:oldSize];
  _searchField.frame = [self _searchFieldRectForFrame:_searchField.frame];
}

- (NSRect)_searchFieldRectForFrame:(NSRect)frame {
	BOOL showSidebarOnLeft = [[MDSettings defaultSettings] showSideViewOnLeft];
  NSRect rect = frame;
  rect.size.width = [self frame].size.width - rect.origin.x - (showSidebarOnLeft ? _resizer.frame.size.width : SEARCH_FIELD_RIGHT_PADDING);
  return rect;
}

- (void)setNeedsLayout {
  _needsLayout = YES;
}

// For 10.6 support, we will use this, but for 10.7 we can use [NSView layout]
- (void)viewWillDraw {
  if (!_needsLayout)
    return;

	BOOL showSidebarOnLeft = [[MDSettings defaultSettings] showSideViewOnLeft];

  float leftLoc = 0;
  NSRect frame;

  frame = _resizer.frame;
  if (showSidebarOnLeft) {
		frame.origin.x = [self frame].size.width - frame.size.width;
    [_resizer setAutoresizingMask:NSViewMinXMargin];
	} else {
		frame.origin.x = 0;
    leftLoc += frame.size.width;
    [_resizer setAutoresizingMask:NSViewMaxXMargin];
	}
  _resizer.frame = frame;
	
	for (NSView *button in _buttons) {
		NSRect buttonFrame = [button frame];
		buttonFrame.origin.y = 0;
		buttonFrame.origin.x = leftLoc;
		leftLoc = leftLoc + (buttonFrame.size.width-1);
    button.frame = buttonFrame;
	}
  
  frame = _searchField.frame;
  frame.origin.x = leftLoc + SEARCH_FIELD_LEFT_PADDING;
  _searchField.frame = [self _searchFieldRectForFrame:frame];

  _needsLayout = NO;
}

#pragma mark Actions

- (void)terminalButtonPressed:(id)sender {
	NSString *path = [self _selectedFilePath];
	if (!path) {
		return;
	}
	
	path = [path stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\\\\\""];
	NSString *appName = [[NSUserDefaults standardUserDefaults] stringForKey:kMDTerminalApplicationKey];
  //	BOOL openTerminalInTab = [[MDSettings defaultSettings] openTerminalInTab]; 
	NSString *appleScriptCommand = nil;
	
	if ([appName isEqualToString:@"iTerm"]) {
		appleScriptCommand = [NSString stringWithFormat:@"tell application \"iTerm\"\n\tactivate\n\ttell the first terminal\n\t\tlaunch session \"Default session\"\n\t\ttell the last session\n\t\t\twrite text \"cd \\\"%@\\\"\"\n\t\tend tell\n\tend tell\nend tell", path];
	} else {
		appleScriptCommand = [NSString stringWithFormat:@"activate application \"Terminal\"\n\ttell application \"System Events\"\n\tkeystroke \"t\" using {command down}\n\tend tell\n\ttell application \"Terminal\"\n\trepeat with win in windows\n\ttry\n\tif get frontmost of win is true then\n\tdo script \"cd \\\"%@\\\"; clear\" in (selected tab of win)\n\tend if\n\tend try\n\tend repeat\n\tend tell", path];
	}
	
	MDLog(@"script:\n%@", appleScriptCommand);
	NSAppleScript *as = [[NSAppleScript alloc] initWithSource: appleScriptCommand];
	[as executeAndReturnError:nil];
	[as release];
	return;
}


#pragma mark Private Methods

- (NSString *)_selectedFilePath {
	NSArray *selectedItems = nil;
	if (_projectFileOutlineView && 
      [_projectFileOutlineView respondsToSelector:@selector(selectedItems)]) {
		selectedItems = [_projectFileOutlineView performSelector:@selector(selectedItems)];
		if (!selectedItems || ![selectedItems isKindOfClass:[NSArray class]] || [selectedItems count] == 0) {
			selectedItems = [NSArray arrayWithObject:[(NSOutlineView *)_projectFileOutlineView itemAtRow:0]];
		}
	}
	
	for (NSDictionary *item in selectedItems) {
		NSString *path = [item objectForKey:@"sourceDirectory"];
		if (!path) {
			path = [[item objectForKey:@"filename"] stringByDeletingLastPathComponent];
		}
		
		if (path) {
			return path;
		}
	}
	
	return nil;
}

- (void)_focusSearchField {
  if ([_searchField acceptsFirstResponder])
    [_searchField becomeFirstResponder];
}
@end
