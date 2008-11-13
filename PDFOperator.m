//
//  PDFOperator.m
//  LayerLink
//
//  Created by Eric Ocean on 9/23/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFOperator.h"
#import "PDFParsingVisitorProtocol.h"
#import "PDFParsingProtocol.h"

#import "PDFInlineImage.h"
#import "PDFText.h"


@implementation PDFOperator

+ operatorWithString:(NSString *)opString;
{
	return [[[self alloc] initWithString:opString] autorelease];
}

- initWithString:(NSString *)opString;
{
	if ( self = [super init] ) {
		op = [opString retain];
	}
	return self;
}

- (void)dealloc;
{
	[op release]; op = nil;
	[super dealloc];
}

- (NSString *)op;
{
	return op;
}

- (NSString *)description;
{
	return op;
}

- (void)
acceptPdfParsingVisitor:(id)theVisitor;
{
	[theVisitor handleParsedOperatorObject:self];
}

- (PDFOperator *)nonPaintingEquivalent;
{
	if (	[op isEqualToString:@"b"]	||
			[op isEqualToString:@"B"]	||
			[op isEqualToString:@"b*"]	||
			[op isEqualToString:@"B*"]	||
			[op isEqualToString:@"f"]	||
			[op isEqualToString:@"F"]	||
			[op isEqualToString:@"f*"]	||
			[op isEqualToString:@"s"]	||
			[op isEqualToString:@"S"]		)
	{
		[op release]; op = @"n";
	}
	return self;
}

- (PDFOperator *)containerOp;
{
	if ( [op isEqualToString:@"BT"] )
	{
		return [[[PDFText alloc] init] autorelease];
	}
	else return self;
}

- (void)setParser:(PDFParser *)p; {}

@end
