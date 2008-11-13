//
//  PDFInlineImage.h
//  LayerLink
//
//  Created by Eric Ocean on 9/25/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFOperator.h"


@class PDFParser;

@interface PDFInlineImage : PDFOperator
{
	PDFParser *parser;
}

@end
