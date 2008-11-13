//
//  PDFIntegerNumber.m
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFIntegerNumber.h"
#import "PDFParsingProtocol.h"


@implementation PDFIntegerNumber

+ integerNumberWithString:(NSString *)numberString;
{
	return [[[self alloc] initWithString:numberString] autorelease];
}

- initWithString:(NSString *)numberString;
{
	if ( self = [super init] ) {
		number = [[NSNumber alloc] initWithInt:[numberString intValue]];
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
	[theVisitor handleParsedIntegerNumberObject:self];
}

- (NSString *)description;
{
	return [number description];
}

- (unsigned int)unsignedIntValue;
{
	return [number unsignedIntValue];
}

- (int)intValue;
{
	return [number intValue];
}

- (unsigned int)hash;
{
	return [number hash];
}

- (BOOL)isEqual:(id)anObject;
{
	return [number isEqual:[anObject nsNumber]];
}

- (NSNumber *)nsNumber;
{
	return number;
}

@end
