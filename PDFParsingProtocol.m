//
//  PDFParsingProtocol.m
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFParsingProtocol.h"


#import "PDFParsingProtocolDebug.h"


@implementation NSObject ( PDFParsing )

- (void)handleParsedBooleanObject:(PDFBoolean *)theBoolean;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedIntegerNumberObject:(PDFIntegerNumber *)theInt;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedRealNumberObject:(PDFRealNumber *)theReal;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedNameObject:(PDFName *)theName;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedStringObject:(PDFString *)theString;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedCommentObject:(PDFComment *)theComment;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedOperatorObject:(PDFOperator *)op;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedStreamDataObject:(PDFStreamData *)sd;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedBeginIndirectObjectToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedEndIndirectObjectToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedObjectReferenceToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedArrayBeginToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedArrayEndToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedDictionaryBeginToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedDictionaryEndToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedStreamBeginToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedStreamEndToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedPdfNullToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedTrailerToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedStartxrefToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedXrefToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedObjectFreeToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

- (void)handleParsedObjectInUseToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP
}

@end
