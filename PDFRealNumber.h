//
//  PDFRealNumber.h
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFObject.h"


@interface PDFRealNumber : PDFObject
{
	NSDecimalNumber *number;
}

+ realNumberWithString:(NSString *)decimalNumberString;

- initWithString:(NSString *)decimalNumberString;

- (void)acceptPdfParsingVisitor:(id)theVisitor;

@end
