//
//  PDFObjectReference.h
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFObject.h"


@class PDFIntegerNumber;

@interface PDFObjectReference : PDFObject
{
	PDFIntegerNumber *number;
	PDFIntegerNumber *generation;
}

+ objectReferenceWithNumber:(PDFIntegerNumber *)num generation:(PDFIntegerNumber *)gen;

- initWithNumber:(PDFIntegerNumber *)num generation:(PDFIntegerNumber *)gen;

- (PDFIntegerNumber *)number;
- (PDFIntegerNumber *)generation;

@end
