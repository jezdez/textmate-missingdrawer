//
//  MDPreferenceController.m
//  MissingDrawer
//
//  Created by Mads Hartmann Jensen on 12/9/10.
//  Copyright 2010 Sidewayscoding. All rights reserved.
//

#import "MDPreferenceController.h"


@implementation MDPreferenceController

@synthesize preferencesView;

static MDPreferenceController *sharedInstance = nil;

+ (MDPreferenceController*)instance
{
	@synchronized(self) {
		if (sharedInstance == nil) {
			[[self alloc] init];
		}
	}
	return sharedInstance;
}

-(id)init
{
	if (self = [super init]) {
		sharedInstance = self;
		
		// Load the preference NIB
		NSString* nibPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Preferences" ofType:@"nib"];
		preferenceWindowController = [[NSWindowController alloc] initWithWindowNibPath:nibPath owner:self];
		[preferenceWindowController showWindow:self];
		
    }
	return self; 
}



@end
