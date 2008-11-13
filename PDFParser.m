//
//  PDFParser.m
//  LayerLink
//
//  Created by Eric Ocean on Thu Jul 15 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFParser.h"
#import "PDFLexer.h"
#import "PDFDocument.h"
#import "PDFParsingVisitorProtocol.h"
#import "NSMutableArray+StackOperations.h"
#import "PDFStreamLexer.h"


@implementation NSObject (PDFParserCallbacks)

- (void)becameCurrentParserAfterPop; {}
	// called on the object that becomes the current parser after popCurrentParser is called

@end


@implementation PDFParser

// designated initializer
- initWithData:(NSData *)theData forDocument:(PDFDocument *)pdfDoc;
{
	if ( self = [super init] ) {
		data = [theData retain];
		lexer = [[PDFLexer alloc] initWithData:data];
		stack = [[NSMutableArray alloc] initWithCapacity:10];
		doc = pdfDoc; // weak retain
		error = nil;
		
		[doc setParser:self];
		[stack push:pdfDoc];
	}
	return self;
}

- (void)
dealloc;
{
	[data release]; data = nil;
	[lexer release]; lexer = nil;
	[stack release]; stack = nil;
	[super dealloc];
}

// PDFParser manages a stack of objects implementing the PDFParsing informal protocol.
// The object on the top is the current parser.

- (BOOL)
parseDocument;
{
	NSEnumerator *enumerator = [lexer tokenEnumerator];
	id aToken;

	while ( (aToken = [enumerator nextObject]) && (error == nil) )
	{
		[aToken acceptPdfParsingVisitor:[stack top]];
	}
	
	if ( error != nil )
	{
		//display error message here
		return NO; // failure
	}
	else return YES; // success
}

- (BOOL)parseStream;
{
	[lexer release];
	lexer = [[PDFStreamLexer alloc] initWithData:data];
	
	NSEnumerator *enumerator = [lexer tokenEnumerator];
	id aToken;

	while ( (aToken = [enumerator nextObject]) && (error == nil) )
	{
//		NSLog(@"token: %@", aToken);
		[aToken acceptPdfParsingVisitor:[stack top]];
	}
	
	if ( error != nil )
	{
		//display error message here
		return NO; // failure
	}
	else return YES; // success
}

- (void)pushParser:(id)aParsingProtocolObject;
{
	[stack push:aParsingProtocolObject];
}

- (void)popCurrentParser;
{
	[stack pop];
	[[stack top] becameCurrentParserAfterPop];
}


@end
