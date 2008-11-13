//
//  PDFRealNumber.m
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFRealNumber.h"
#import "PDFParsingProtocol.h"


@implementation PDFRealNumber

+ realNumberWithString:(NSString *)decimalNumberString;
{
	return [[[self alloc] initWithString:decimalNumberString] autorelease];
}

- initWithString:(NSString *)decimalNumberString;
{
	if ( self = [super init] ) {
		number = [[NSDecimalNumber alloc] initWithString:decimalNumberString];
	}
	return self;
}

- (void)dealloc;
{
	[number release]; number = nil;
	[super dealloc];
}

- (void)
acceptPdfParsingVisitor:(id)theVisitor;
{
	[theVisitor handleParsedRealNumberObject:self];
}

- (NSString *)description;
{
	return [number descriptionWithLocale:nil];
}

@end
