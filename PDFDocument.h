//
//  PDFDocument.h
//  LayerLink
//
//  Created by Eric Ocean on Thu Jul 15 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class PDFParser, PDFIndirectObject, PDFObject, PDFTrailer, PDFXref, PDFName, PDFObjectReference, PDFDictionary;

@interface PDFDocument : NSDocument 
{
	PDFParser *parser;
	NSMutableArray *indirectObjects;
	NSMutableArray *numberBuffer;
	PDFTrailer *trailer;
	PDFXref *xref;
	UInt32 startxref; // we can only handle files up to 4GB this way
	BOOL captureStartxref;
}

- (void)setParser:(PDFParser *)theParser;
- (void)addIndirectObject:(PDFIndirectObject *)theObject;

- (int)startxref;

- (NSData *)objectDataForHiddenLayerObjectName:(PDFName *)aName;

- (id)objectForReference:(PDFObjectReference *)ref;

- (NSArray *)hiddenLayerNames;

- (int)firstPageObjectNumber;
- (int)firstPageGenerationNumber;

- (int)contentObjectNumber;
- (int)contentGenerationNumber;

- (PDFDictionary *)firstPageDictionaryMutableCopy;

- (int)numberOfObjects;

- (NSString *)producerAsNSString;
- (NSString *)creatorAsNSString;

- (BOOL)firstPageContentStreamNeedsInflate;

@end