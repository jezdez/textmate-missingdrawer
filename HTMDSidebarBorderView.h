//
//  HTMDSidebarBorderView.h
//  MissingDrawer

#import <Cocoa/Cocoa.h>

@interface HTMDSidebarBorderView : NSView {
}
- (void)addToSuperview:(NSView*)superview;

+ (NSImage*)sidebarBorderImage;
+ (NSImage*)sidebarResizerImage;

@end
