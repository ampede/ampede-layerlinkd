//
//  PDFTrailer.m
//  LayerLink
//
//  Created by Eric Ocean on Thu Jul 15 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFTrailer.h"
#import "PDFParser.h"
#import "PDFDictionary.h"
#import "LOG_PDFPARSING_CALLBACKS_IMP.h"


@implementation PDFTrailer

- (void)handleParsedDictionaryBeginToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	dict = [PDFDictionary dictionaryWithParser:parser];
	[parser pushParser:dict];
}

- (void)becameCurrentParserAfterPop;
{
	// trailer has a single dictionary, and no end token, making this necessary
//	NSLog(@"\n%@", [self description]);
	[parser popCurrentParser];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

+ trailerWithParser:(PDFParser *)p;
{
	return [[[self alloc] initWithParser:p] autorelease];
}

- initWithParser:(PDFParser *)p;
{
	if ( self = [super init] ) {
		parser = p; // weak retain
	}
	return self;
}

- (void)dealloc;
{
	parser = nil;
	[super dealloc];
}

- (NSString *)description;
{
	return [NSString stringWithFormat:@"\ntrailer\n%@\n\n", dict];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (PDFIntegerNumber *)size;
{
	return [dict objectForKey:@"Size"];
}

- (id)objectForKey:(NSString *)aString;
{
	return [dict objectForKey:aString];
}

- (PDFObjectReference *)infoObjectReference;
{	
	return [dict objectForKey:@"Info"];
}

@end
