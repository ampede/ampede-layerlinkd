//
//  PDFArray.m
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFArray.h"
#import "PDFParser.h"

#import "PDFBoolean.h"
#import "PDFComment.h"
#import "PDFDictionary.h"
#import "PDFIndirectObject.h"
#import "PDFIntegerNumber.h"
#import "PDFName.h"
#import "PDFObjectReference.h"
#import "PDFRealNumber.h"
#import "PDFStream.h"
#import "PDFStreamData.h"
#import "PDFString.h"
#import "PDFToken.h"
#import "PDFTrailer.h"
#import "PDFXref.h"
#import "PDFXrefItem.h"
#import "PDFNull.h"

#import "LOG_PDFPARSING_CALLBACKS_IMP.h"


@implementation PDFArray

- (void)handleParsedBooleanObject:(PDFBoolean *)theBoolean;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	if ( [numberBuffer count] ) [self emptyNumberBuffer];

	[self addObject:theBoolean];
}

- (void)handleParsedIntegerNumberObject:(PDFIntegerNumber *)theInt;
{
	LOG_PDFPARSING_CALLBACKS_IMP
	
	[tokens addObject:theInt];

	// keep at most two objects in the buffer
	if ( [numberBuffer count] == 2 )
	{
		id obj = [[[numberBuffer objectAtIndex:0] retain] autorelease];
		[numberBuffer removeObjectAtIndex:0];
		[self addObjectWithoutAddingToken:obj]; // we added it ourselves above
	}
	[numberBuffer addObject:theInt];
	
	// handleParsedObjectReferenceToken below clears the numberBuffer
}

- (void)handleParsedRealNumberObject:(PDFRealNumber *)theReal;
{
	LOG_PDFPARSING_CALLBACKS_IMP
	
	if ( [numberBuffer count] ) [self emptyNumberBuffer];

	[self addObject:theReal];
}

- (void)handleParsedNameObject:(PDFName *)theName;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	if ( [numberBuffer count] ) [self emptyNumberBuffer];

	[self addObject:theName];
}

- (void)handleParsedStringObject:(PDFString *)theString;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	if ( [numberBuffer count] ) [self emptyNumberBuffer];

	[self addObject:theString];
}

- (void)handleParsedPdfNullToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	if ( [numberBuffer count] ) [self emptyNumberBuffer];

	[self addObject:[PDFNull null]];
}

- (void)handleParsedCommentObject:(PDFComment *)theComment;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	if ( [numberBuffer count] ) [self emptyNumberBuffer];

	// note: don't add to array!
	[tokens addObject:theComment];
}

////////////// Tokens ///////////////

- (void)handleParsedArrayEndToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	if ( [numberBuffer count] ) [self emptyNumberBuffer];

	[parser popCurrentParser];
}

- (void)handleParsedObjectReferenceToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	PDFIntegerNumber *num = nil;
	PDFIntegerNumber *gen = nil;
	
	[self	findIndirectObjectValuesInArray:tokens
			number:&num
			generation:&gen];
	
	if ( num && gen ) // aren't nil
	{
		[self addObject:[PDFObjectReference objectReferenceWithNumber:num generation:gen]];
	}
	
	[numberBuffer removeAllObjects];
}

- (void)handleParsedArrayBeginToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	if ( [numberBuffer count] ) [self emptyNumberBuffer];

	id a = [PDFArray arrayWithParser:parser];
	[self addObject:a];
	[parser pushParser:a];
}

- (void)handleParsedDictionaryBeginToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	if ( [numberBuffer count] ) [self emptyNumberBuffer];

	id dict = [PDFDictionary dictionaryWithParser:parser];
	[self addObject:dict];
	[parser pushParser:dict];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

+ arrayWithParser:(PDFParser *)p;
{
	return [[[self alloc] initWithParser:p] autorelease];
}

+ array;
{
	return [self arrayWithParser:nil];
}

- initWithParser:(PDFParser *)p;
{
	if ( self = [super init] ) {
		array = [[NSMutableArray alloc] init];
		tokens = [[NSMutableArray alloc] init];
		numberBuffer = [[NSMutableArray alloc] init];
		parser = p; // weak retain
	}
	return self;
}

- init
{
	return [self initWithParser:nil];
}

- (void)dealloc;
{
	[array release]; array = nil;
	[tokens release]; tokens = nil;
	[numberBuffer release]; numberBuffer = nil;
	parser = nil;
	[super dealloc];
}

- (void)
addObject:(id)anObject;
{
	[array addObject:anObject];
	[tokens addObject:anObject];
}

- (void)
addObjectWithoutAddingToken:(id)anObject;
{
	[array addObject:anObject];
}

- (NSString *)description;
{
	NSString *returnString = @"[";
	
	NSEnumerator *enumerator = [array objectEnumerator];
	id aToken;

	returnString = [returnString stringByAppendingString:@" "];

	while ( aToken = [enumerator nextObject] )
	{
		NSString *aTokenString = [[aToken description] retain];
		returnString = [returnString stringByAppendingString:aTokenString];

		returnString = [returnString stringByAppendingString:@" "];
	}

	returnString = [returnString stringByAppendingString:@"]"];

	return returnString;
}

- (void)emptyNumberBuffer;
{
	int cnt = [numberBuffer count];
	
	if ( cnt == 1 )
	{
		id obj1 = [numberBuffer objectAtIndex:0];
		[self addObject:obj1];
	}
	else if ( cnt == 2 )
	{
		id obj1 = [numberBuffer objectAtIndex:0];
		id obj2 = [numberBuffer objectAtIndex:1];
		[self addObject:obj1];
		[self addObject:obj2];
	}
	[numberBuffer removeAllObjects];
}

- (id)objectAtIndex:(unsigned)index;
{
	return [array objectAtIndex:index];
}

@end
