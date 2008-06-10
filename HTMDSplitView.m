//
//  HTMDSplitView.m
//  MissingDrawer


#import "HTMDSplitView.h"

@implementation HTMDSplitView

#pragma mark -
#pragma mark Original Methods

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self setVertical:YES];
        [self setDelegate:self];
    }
    return self;
}

- (IBAction)adjustSubviews:(id)sender
{
    [self adjustSubviews];
}

//setup
- (void)addSubview:(NSView *)aView
{
    [super addSubview:aView];
    if([[self subviews]count]==1){
        [aView setAutoresizingMask:NSViewHeightSizable];
        _sideView=aView;
    }else{
        _mainView=aView;
    }
}

//cleanup
- (void)windowWillCloseWillCall
{
    //NSLog(@"windowWillCloseWillCall");
    NSWindow* window=[self window];
    NSDrawer* drawer=[[window drawers]objectAtIndex:0];
    NSView* sideView=[_sideView retain];
    
    NSView* contentView=[[window contentView]retain];
    NSView* leftView=[[contentView subviews]objectAtIndex:0];
    NSRect leftFrame=[leftView frame];

    if (leftFrame.size.width==0) {
        NSLog(@"save only when frame not collapsed");
        leftFrame.size.width = 122;
        [leftView setFrame:leftFrame];
        [contentView adjustSubviews];
    }
    [contentView storeLayoutWithName:@"Panels"];
    
    if(sideView){
        _sideView=nil;
        [sideView removeFromSuperview];
        [drawer setContentView:sideView];
        [sideView release];
    }
}

#pragma mark -
#pragma mark Overridden from NSSplitView

- (float)dividerThickness
{
    return 1;
}

- (void)drawDividerInRect:(NSRect)aRect
{
    [[NSColor colorWithDeviceWhite:.625 alpha:1] setFill];
    [NSBezierPath fillRect:aRect];
}

#pragma mark -
#pragma mark NSSplitView delegate methods

- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview
{
    return NO;
}

- (float)splitView:(NSSplitView *)sender constrainMinCoordinate:(float)proposedMin ofSubviewAt:(int)offset
{
    return 110.0; //Min width
}

- (float)splitView:(NSSplitView *)sender constrainMaxCoordinate:(float)proposedMax ofSubviewAt:(int)offset
{
    return 350.0; //Max width
}

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
    NSRect newFrame = [sender frame];
    NSView *left = [[sender subviews] objectAtIndex:0];
    NSRect leftFrame = [left frame];
    NSView *right = [[sender subviews] objectAtIndex:1];
    NSRect rightFrame = [right frame];
    float dividerThickness = [sender dividerThickness];

    leftFrame.size.height = newFrame.size.height;
    leftFrame.origin.x = 0;
    leftFrame.origin.y = 0;

    rightFrame.size.width = newFrame.size.width - leftFrame.size.width - dividerThickness;
    rightFrame.size.height = newFrame.size.height;
    rightFrame.origin.x = leftFrame.size.width + dividerThickness;
    
    [left setFrame:leftFrame];
    [right setFrame:rightFrame];
}

#pragma mark -
#pragma mark Sidebar resize area

- (void)resetCursorRects
{
    [super resetCursorRects];
        
    NSRect location = [resizeSlider frame];
    location.origin.y = [self frame].size.height - location.size.height;

    [self addCursorRect:location cursor:[NSCursor resizeLeftRightCursor]];
}

- (void)mouseDown:(NSEvent *)theEvent 
{
    //NSLog(@"mouseDown in splitView");
    NSPoint clickLocation = [theEvent locationInWindow];

    NSView *clickReceiver = [self hitTest:clickLocation];
    if ([[clickReceiver className] isEqualToString:@"HTMDResizer"]) {
        //NSLog(@"Entering drag");
        inResizeMode = YES;
    } else {
        //NSLog([clickReceiver className]);
        inResizeMode = NO;
        [super mouseDown:theEvent];
    }
    //NSLog(@"mouseDown in splitView done");
}

- (void)mouseUp:(NSEvent *)theEvent
{
    //NSLog(@"Exiting drag");
    inResizeMode = NO;
}

- (void)mouseDragged:(NSEvent *)theEvent 
{
    //NSLog(@"mouseDragged in splitView");
    if (inResizeMode == NO) {
        [super mouseDragged:theEvent];
        return;
    }
        
    [[NSNotificationCenter defaultCenter] postNotificationName:NSSplitViewWillResizeSubviewsNotification object:self];

    NSPoint clickLocation = [theEvent locationInWindow];
    NSRect newFrame = [_sideView frame];
    newFrame.size.width = clickLocation.x;
    //NSLog(@"new width: %f", newFrame.size.width);
    
    id delegate = [self delegate];
    if(delegate && [delegate respondsToSelector:@selector(splitView:constrainSplitPosition:ofSubviewAt:)]) {
        float new = [delegate splitView:self constrainSplitPosition:newFrame.size.width ofSubviewAt:0];
        newFrame.size.width = new;
        //NSLog(@"Constrained width to: %f", new);
    }
    
    if(delegate && [delegate respondsToSelector:@selector(splitView:constrainMinCoordinate:ofSubviewAt:)]) {
        float min = [delegate splitView:self constrainMinCoordinate:0. ofSubviewAt:0];
        newFrame.size.width = MAX(min, newFrame.size.width);
        //NSLog(@"Constrained min width to: %f", newFrame.size.width);
    }
    
    if(delegate && [delegate respondsToSelector:@selector(splitView:constrainMaxCoordinate:ofSubviewAt:)]) {
        float max = [delegate splitView:self constrainMaxCoordinate:0. ofSubviewAt:0];
        newFrame.size.width = MIN(max, newFrame.size.width);
        //NSLog(@"Constrained max width to: %f", newFrame.size.width);
    }
    [_sideView setFrame:newFrame];
    [self setNeedsDisplay:YES];
    [self adjustSubviews];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NSSplitViewDidResizeSubviewsNotification object:self];
}

#pragma mark -
#pragma mark Position save support

- (NSString*)htmd__keyForLayoutName: (NSString*)name
{
    return [NSString stringWithFormat: @"HTMDSplitViewLayout%@", name];
}

- (void)storeLayoutWithName: (NSString*)name
{
    NSString* key = [self htmd__keyForLayoutName: name];
    NSMutableArray* viewRects = [NSMutableArray array];
    NSEnumerator* viewEnum = [[self subviews] objectEnumerator];
    NSView* view;
    NSRect frame;
    
    while((view=[viewEnum nextObject])!= nil)
    {
        if([self isSubviewCollapsed: view])
            frame = NSZeroRect;
        else
            frame = [view frame];
        [viewRects addObject: NSStringFromRect(frame)];
    }
    [[NSUserDefaults standardUserDefaults] setObject: viewRects forKey: key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadLayoutWithName: (NSString*)name
{
    NSString* key = [self htmd__keyForLayoutName: name];
    NSMutableArray* viewRects = [[NSUserDefaults standardUserDefaults] objectForKey: key];
    NSArray* views = [self subviews];

    int i, count;
    NSRect frame;
    count = MIN([viewRects count], [views count]);
    
    for(i=0; i<count; i++)
    {
        frame = NSRectFromString([viewRects objectAtIndex: i]);
        if(NSIsEmptyRect(frame))
        {
            frame = [[views objectAtIndex: i] frame];
            if([self isVertical])
                frame.size.width = 0;
            else
                frame.size.height = 0;
        }
        [[views objectAtIndex: i] setFrame: frame];
    }
}

@end
