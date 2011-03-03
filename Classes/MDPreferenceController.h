//
//  MDPreferenceController.h
//  MissingDrawer
//
//  Created by Mads Hartmann Jensen on 12/9/10.
//  Copyright 2010 Sidewayscoding. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MDPreferenceController : NSObject {

	NSWindowController* preferenceWindowController;
	IBOutlet NSView* preferencesView;
	
}

+ (MDPreferenceController*)instance;

@property(retain, readonly) NSView* preferencesView;

@end
