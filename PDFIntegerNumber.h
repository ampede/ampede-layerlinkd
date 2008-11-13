//
//  PDFIntegerNumber.h
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFObject.h"


@interface PDFIntegerNumber : PDFObject
{
	NSNumber *number;
}

+ integerNumberWithString:(NSString *)decimalNumberString;

- initWithString:(NSString *)decimalNumberString;

- (void)acceptPdfParsingVisitor:(id)theVisitor;

- (unsigned int)unsignedIntValue;

- (int)intValue;

- (NSNumber *)nsNumber;

@end
