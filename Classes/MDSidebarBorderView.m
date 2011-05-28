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

@interface MDSidebarBorderView (PrivateMethods)
- (NSString *)_selectedFilePath;
@end


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

- (void)addToSuperview:(NSView *)superview {
    NSScrollView *outlineView = nil;
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
            _projectFileOutlineView = [[outlineView contentView] documentView];
        }
    }
	
    [btns sortUsingFunction:(NSInteger (*)(id, id, void *))compareFrameOriginX context:nil];
	
	NSRect tmButtonFrame = [[btns lastObject] frame];
	NSRect buttonFrame = NSMakeRect(tmButtonFrame.origin.x + tmButtonFrame.size.width, tmButtonFrame.origin.y,
									23.0f, tmButtonFrame.size.height);
	
	// Terminal button
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kMDTerminalButtonEnabledKey]) {
		NSButton *terminalButton = [[NSButton alloc] initWithFrame:buttonFrame];
		
		NSImage *buttonImage = [MDSidebarBorderView bundledImageWithName:@"ButtonTerminal"];
		NSImage *buttonImagePressed = [MDSidebarBorderView bundledImageWithName:@"ButtonTerminalPressed"]; 
		
		[terminalButton setToolTip:@"Open Terminal window and 'cd' to selected file/folder"];
		[terminalButton setImage:buttonImage];
		[terminalButton setAlternateImage:buttonImagePressed];
		[terminalButton setAction:@selector(terminalButtonPressed:)];
		[terminalButton setTarget:self];
		
		[terminalButton setBordered:NO];
		[btns addObject:terminalButton];
		[terminalButton release];
		
		// Move over for git button
		buttonFrame = NSMakeRect(buttonFrame.origin.x + buttonFrame.size.width, buttonFrame.origin.y,
								 buttonFrame.size.width, buttonFrame.size.height);
	}
	
	// Git button
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kMDGitButtonEnabledKey]) {
		NSButton *gitButton = [[NSButton alloc] initWithFrame:buttonFrame];

		NSImage *gitButtonImage = [MDSidebarBorderView bundledImageWithName:@"ButtonGit"];
		NSImage *gitButtonImagePressed = [MDSidebarBorderView bundledImageWithName:@"ButtonGitPressed"]; 

		[gitButton setToolTip:@"Open git window here"];
		[gitButton setImage:gitButtonImage];
		[gitButton setAlternateImage:gitButtonImagePressed];
		[gitButton setAction:@selector(gitButtonPressed:)];
		[gitButton setTarget:self];

		[gitButton setBordered:NO];
		[btns addObject:gitButton];
		[gitButton release];
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

- (void)gitButtonPressed:(id)sender {
	NSString *path = [self _selectedFilePath];
	if (!path) {
		return;
	}
	
	// Try to launch GitX
	if (![[NSWorkspace sharedWorkspace] openFile:path withApplication:@"GitX"]) {
		// Otherwise launch gitk
		// TODO: Fix
//		NSTask *task = [[NSTask alloc] init];
//		[task setLaunchPath:@"/usr/local/bin/gitk"];
//		[task setCurrentDirectoryPath:path];
//		[task launch];
//		[task waitUntilExit];
//		[task release];
	}
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

@end
