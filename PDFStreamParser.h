//
//  PDFStreamParser.h
//  LayerLink
//
//  Created by Eric Ocean on 9/23/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class PDFParser;

@interface PDFStreamParser : NSObject
{
	PDFParser *parser;
	NSMutableArray *tokens;
}

- (void)setParser:(PDFParser *)theParser;

- (void)printContents;

- (void)
writeContentsToData:(NSMutableData *)md
upToButNotIncludingLayer:(int)layerNumber;

- (NSArray *)layerNames;

@end
