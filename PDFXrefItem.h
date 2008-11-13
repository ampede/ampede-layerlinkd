//
//  PDFXrefItem.h
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFObject.h"


@class PDFIntegerNumber;

@interface PDFXrefItem : PDFObject
{
	unsigned int offsetOrNumber;
	unsigned int generation;
	char status; // either 'n': in-use, or 'f': freed
}

+ inUseObjectWithOffset:(unsigned int)offset generation:(unsigned int)gen;
+ freeObjectWithNumber:(unsigned int)number generation:(unsigned int)gen;

- initInUseObjectWithOffset:(unsigned int)offset generation:(unsigned int)gen;
- initFreeObjectWithNumber:(unsigned int)number generation:(unsigned int)gen;

@end
