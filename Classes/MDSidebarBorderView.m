//
//  MDSidebarBorderView.m
//  MissingDrawer
//
//	Copyright (c) 2006 hetima computer, 
//                2008, 2009 Jannis Leidel, 
//                2010 Christoph Meißner
//                2010 Sam Soffes
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
#import "MDResizer.h"
#import "Foundation/NSGeometry.h"
#import "MDSettings.h"

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

@implementation MDSidebarBorderView

#pragma mark Class Methods

+ (NSImage *)bundledImageWithName:(NSString *)imageName {
	NSBundle *pluginBundle = [NSBundle bundleForClass:[self class]];
	return [[[NSImage alloc] initWithContentsOfFile:[pluginBundle pathForResource:imageName ofType:@"png"]] autorelease];
}


#pragma mark NSView

- (BOOL)mouseDownCanMoveWindow {
    return YES;
}


- (void)drawRect:(NSRect)rect {
    NSRect fromRect = NSZeroRect;
    NSImage *image = [MDSidebarBorderView bundledImageWithName:@"DrawerBorder"];
    fromRect.size = [image size];
	
    [image drawInRect:[self frame] fromRect:fromRect operation:NSCompositeSourceOver fraction:1.0];
}


#pragma mark Drawing

- (void)addToSuperview:(NSView*)superview {
    NSScrollView* outlineView = nil;
    int i, cnt;
	BOOL showSidebarOnLeft = [[MDSettings defaultSettings] showSideViewOnLeft];
	
    // Adjust frame
    NSImage *image = [MDSidebarBorderView bundledImageWithName:@"DrawerBorder"];
    NSRect borderRect = NSZeroRect;
	borderRect.origin.x = showSidebarOnLeft ? -1.0 : 1.0;
    borderRect.size.height = [image size].height;
    borderRect.size.width = [superview frame].size.width + 2;
	
    // Add resizer image
    NSRect handleRect = NSZeroRect;
    NSImage *sidebarResizerImage = [MDSidebarBorderView bundledImageWithName:@"DrawerResizeHandle"];
    handleRect.size = [sidebarResizerImage size];
    handleRect.origin.y = 0;
	if (showSidebarOnLeft) {
		handleRect.origin.x = [self frame].size.width - handleRect.size.width;
	} else {
		handleRect.origin.x = 0;
	}
    NSImageView *imageView = [[MDResizer alloc] initWithFrame:handleRect];
    [imageView setImage: sidebarResizerImage];
    [imageView setAutoresizingMask:showSidebarOnLeft?NSViewMinXMargin:NSViewMaxXMargin];
    [self addSubview:imageView];
    [self setNeedsDisplay:YES];
	
    [self setAutoresizingMask:(NSViewWidthSizable+NSViewMaxYMargin)];
	
    // Add self to superview
    [superview addSubview:self];
    [self setFrame:borderRect];
	
    // Gather buttons
    NSMutableArray *btns = [[NSMutableArray alloc] init];
    NSArray *subviews = [superview subviews];
    cnt = [subviews count];
    for (i = 0; i < cnt; i++) {
        id aView = [subviews objectAtIndex:i];
        if ([aView isKindOfClass:[NSButton class]] && [aView frame].origin.y < 1) {
            [btns addObject:aView];
        } else if ([aView isKindOfClass:[NSScrollView class]]) {
            outlineView = (NSScrollView *)aView;
            projectFileOutlineView = [[outlineView contentView] documentView];
        }
    }
	
    [btns sortUsingFunction:(NSInteger (*)(id, id, void *))compareFrameOriginX context:nil];
    NSButton *lastButton = [btns lastObject];
	
    NSRect terminalButtonFrame;
    terminalButtonFrame.size.width = 23;
    terminalButtonFrame.size.height = [lastButton frame].size.height;
    terminalButtonFrame.origin.x = [lastButton frame].origin.x + terminalButtonFrame.size.width;
    terminalButtonFrame.origin.y = [lastButton frame].origin.y;
	
    NSButton *terminalButton = [[NSButton alloc] initWithFrame:terminalButtonFrame];
	
    NSImage *buttonImage = [MDSidebarBorderView bundledImageWithName:@"OpenTerminalHere"];
    NSImage *buttonImagePressed = [MDSidebarBorderView bundledImageWithName:@"OpenTerminalHerePressed"]; 
	
	[terminalButton setToolTip:@"Open Terminal window and 'cd' to selected file/folder"];
    [terminalButton setImage:buttonImage];
    [terminalButton setAlternateImage:buttonImagePressed];
    [terminalButton setAction:@selector(terminalButtonPressed:)];
    [terminalButton setTarget:self];
	
    [terminalButton setBordered:NO];
    [btns addObject:terminalButton];
	[terminalButton release];
	
//  [btns sortUsingFunction:(NSInteger (*)(id, id, void *))compareFrameOriginX context:nil];
	
	// Adjust outlineView frame
    if (outlineView){
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
        [layoutManager release];
        [realOutlineView setIntercellSpacing:NSMakeSize (6.0, 4.0)];
        [realOutlineView reloadData];
    }
	
	//place buttons into sideboardview (self)

//  alternative A: "Add file" button gets partially covered by window resizer handle when displaying buttons 
//	on the right outside when in lefty mode
	
//	if(showSidebarOnLeft) {
//		float leftLoc = 0;
//		
//		for (NSView* button in btns) {
//			
//			NSRect buttonFrame = [button frame];
//			buttonFrame.origin.y = -4;
//			buttonFrame.origin.x = leftLoc;
//			leftLoc = leftLoc + (buttonFrame.size.width-1);
//			
//			[button setAutoresizingMask:NSViewMaxXMargin];
//			[button removeFromSuperview];
//			[button setFrame:buttonFrame];
//			[self addSubview:button];
//			
//		}	
//	} else {
//		float pos = 0;
//		
//		for (NSView* button in btns) {
//			NSRect buttonFrame = [button frame];
//			buttonFrame.origin.y = -4;
//			pos = pos + (buttonFrame.size.width-1);
//			buttonFrame.origin.x = [self frame].size.width-pos;
//			
//			[button removeFromSuperview];
//			[button setFrame:buttonFrame];
//			[button setAutoresizingMask:NSViewMinXMargin];
//			[self addSubview:button];
//		}
//	}
	
	float leftLoc = 0;
	if (!showSidebarOnLeft) {
		leftLoc = leftLoc + handleRect.size.width; // = 18 
	}
	
	for (NSView *button in btns) {
		NSRect buttonFrame = [button frame];
		buttonFrame.origin.y = -4;
		buttonFrame.origin.x = leftLoc;
		leftLoc = leftLoc + (buttonFrame.size.width-1);
		
		[button setAutoresizingMask:NSViewMaxXMargin];
		[button removeFromSuperview];
		[button setFrame:buttonFrame];
		[self addSubview:button];
	}
	
    [btns release];
    [imageView release];
}


