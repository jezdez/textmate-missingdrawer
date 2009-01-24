//
//  HTMDMissingDrawer.m
//  MissingDrawer

#import <objc/objc-runtime.h>
#import "HTMDMissingDrawer.h"
#import "HTMDSplitView.h"
#import "HTMDSidebarBorderView.h"

#pragma mark -
#pragma mark Replacement functions 

IMP org_OakProjectController_windowWillClose=NULL;
void rep_OakProjectController_windowWillClose(id self, SEL _cmd, id aNotification)
{
    //reset
    id window=[aNotification object];
    id splitView=[window contentView];
    if([splitView isKindOfClass:[HTMDSplitView class]])
        [splitView windowWillCloseWillCall];
    
    // call original
    org_OakProjectController_windowWillClose(self, _cmd, aNotification);
}

IMP org_OakProjectController_windowDidLoad=NULL;
void rep_OakProjectController_windowDidLoad(id self, SEL _cmd)
{
    //NSLog(@"window did load");
    // call original
    org_OakProjectController_windowDidLoad(self, _cmd);
    NSWindow* window=[self window];
    NSView* contentView=[[window contentView]retain];
    NSDrawer* drawer=[[window drawers]objectAtIndex:0];
    NSView* leftView=[[drawer contentView]retain];
    [drawer setContentView:nil];
    [window setContentView:nil];
    
    HTMDSidebarBorderView* borderView=[[HTMDSidebarBorderView alloc]initWithFrame:[leftView frame]];
    [borderView addToSuperview:leftView];
    
    NSView* splitView=[HTMDMissingDrawer makeSplitViewWithMainView:contentView sideView:leftView];
    [window setContentView:splitView];
    [borderView release];
    [contentView release];
    [leftView release];
    [splitView loadLayoutWithName:@"Panels"];
    
}

IMP org_OakProjectController_openProjectDrawer=NULL;
void rep_OakProjectController_openProjectDrawer(id self, SEL _cmd, id sender)
{
    NSWindow* window=[self window];
    NSView* contentView=[[window contentView]retain];
    //NSLog(@"project drawer opened");
    
    if ([[contentView className] isEqualToString:@"HTMDSplitView"]) {
        //NSLog(@"panel exists and menu item was clicked");
        NSView* leftView=[[contentView subviews]objectAtIndex:0];
        NSRect leftFrame=[leftView frame];

        if (leftFrame.size.width==0) {
            //NSLog(@"show hidden panel");
            [contentView loadLayoutWithName:@"Panels"];
            [contentView adjustSubviews];
        }else{
            //NSLog(@"hide visible panel");
            [contentView storeLayoutWithName:@"Panels"];
            leftFrame.size.width = 0;
            [leftView setFrame:leftFrame];
            [contentView adjustSubviews];
        }
    }
}

IMP org_OakProjectController_revealInProject=NULL;
void rep_OakProjectController_revealInProject(id self, SEL _cmd, id sender)
{
    //NSLog(@"reveal in project, yeah!");
	org_OakProjectController_revealInProject(self, _cmd, sender);
	org_OakProjectController_revealInProject(self, _cmd, sender);

  NSWindow* window=[self window];
  NSView* contentView=[[window contentView]retain];
  //NSLog(@"project drawer opened");
  
  if ([[contentView className] isEqualToString:@"HTMDSplitView"]) {
      //NSLog(@"panel exists and menu item was clicked");
      NSView* leftView=[[contentView subviews]objectAtIndex:0];
      NSRect leftFrame=[leftView frame];

      if (leftFrame.size.width==0) {
          //NSLog(@"show hidden panel");
        rep_OakProjectController_openProjectDrawer(self, _cmd, sender);
      }
  }
}

#pragma mark -
#pragma mark Plugin methods

@implementation HTMDMissingDrawer

- (id)initWithPlugInController:(id <TMPlugInController>)aController
{
  if (self = [super init]) {
        //NSLog(@"Textmate plugin MissingDrawer loaded.");
        [self _setup];
  }
  return self;
}

- (void)_setup
{
    org_OakProjectController_windowDidLoad =
        [HTMDMissingDrawer replaceClassName:@"OakProjectController"
            selectorName:@"windowDidLoad" 
            withFunc:rep_OakProjectController_windowDidLoad isClassMethod:NO];

    org_OakProjectController_windowWillClose =
        [HTMDMissingDrawer replaceClassName:@"OakProjectController"
            selectorName:@"windowWillClose:" 
            withFunc:rep_OakProjectController_windowWillClose isClassMethod:NO];

    org_OakProjectController_openProjectDrawer =
        [HTMDMissingDrawer replaceClassName:@"OakProjectController"
            selectorName:@"openProjectDrawer:"
            withFunc:rep_OakProjectController_openProjectDrawer isClassMethod:NO];

    org_OakProjectController_revealInProject =
    [HTMDMissingDrawer replaceClassName:@"OakProjectController"
            selectorName:@"revealInProject:"
            withFunc:rep_OakProjectController_revealInProject isClassMethod:NO];
    
}

#pragma mark -
#pragma mark Custom

+ (NSView*)makeSplitViewWithMainView:(NSView*)contentView sideView:(NSView*)sideView
{
    NSSplitView* splitView=[[HTMDSplitView alloc]initWithFrame:[contentView frame]];
    [splitView setVertical:YES];
    [splitView addSubview:sideView];
    [splitView addSubview:contentView];
    return [splitView autorelease];
}

#pragma mark -
#pragma mark Class replacement support

+ (IMP)replaceClassName:(NSString*)className selectorName:(NSString*)origSelName withFunc:(const void*)repFunc isClassMethod:(BOOL)isClassMethod
{
    Class aClass=NSClassFromString(className);
    SEL origSel=NSSelectorFromString(origSelName);
    if(aClass){
        return [HTMDMissingDrawer replaceClass:aClass selector:origSel withFunc:repFunc isClassMethod:isClassMethod];
    }
    return nil;
}

+ (IMP)replaceClass:(Class)aClass selector:(SEL)origSel withFunc:(const void*)repFunc isClassMethod:(BOOL)isClassMethod
{
     struct objc_method *origMethod;
     IMP oldImp = NULL;
     extern void _objc_flush_caches(Class);
     if ((origMethod = class_getInstanceMethod(aClass, origSel))){
         oldImp = origMethod->method_imp;
         // Replace the method in place
         origMethod->method_imp = repFunc;
         // Flush the method cache
         _objc_flush_caches(aClass);
     }
    //return original func pointer
     return oldImp;
}

@end