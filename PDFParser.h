//
//  PDFParser.h
//  LayerLink
//
//  Created by Eric Ocean on Thu Jul 15 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFParsingProtocol.h"


// This class is responsible for parsing PDF data. The data need not be complete.
// It interacts principally with PDFLexer and objects that implement the PDFParsing informal protocol.
// It defines specialized methods to parse different aspects of a PDF file, such as the cross-reference table.
// Usually, you will use it to parse an indirect object.
//
// It it always the caller's repsonsibility to insure that the NSData passed contains enough data to complete the
// desired parse, and that the data starts at the correct position to begin that parse.
// It is acceptable to send too much data (at the end); the parser will only use as much as it needs.
//
// All parsing methods return nil on error.

@class PDFLexer, PDFIndirectObject, PDFStreamData, PDFTrailer, PDFXref, PDFDocument;

@interface PDFParser : NSObject
{
	NSData *data;
	PDFLexer *lexer;
	NSMutableArray *stack;
	PDFDocument *doc;
	NSError *error;
}

// designated initializer
- initWithData:(NSData *)theData forDocument:(PDFDocument *)pdfDoc;

// PDFParser manages a stack of objects implementing the PDFParsing informal protocol.
// The object on the top is the current parser.

// main method; this parses the entire document, assigning pdf objects to its pdfDoc
- (BOOL)parseDocument;
	// returns YES on success, NO on failure
- (BOOL)parseStream;
	// returns YES on success, NO on failure
	
- (void)pushParser:(id)aParsingProtocolObject;
- (void)popCurrentParser;

// convenience methods
//+ (PDFIndirectObject *)parseIndirectObjectFromData:(NSData *)theData;
//+ (PDFStreamData *)parseStreamDataFromData:(NSData *)theData;
//
//+ (NSString *)parseHeaderFromData:(NSData *)theData;
//+ (PDFTrailer *)parseTrailerFromData:(NSData *)theData;
//+ (PDFXref *)parseXrefFromData:(NSData *)theData;

// These methods determine what kind of parsing object PDFParser will instantiate to handle the parse
// That object becomes the first (and initially the only) object on the parsing stack.
//- (PDFIndirectObject *)parseIndirectObject;
//- (PDFStreamData *)parseStreamData;
//		// this allows you to parse just the data stream of a stream object
//		// it's useful when you already have the stream, and just want to do something with it, such as transforming it
//		
//- (NSString *)parseHeader;
//- (PDFTrailer *)parseTrailer;
//- (PDFXref *)parseXref;

@end


@interface NSObject (PDFParserCallbacks)

- (void)becameCurrentParserAfterPop;

@end


