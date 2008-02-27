//
//  HTMDMissingDrawer.h
//  MissingDrawer

#import <Cocoa/Cocoa.h>

@protocol TMPlugInController
	- (float)version;
@end

@interface HTMDMissingDrawer : NSObject
{
}
+ (NSView*)makeSplitViewWithMainView:(NSView*)contentView sideView:(NSView*)sideView;
+ (IMP)replaceClassName:(NSString*)className selectorName:(NSString*)origSelName withFunc:(const void*)repFunc isClassMethod:(BOOL)isClassMethod;
+ (IMP)replaceClass:(Class)aClass selector:(SEL)origSel withFunc:(const void*)repFunc isClassMethod:(BOOL)isClassMethod;

- (id)initWithPlugInController:(id <TMPlugInController>)aController;
- (void)_setup;

@end
