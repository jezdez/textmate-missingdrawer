//
//  HTMDResizer.m
//  MissingDrawer

#import "HTMDResizer.h"

@implementation HTMDResizer

- (void)mouseDown:(NSEvent *)theEvent
{
    //NSLog(@"mouseDown in sliderImage");
    [[[self superview] superview] mouseDown:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    //NSLog(@"mouseDragged in sliderImage");
    [[[self superview] superview] mouseDragged:theEvent];
}

@end