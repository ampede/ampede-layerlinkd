//
//  PDFToken.m
//  LayerLink
//
//  Created by Eric Ocean on Fri Jul 16 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFToken.h"


@implementation PDFToken

+ (id)pdfNull;
{
	return [[[self alloc] initWithString:@"PdfNullToken"] autorelease];
}

+ (id)objectReference;
{
	return [[[self alloc] initWithString:@"ObjectReferenceToken"] autorelease];
}

+ (id)beginIndirectObject;
{
	return [[[self alloc] initWithString:@"BeginIndirectObjectToken"] autorelease];
}

+ (id)endIndirectObject;
{
	return [[[self alloc] initWithString:@"EndIndirectObjectToken"] autorelease];
}

+ (id)beginArray;
{
	return [[[self alloc] initWithString:@"ArrayBeginToken"] autorelease];
}

+ (id)endArray;
{
	return [[[self alloc] initWithString:@"ArrayEndToken"] autorelease];
}

+ (id)beginDict;
{
	return [[[self alloc] initWithString:@"DictionaryBeginToken"] autorelease];
}

+ (id)endDict;
{
	return [[[self alloc] initWithString:@"DictionaryEndToken"] autorelease];
}

+ (id)beginStream;
{
	return [[[self alloc] initWithString:@"StreamBeginToken"] autorelease];
}

+ (id)endStream;
{
	return [[[self alloc] initWithString:@"StreamEndToken"] autorelease];
}

+ (id)trailer;
{
	return [[[self alloc] initWithString:@"TrailerToken"] autorelease];
}

+ (id)startxref;
{
	return [[[self alloc] initWithString:@"StartxrefToken"] autorelease];
}

+ (id)xref;
{
	return [[[self alloc] initWithString:@"XrefToken"] autorelease];
}

+ (id)pdfFree;
{
	return [[[self alloc] initWithString:@"ObjectFreeToken"] autorelease];
}

+ (id)inUse;
{
	return [[[self alloc] initWithString:@"ObjectInUseToken"] autorelease];
}

- initWithString:(NSString *)aShortName;
{
	if ( self = [super init] ) {
		shortName = aShortName; // this is a static string, so no need to memory manage
		tokenSelector = NSSelectorFromString( [@"handleParsed" stringByAppendingString:shortName] );
	}
	return self;
}

- (void)
dealloc;
{
	[super dealloc];
}

- (NSString *)description;
{
	return shortName; // this is a static string, so no need to memory manage
}

- (void)
acceptPdfParsingVisitor:(id)theVisitor;
{
	void (*handler)(id, SEL);

	handler = (void (*)(id, SEL))[theVisitor methodForSelector:tokenSelector];
	
	handler( theVisitor, tokenSelector );
}

@end

