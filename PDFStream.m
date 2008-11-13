//
//  PDFStream.m
//  LayerLink
//
//  Created by Eric Ocean on Thu Jul 15 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFStream.h"
#import "PDFStreamData.h"
#import "PDFDictionary.h"
#import "PDFParser.h"

#import "LOG_PDFPARSING_CALLBACKS_IMP.h"


@implementation PDFStream

- (void)handleParsedStreamDataObject:(PDFStreamData *)sd;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	bytes = [sd retain];
}

////////////// Tokens ///////////////

- (void)handleParsedStreamEndToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP
	
	[parser popCurrentParser];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

+ streamWithDictionary:(PDFDictionary *)d parser:(PDFParser *)p;
{
	return [[[self alloc] initWithDictionary:d parser:p] autorelease];
}

- initWithDictionary:(PDFDictionary *)d parser:(PDFParser *)p;
{
	if ( self = [super init] ) {
		dict = d;
		bytes = nil;
		parser = p; // weak retain
	}
	return self;
}

- (void)dealloc;
{
	[dict release]; dict = nil;
	[bytes release]; bytes = nil;
	parser = nil;
	[super dealloc];
}

- (NSString *)description;
{
	return [NSString stringWithFormat:@"stream\n%@\n%@\nendstream", dict, bytes];
}

- (NSData *)streamData;
{
	return [bytes data];
}

@end
