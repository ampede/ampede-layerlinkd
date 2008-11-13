//
//  PDFDocument.m
//  LayerLink
//
//  Created by Eric Ocean on Thu Jul 15 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFDocument.h"
#import "PDFParsingProtocol.h"
#import "PDFParser.h"
#import "PDFTrailer.h"
#import "PDFXref.h"
#import "PDFIntegerNumber.h"
#import "PDFStreamParser.h"


@implementation PDFDocument

// PDFDocument should only have to respond to:
//
//		handleParsedIntegerNumberObject:
//		handleParsedBeginIndirectObjectToken
//		handleParsedTrailerToken
//		handleParsedStartxrefToken
//		handleParsedXrefToken
//
// Everything else is an error.

- (void)handleParsedIntegerNumberObject:(PDFIntegerNumber *)theInt;
{
//	NSLog(@"%@", NSStringFromSelector( _cmd ) );
	
	if ( captureStartxref )
	{
		startxref = [theInt unsignedIntValue];
		captureStartxref = NO;
//		NSLog(@"\n\nstartxref\n%u\n\n", startxref);
		return;
	}

	[numberBuffer addObject:theInt];
}

////////////// Tokens ///////////////

- (void)handleParsedBeginIndirectObjectToken;
{
	if ( [numberBuffer count] != 2 )
	{
		// register an exception with PDFParser
		exit(111);
	}
	else if ( ([[numberBuffer objectAtIndex:0] class] != [PDFIntegerNumber class]) ||
		 ([[numberBuffer objectAtIndex:1] class] != [PDFIntegerNumber class]) )
	{
		// register an exception with PDFParser
		exit(111);
	}
	else
	{
		id tmp = [[PDFIndirectObject alloc]
						initWithNumber:[numberBuffer objectAtIndex:0]
						generation:[numberBuffer objectAtIndex:1]
						parser:parser];
		[numberBuffer removeAllObjects];
		[self addIndirectObject:tmp];
		[parser pushParser:tmp];
		[tmp release];
	}
}

- (void)handleParsedTrailerToken;
{
	trailer = [[PDFTrailer alloc] initWithParser:parser];
	[parser pushParser:trailer];
}

- (void)handleParsedStartxrefToken;
{
	captureStartxref = YES;
}

