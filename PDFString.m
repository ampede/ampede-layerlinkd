//
//  PDFString.m
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFString.h"
#import "PDFParsingProtocol.h"


@implementation PDFString

+ stringWithData:(NSData *)theData;
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
	[theVisitor handleParsedStringObject:self];
}

- (NSString *)description;
{
	return [data description];
}

- (void)writeToData:(NSMutableData *)md;
{
	[md appendData:[@"(" dataUsingEncoding:NSASCIIStringEncoding]];
	[md appendData:data];
	[md appendData:[@")" dataUsingEncoding:NSASCIIStringEncoding]];
}

- (NSData *)data;
{
	return data;
}

- (NSString *)asNSString;
{
	return [NSString stringWithCString:(char *)[data bytes] length:[data length]]; 
}

@end
