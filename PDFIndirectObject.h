//
//  PDFIndirectObject.h
//  LayerLink
//
//  Created by Eric Ocean on Thu Jul 15 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFObject.h"


@class PDFIntegerNumber, PDFParser, PDFObjectReference;

@interface PDFIndirectObject : PDFObject
{
	PDFIntegerNumber *number;
	PDFIntegerNumber *generation;
	id value;
	NSMutableArray *tokens; // includes comments, etc.
	PDFParser *parser;
}

// designated initializer
- initWithNumber:(PDFIntegerNumber *)num generation:(PDFIntegerNumber *)gen parser:(PDFParser *)p;
- initWithNumber:(PDFIntegerNumber *)num generation:(PDFIntegerNumber *)gen;

- (void)setValue:(id)aValue;

- (BOOL)isObjectOfReference:(PDFObjectReference *)ref;

- (id)value;

@end