- (void)handleParsedXrefToken;
{
	xref = [[PDFXref alloc] initWithParser:parser];
	[parser pushParser:xref];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- init
{
	if ( self = [super init] ) {
		indirectObjects = [[NSMutableArray alloc] init];
		numberBuffer = [[NSMutableArray alloc] init];
		trailer = nil;
		xref = nil;
		startxref = 0;
		captureStartxref = NO;
	}
	return self;
}

- (void)
dealloc;
{
	[indirectObjects release]; indirectObjects = nil;
	[numberBuffer release]; numberBuffer = nil;
	[trailer release]; trailer = nil;
	[xref release]; xref = nil;
	[super dealloc];
}

- (void)setParser:(PDFParser *)theParser;
{
	parser = theParser; // weak retain
}

- (void)addIndirectObject:(PDFIndirectObject *)theObject;
{
	[indirectObjects addObject:theObject];
}

- (NSString *)windowNibName
{
    // Implement this to return a nib to load OR implement -makeWindowControllers to manually create your controllers.
    return @"PDFDocument";
}

- (NSData *)
dataRepresentationOfType:(NSString *)type
{
    // Implement to provide a persistent data representation of your document OR remove this and implement the
	// file-wrapper or file path based save methods.
    return nil;
}

- (BOOL)
loadDataRepresentation:(NSData *)data
ofType:(NSString *)type;
{
	if (1) // ( [type isEqualToString:@"Portable Document Format"] )
	{
//		NSLog(@"reading file...");
	
		PDFParser *myParser = [[PDFParser alloc] initWithData:data forDocument:self];
	
		if ( [myParser parseDocument] )
		{
			// report success
//			NSLog(@"successfully read document");
		}
		else
		{
			// report failure
			NSLog(@"LayerLink error: could not read document. Make sure document is created with Illustrator 10 or greater.");
		}
	}
	else if ( [type isEqualToString:@"Portable Document Stream Format"] )
	{
//		NSLog(@"reading stream...");
	
		PDFStreamParser *myStreamParser = [[PDFStreamParser alloc] init];
		PDFParser *myParser = [[PDFParser alloc] initWithData:data forDocument:(PDFDocument *)myStreamParser];

		if ( [myParser parseStream] )
		{
			// report success
//			NSLog(@"successfully read stream");
			[myStreamParser printContents];
		}
		else
		{
			// report failure
//			NSLog(@"failed to read stream");
		}
	}

	return NO;
}

- (void)
windowControllerDidLoadNib:(NSWindowController *)wc;
{

}

- (int)startxref;
{
	return startxref;
}

- (NSData *)objectDataForHiddenLayerObjectName:(PDFName *)aName;
{
	PDFObjectReference *rootObjectRef = [trailer objectForKey:@"Root"];
	PDFIndirectObject *rootObject = [self objectForReference:rootObjectRef];

	PDFObjectReference *pagesRef = [rootObject objectForKey:@"Pages"];
	PDFIndirectObject *pagesObject = [self objectForReference:pagesRef];

	PDFObjectReference *pageRef = [[pagesObject objectForKey:@"Kids"] objectAtIndex:0];
	PDFIndirectObject *pageObject = [self objectForReference:pageRef];
	
	PDFObjectReference *hiddenLayerRef = [[[pageObject objectForKey:@"Resources"]
													   objectForKey:@"Properties"]
													   objectForKey:[aName string]];
	PDFIndirectObject *hiddenLayer = [self objectForReference:hiddenLayerRef];
	
	PDFObjectReference *hiddenLayerContentsRef = [hiddenLayer objectForKey:@"Contents"];
	PDFIndirectObject *hiddenLayerContents = [self objectForReference:hiddenLayerContentsRef];
	
	return [[hiddenLayerContents value] streamData];
}

- (id)objectForReference:(PDFObjectReference *)ref;
{
	NSEnumerator *enumerator = [indirectObjects objectEnumerator];
	PDFIndirectObject *anObject;
	
	while ( anObject = [enumerator nextObject] )
	{
		if ( [anObject isObjectOfReference:ref] ) return anObject;
	}
	return nil;
}

- (NSArray *)hiddenLayerNames;
{
	PDFObjectReference *rootObjectRef = [trailer objectForKey:@"Root"];
	PDFIndirectObject *rootObject = [self objectForReference:rootObjectRef];

	PDFObjectReference *pagesRef = [rootObject objectForKey:@"Pages"];
	PDFIndirectObject *pagesObject = [self objectForReference:pagesRef];

	PDFObjectReference *pageRef = [[pagesObject objectForKey:@"Kids"] objectAtIndex:0];
	PDFIndirectObject *pageObject = [self objectForReference:pageRef];
	
	PDFDictionary *hiddenLayerDict = [[pageObject objectForKey:@"Resources"] objectForKey:@"Properties"];
	return [hiddenLayerDict keys];
}

- (BOOL)firstPageContentStreamNeedsInflate;
{
	PDFObjectReference *rootObjectRef = [trailer objectForKey:@"Root"];
	PDFIndirectObject *rootObject = [self objectForReference:rootObjectRef];

	PDFObjectReference *pagesRef = [rootObject objectForKey:@"Pages"];
	PDFIndirectObject *pagesObject = [self objectForReference:pagesRef];

	PDFObjectReference *pageRef = [[pagesObject objectForKey:@"Kids"] objectAtIndex:0];
	PDFIndirectObject *pageObject = [self objectForReference:pageRef];
	
	PDFObjectReference *contentObjectRef = [pageObject objectForKey:@"Contents"];
	PDFIndirectObject *contentObject = [self objectForReference:contentObjectRef];
	
	PDFName *filterName = [contentObject objectForKey:@"Filter"];
	
	return ( filterName ) ? YES : NO;
}

- (int)firstPageObjectNumber;
{
	PDFObjectReference *rootObjectRef = [trailer objectForKey:@"Root"];
	PDFIndirectObject *rootObject = [self objectForReference:rootObjectRef];

	PDFObjectReference *pagesRef = [rootObject objectForKey:@"Pages"];
	PDFIndirectObject *pagesObject = [self objectForReference:pagesRef];

	PDFObjectReference *pageRef = [[pagesObject objectForKey:@"Kids"] objectAtIndex:0];
	
	return [[[pageRef number] nsNumber] intValue];
}

- (int)firstPageGenerationNumber
{
	PDFObjectReference *rootObjectRef = [trailer objectForKey:@"Root"];
	PDFIndirectObject *rootObject = [self objectForReference:rootObjectRef];

	PDFObjectReference *pagesRef = [rootObject objectForKey:@"Pages"];
	PDFIndirectObject *pagesObject = [self objectForReference:pagesRef];

	PDFObjectReference *pageRef = [[pagesObject objectForKey:@"Kids"] objectAtIndex:0];
	
	return [[[pageRef generation] nsNumber] intValue];
}

- (int)contentObjectNumber;
{
	PDFObjectReference *rootObjectRef = [trailer objectForKey:@"Root"];
	PDFIndirectObject *rootObject = [self objectForReference:rootObjectRef];

	PDFObjectReference *pagesRef = [rootObject objectForKey:@"Pages"];
	PDFIndirectObject *pagesObject = [self objectForReference:pagesRef];

	PDFObjectReference *pageRef = [[pagesObject objectForKey:@"Kids"] objectAtIndex:0];
	PDFIndirectObject *pageObject = [self objectForReference:pageRef];
	
	PDFObjectReference *contentObjectRef = [pageObject objectForKey:@"Contents"];
	
	return [[[contentObjectRef number] nsNumber] intValue];
}

- (int)contentGenerationNumber;
{
	PDFObjectReference *rootObjectRef = [trailer objectForKey:@"Root"];
	PDFIndirectObject *rootObject = [self objectForReference:rootObjectRef];

	PDFObjectReference *pagesRef = [rootObject objectForKey:@"Pages"];
	PDFIndirectObject *pagesObject = [self objectForReference:pagesRef];

	PDFObjectReference *pageRef = [[pagesObject objectForKey:@"Kids"] objectAtIndex:0];
	PDFIndirectObject *pageObject = [self objectForReference:pageRef];
	
	PDFObjectReference *contentObjectRef = [pageObject objectForKey:@"Contents"];
	
	return [[[contentObjectRef generation] nsNumber] intValue];
}

- (PDFDictionary *)firstPageDictionaryMutableCopy;
{
	PDFObjectReference *rootObjectRef = [trailer objectForKey:@"Root"];
	PDFIndirectObject *rootObject = [self objectForReference:rootObjectRef];

	PDFObjectReference *pagesRef = [rootObject objectForKey:@"Pages"];
	PDFIndirectObject *pagesObject = [self objectForReference:pagesRef];

	PDFObjectReference *pageRef = [[pagesObject objectForKey:@"Kids"] objectAtIndex:0];
	PDFIndirectObject *pageObject = [self objectForReference:pageRef];
	
	return [[pageObject value] dictionaryCopy];
}

- (int)numberOfObjects;
{
	return [[[trailer size] nsNumber] intValue];
}

- (NSString *)producerAsNSString;
{
	PDFObjectReference *infoRef = [trailer infoObjectReference];
	PDFDictionary *infoDict = [self objectForReference:infoRef];
	PDFString *producer = [infoDict objectForKey:@"Producer"];
	return [producer asNSString]; // assumes /Producer string is in ASCII encoding 
}

- (NSString *)creatorAsNSString;
{
	PDFObjectReference *infoRef = [trailer infoObjectReference];
	PDFDictionary *infoDict = [self objectForReference:infoRef];
	PDFString *creator = [infoDict objectForKey:@"Creator"];
	return [creator asNSString]; // assumes /Creator string is in ASCII encoding
}

@end
