//
//  PDFXrefItem.m
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFXrefItem.h"


@implementation PDFXrefItem

+ inUseObjectWithOffset:(unsigned int)offset generation:(unsigned int)gen;
{
	return [[[self alloc] initInUseObjectWithOffset:offset generation:gen] autorelease];
}

+ freeObjectWithNumber:(unsigned int)number generation:(unsigned int)gen;
{
	return [[[self alloc] initFreeObjectWithNumber:number generation:gen] autorelease];
}

- initInUseObjectWithOffset:(unsigned int)offset generation:(unsigned int)gen;
{
	if ( self = [super init] ) {
		offsetOrNumber = offset;
		generation = gen;
		status = 'n';
	}
	return self;
}

- initFreeObjectWithNumber:(unsigned int)number generation:(unsigned int)gen;
{
	if ( self = [super init] ) {
		offsetOrNumber = number;
		generation = gen;
		status = 'f';
	}
	return self;
}

- (NSString *)description;
{
	return [NSString stringWithFormat:@"%0.10d %0.5d %c", offsetOrNumber, generation, status];
}

@end
