//
//  PDFParsingProtocol.h
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFObjects.h"


// These are the callbacks that objects managed by the PDFParser class (and used by the PDFLexer) must manage.
// This is not an informal protocol because I want each parsing object to handle the full range of problems that can
// occur during a parse and give appropriate, context sensitive error messages when things go awry.

//@class PDFComment, PDFString, PDFName, PDFBoolean, PDFRealNumber, PDFIntegerNumber;

@interface NSObject ( PDFParsing )

- (void)handleParsedBooleanObject:(PDFBoolean *)theBoolean;
- (void)handleParsedIntegerNumberObject:(PDFIntegerNumber *)theInt;
- (void)handleParsedRealNumberObject:(PDFRealNumber *)theReal;
- (void)handleParsedNameObject:(PDFName *)theName;
- (void)handleParsedStringObject:(PDFString *)theString;
- (void)handleParsedStreamDataObject:(PDFStreamData *)sd;
- (void)handleParsedOperatorObject:(PDFOperator *)op;

- (void)handleParsedCommentObject:(PDFComment *)theComment;

- (void)handleParsedBeginIndirectObjectToken;
- (void)handleParsedEndIndirectObjectToken;

- (void)handleParsedObjectReferenceToken;

- (void)handleParsedArrayBeginToken;
- (void)handleParsedArrayEndToken;

- (void)handleParsedDictionaryBeginToken;
- (void)handleParsedDictionaryEndToken;

- (void)handleParsedStreamBeginToken;
- (void)handleParsedStreamEndToken;

- (void)handleParsedPdfNullToken;
- (void)handleParsedTrailerToken;
- (void)handleParsedStartxrefToken;
- (void)handleParsedXrefToken;
- (void)handleParsedObjectFreeToken;
- (void)handleParsedObjectInUseToken;

@end


// These are callbacks that are only of interest to stream parsers.

@interface NSObject ( PDFStreamParsing )

@end
