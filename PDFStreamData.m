//
//  PDFStreamData.m
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFStreamData.h"
#import "PDFParsingProtocol.h"


@implementation PDFStreamData

+ streamDataWithData:(NSData *)theData;
{
	return [[[self alloc] initWithData:theData] autorelease];
}

- initWithData:(NSData *)theData;
{
	if ( self = [super init] ) {
		data = [theData retain];
	}	
	return self;
}

- (void)dealloc;
{
	[data release]; data = nil;
	[super dealloc];
}

- (void)
acceptPdfParsingVisitor:(id)theVisitor;
{
	[theVisitor handleParsedStreamDataObject:self];
}

- (NSData *)data;
{
	return data;
}

@end
