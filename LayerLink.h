//
//  LayerLink.h
//  LayerLink
//
//  Created by Eric Ocean on 10/4/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class UKKQueue;

@interface LayerLink : NSObject
{
	NSUserDefaults *defaults;
	UKKQueue *kqueue;
	
	NSMutableDictionary *filePathToLayerLinkFolder;
	NSMutableDictionary *pendingAiFiles;
}

- (NSUserDefaults *)defaults;

- (UKKQueue *)kqueue;

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification;

- (void)monitorLayerLinkFolder;

- (void)addLayerLinkFolder:(NSString *)folderName;

@end
