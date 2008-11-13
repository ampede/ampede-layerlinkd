//
//  PDFArray.h
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFObject.h"


@class PDFParser;

@interface PDFArray : PDFObject
{
	NSMutableArray *array;
	NSMutableArray *tokens; // includes comments, etc.
	NSMutableArray *numberBuffer;
	PDFParser *parser;
}

+ arrayWithParser:(PDFParser *)p;
+ array;

- initWithParser:(PDFParser *)p;

- (void)addObject:(id)anObject;
- (void)addObjectWithoutAddingToken:(id)anObject;

- (void)emptyNumberBuffer;

- (id)objectAtIndex:(unsigned)index;

@end
