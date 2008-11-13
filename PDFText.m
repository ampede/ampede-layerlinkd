//
//  PDFText.m
//  LayerLink
//
//  Created by Eric Ocean on 9/25/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFText.h"
#import "PDFParser.h"
#import "LOG_PDFPARSING_CALLBACKS_IMP.h"


@implementation PDFText

- (void)handleParsedOperatorObject:(PDFOperator *)operator;
{
	LOG_PDFPARSING_CALLBACKS_IMP
	
//	NSLog(@"PDFText handleParsedOperatorObject called with op: %@", operator);

	if ( [[operator op] isEqualToString:@"ET"] )
	{
		// we're done!
		[parser popCurrentParser];
	}
}

- (void)setParser:(PDFParser *)p;
{
	parser = p; // weak retain
}

- (void)writeToData:(NSMutableData *)md;
{
	; // don't write anything
}

@end
