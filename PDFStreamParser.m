//
//  PDFStreamParser.m
//  LayerLink
//
//  Created by Eric Ocean on 9/23/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFStreamParser.h"
#import "PDFParsingProtocol.h"
#import "PDFParser.h"
#import "LOG_PDFPARSING_CALLBACKS_IMP.h"

#import "PDFName.h"


@implementation PDFStreamParser

- (void)handleParsedIntegerNumberObject:(PDFIntegerNumber *)theInt;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	[tokens addObject:theInt];
}

- (void)handleParsedRealNumberObject:(PDFRealNumber *)theReal;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	[tokens addObject:theReal];
}

- (void)handleParsedNameObject:(PDFName *)theName;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	[tokens addObject:theName];
}

- (void)handleParsedStringObject:(PDFString *)theString;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	[tokens addObject:theString];
}

- (void)handleParsedCommentObject:(PDFComment *)theComment;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	[tokens addObject:theComment];
}

- (void)handleParsedOperatorObject:(PDFOperator *)op;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	PDFOperator *newOp = [op nonPaintingEquivalent];
	
	if ( op != newOp )
	{
		[tokens addObject:newOp];
		return;
	}
	
	PDFOperator *containerOp = [op containerOp];
	
	if ( op != containerOp )
	{
		[containerOp setParser:parser];
		[tokens addObject:containerOp];
		[parser pushParser:containerOp];
		return;
	}
	
	if ( ([[op op] isEqualToString:@"Do"]) || ([[op op] isEqualToString:@"sh"]) )
	{
		[tokens removeLastObject]; // a /name object; also, don't add current operator
		return;
	}

	[tokens addObject:op];
}

////////////// Tokens ///////////////

- (void)handleParsedArrayBeginToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	id array = [PDFArray arrayWithParser:parser];
	[tokens addObject:array];
	[parser pushParser:array];
}

- (void)handleParsedDictionaryBeginToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	id dict = [PDFDictionary dictionaryWithParser:parser];
	[tokens addObject:dict];
	[parser pushParser:dict];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- init
{
	if ( self = [super init] ) {
		tokens = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)
dealloc;
{
	[tokens release]; tokens = nil;
	[super dealloc];
}

- (void)setParser:(PDFParser *)theParser;
{
	parser = theParser; // weak retain
}

- (NSString *)description;
{
	return [NSString stringWithFormat:@"token array count is %@", tokens];
	// return [tokens componentsJoinedByString:@", "];
}

- (void)printContents;
{
	NSEnumerator *enumerator = [tokens objectEnumerator];
	PDFObject *aToken;
	NSMutableData *md = [NSMutableData data];
	NSData *eol = [@"\r" dataUsingEncoding:NSASCIIStringEncoding];

	while ( aToken = [enumerator nextObject] )
	{
		[aToken writeToData:md];
		[md appendData:eol];
	}
		
	NSFileHandle *fh = [NSFileHandle fileHandleWithStandardOutput];
	
	[fh writeData:md];
}

- (void)
writeContentsToData:(NSMutableData *)md
upToButNotIncludingLayer:(int)layerNumber;
{
	NSEnumerator *enumerator = [tokens objectEnumerator];
	PDFObject *aToken;
	NSData *eol = [@"\r" dataUsingEncoding:NSASCIIStringEncoding];
	int currentLayer = 0;
	
	PDFName *layerName = [PDFName nameWithString:@"Layer"];

	while ( aToken = [enumerator nextObject] )
	{
		if ( [aToken class] == [layerName class] )
		{
			if ( [aToken isEqual:layerName] )
			{
				currentLayer++;
				if (currentLayer == layerNumber) break;
			}
		}
		[aToken writeToData:md];
		[md appendData:eol];
	}
}

- (NSArray *)layerNames;
{
	NSMutableArray *layerNames = [NSMutableArray array];
	NSEnumerator *enumerator = [tokens objectEnumerator];
	PDFObject *aToken;

	PDFName *layerName = [PDFName nameWithString:@"Layer"];

	while ( aToken = [enumerator nextObject] )
	{
		if ( [aToken class] == [layerName class] )
		{
			if ( [aToken isEqual:layerName] )
			{
				// next object is PDFDictionary
				PDFDictionary *dict = [enumerator nextObject];
				[layerNames addObject:[dict objectForKey:@"Title"]];
			}
		}
	}
	
	return layerNames;
}

@end
