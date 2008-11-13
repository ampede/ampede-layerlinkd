//
//  PDFInlineImage.m
//  LayerLink
//
//  Created by Eric Ocean on 9/25/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFInlineImage.h"
#import "PDFParser.h"
#import "LOG_PDFPARSING_CALLBACKS_IMP.h"


@implementation PDFInlineImage

- (void)handleParsedOperatorObject:(PDFOperator *)operator;
{
	LOG_PDFPARSING_CALLBACKS_IMP
	
//	NSLog(@"PDFInlineImage handleParsedOperatorObject called with op: %@", operator);

	if ( [[operator op] isEqualToString:@"EI"] )
	{
		// we're done!
		[parser popCurrentParser];
	}
}

- (void)setParser:(PDFParser *)p;
{
	parser = p; // weak retain
}

@end
