//
//  NSObject+MDOakProjectControllerMethodReplacements.h
//  MissingDrawer
//
//  Created by Sam Soffes on 8/18/10.
//  Copyright 2010 Sam Soffes. All rights reserved.
//

@interface NSObject (MDOakProjectControllerMethodReplacements)

- (void)MD_repl_windowDidLoad;
- (void)MD_repl_windowWillClose:(NSNotification *)notification;
- (void)MD_repl_revealInProject:(id)sender;
- (void)MD_repl_openProjectDrawer:(id)sender;

@end
