//
//  PDFXref.h
//  LayerLink
//
//  Created by Eric Ocean on Thu Jul 15 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFObject.h"


@class PDFIntegerObject, PDFParser;

@interface PDFXref : PDFObject
{
	// This should probably be a standard, malloc'd array, not an NSArray. I'm just not sure how to do that.
	NSMutableArray *toc; // an array of PDFIndirectObject; there is one entry for each possible object number
	PDFParser *parser;
	
	BOOL getFirstLine;
	PDFIntegerNumber *firstObject;
	PDFIntegerNumber *lastObject;
	
	PDFIntegerNumber *tmpOffsetOrObjectNumber;
	PDFIntegerNumber *tmpGeneration;
}

+ xrefWithParser:(PDFParser *)p;

- initWithParser:(PDFParser *)p;

@end