#pragma mark Actions

- (void)terminalButtonPressed:(id)sender {
    NSArray *selectedItems = nil;
    if (projectFileOutlineView && 
		[projectFileOutlineView respondsToSelector:@selector(selectedItems)]) {
        selectedItems = [projectFileOutlineView performSelector:@selector(selectedItems)];
        if (!selectedItems || ![selectedItems isKindOfClass:[NSArray class]] || [selectedItems count] == 0) {
            return;
        }
    }
	
    for (NSDictionary *item in selectedItems) {
        MDLog("[projectFileOutlineView selectedItems]: %@", item);
        NSString *path = [item objectForKey:@"sourceDirectory"];
        if (!path) {
            path = [[item objectForKey:@"filename"] stringByDeletingLastPathComponent];
        }
		
        if (path) {
            path = [path stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\\\\\""];
			NSString *appName = [[MDSettings defaultSettings] terminalLauncherAppName];
			NSString *appleScriptCommand;
			
			if ([appName caseInsensitiveCompare:@"iTerm"] == NSOrderedSame) {
				appleScriptCommand = [NSString stringWithFormat:@"tell application \"iTerm\"\n\tactivate\n\ttell the first terminal\n\t\tlaunch session \"Default session\"\n\t\ttell the last session\n\t\t\twrite text \"cd \\\"%@\\\"\"\n\t\tend tell\n\tend tell\nend tell", path];
			} else if ([appName caseInsensitiveCompare:@"Terminal"] == NSOrderedSame) {
				appleScriptCommand = [NSString stringWithFormat:@"tell application \"Terminal\"\n\tdo script \"cd \\\"%@\\\"\"\n\tactivate\nend tell", path];
			} else {
				return;
			}
			
            MDLog("script:\n%@", appleScriptCommand);
            NSAppleScript *as = [[NSAppleScript alloc] initWithSource: appleScriptCommand];
            [as executeAndReturnError:nil];
			[as release];
            return;
        }
    }
}

@end
