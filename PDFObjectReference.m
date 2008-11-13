//
//  PDFObjectReference.m
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFObjectReference.h"
#import "PDFIntegerNumber.h"


@implementation PDFObjectReference

+ objectReferenceWithNumber:(PDFIntegerNumber *)num generation:(PDFIntegerNumber *)gen;
{
	return [[[self alloc] initWithNumber:num generation:gen] autorelease];
}

- initWithNumber:(PDFIntegerNumber *)num generation:(PDFIntegerNumber *)gen;
{
	if ( self = [super init] ) {
		number = [num retain];
		generation = [gen retain];
	}
	return self;
}

- (void)dealloc;
{
	[number release]; number = nil;
	[generation release]; generation = nil;
	[super dealloc];
}

- (NSString *)description;
{
	return [NSString stringWithFormat:@"%@ %@ R", number, generation];
}

- (PDFIntegerNumber *)number;
{
	return number;
}

- (PDFIntegerNumber *)generation;
{
	return generation;
}

@end
