//
//  HTMDSplitView.h
//  MissingDrawer

#import <Cocoa/Cocoa.h>

@interface HTMDSplitView : NSSplitView {
    NSView* _sideView;
    NSView* _mainView;

	IBOutlet id resizeSlider;
	BOOL inResizeMode;
}
- (void)windowWillCloseWillCall;
- (IBAction)adjustSubviews:(id)sender;

- (void)storeLayoutWithName:(NSString *)name;
- (void)loadLayoutWithName:(NSString *)name;

@end
