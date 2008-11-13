//
//  PDFOperator.h
//  LayerLink
//
//  Created by Eric Ocean on 9/23/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFObject.h"


@class PDFParser;

@interface PDFOperator : PDFObject
{
	NSString *op;
}

+ operatorWithString:(NSString *)opString;

- initWithString:(NSString *)opString;

- (NSString *)op;

- (PDFOperator *)nonPaintingEquivalent;

- (PDFOperator *)containerOp;

- (void)setParser:(PDFParser *)p;

@end
