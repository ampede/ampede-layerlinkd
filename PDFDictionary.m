//
//  PDFDictionary.m
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFDictionary.h"
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


@implementation PDFDictionary

// no validation is done on input

- (void)handleParsedBooleanObject:(PDFBoolean *)theBoolean;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	[self addObject:theBoolean];
}

- (void)handleParsedIntegerNumberObject:(PDFIntegerNumber *)theInt;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	numberPending = [theInt retain];
	[tokens addObject:theInt];
}

- (void)handleParsedRealNumberObject:(PDFRealNumber *)theReal;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	[self addObject:theReal];
}

- (void)handleParsedNameObject:(PDFName *)theName;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	// this helps to differentiate between numbers making up an object reference
	// and storing a number as a value
	if ( numberPending )
	{
		[self addObject:numberPending];
		[numberPending release]; numberPending = nil;
	}
	
	if ( needKey )
	{
		needKey = NO;
		[self addKey:theName];
	}
	else
	{
		[self addObject:theName];
	}
}

- (void)handleParsedStringObject:(PDFString *)theString;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	[self addObject:theString];
}

- (void)handleParsedPdfNullToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	[tokens addObject:[PDFNull null]];
	[pendingKey release]; pendingKey = nil;
		// we don't register keys with null objects as existing in the dictionary
}

- (void)handleParsedCommentObject:(PDFComment *)theComment;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	// note: don't add to array!
	[tokens addObject:theComment];
}

- (void)handleParsedOperatorObject:(PDFOperator *)op;
{
	LOG_PDFPARSING_CALLBACKS_IMP
	
	[self addObject:op];
}

////////////// Tokens ///////////////

- (void)handleParsedDictionaryEndToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	if ( numberPending )
	{
		[self addObject:numberPending];
		[numberPending release]; numberPending = nil;
	}
	
	[parser popCurrentParser];
}

- (void)handleParsedObjectReferenceToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	PDFIntegerNumber *num = nil;
	PDFIntegerNumber *gen = nil;
	
	[numberPending release]; numberPending = nil; // don't need this anymore
	
	[self	findIndirectObjectValuesInArray:tokens
			number:&num
			generation:&gen];
	
	if ( num && gen ) // aren't nil
	{
		[self addObject:[PDFObjectReference objectReferenceWithNumber:num generation:gen]];
	}
}

- (void)handleParsedArrayBeginToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	id a = [PDFArray arrayWithParser:parser];
	[self addObject:a];
	[parser pushParser:a];
}

- (void)handleParsedDictionaryBeginToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	id d = [PDFDictionary dictionaryWithParser:parser];
	[self addObject:d];
	[parser pushParser:d];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

+ dictionaryWithParser:(PDFParser *)p;
{
	return [[[self alloc] initWithParser:p] autorelease];
}

+ dictionary;
{
	return [self dictionaryWithParser:nil];
}

- initWithParser:(PDFParser *)p;
{
	if ( self = [super init] ) {
		dict = [[NSMutableDictionary alloc] init];
		tokens = [[NSMutableArray alloc] init];
		parser = p; // weak retain
		needKey = YES;
		numberPending = nil;
	}
	return self;
}

- init
{
	return [self initWithParser:nil];
}

- (void)dealloc;
{
	[dict release]; dict = nil;
	[tokens release]; tokens = nil;
	parser = nil;
	[super dealloc];
}

- (void)
addKey:(id)aKey;
{
	pendingKey = [aKey retain];
	[tokens addObject:aKey];
}

- (void)
addObject:(id)anObject;
{
	[dict setObject:anObject forKey:pendingKey];
	needKey = YES;
	[tokens addObject:anObject];
	[pendingKey release]; pendingKey = nil;
}

- (NSString *)description;
{
	NSString *returnString = @"<";
	
	NSEnumerator *enumerator = [dict keyEnumerator];
	id aToken;
	NSEnumerator *enumerator2 = [dict objectEnumerator];
	id aToken2;

	returnString = [returnString stringByAppendingString:@"<"];

	returnString = [returnString stringByAppendingString:@"\n"];

	while ( (aToken = [enumerator nextObject]) && (aToken2 = [enumerator2 nextObject]) )
	{
		NSString *aTokenString = [[aToken description] retain]; // XXX this is a memory leak--REMOVE
		returnString = [returnString stringByAppendingString:aTokenString];

		returnString = [returnString stringByAppendingString:@" "];

		NSString *aToken2String = [[aToken2 description] retain];
		returnString = [returnString stringByAppendingString:aToken2String];
		
		returnString = [returnString stringByAppendingString:@"\n"];
	}

	returnString = [returnString stringByAppendingString:@">>"];

	return returnString;
}

- (void)writeToData:(NSMutableData *)md;
{
	NSEnumerator *enumerator = [dict keyEnumerator];
	PDFObject *aToken;
	NSEnumerator *enumerator2 = [dict objectEnumerator];
	PDFObject *aToken2;
	
	NSData *space = [@" " dataUsingEncoding:NSASCIIStringEncoding];
	NSData *eol = [@"\r" dataUsingEncoding:NSASCIIStringEncoding];

	[md appendData:[@"<<\r" dataUsingEncoding:NSASCIIStringEncoding]];
	
	while ( (aToken = [enumerator nextObject]) && (aToken2 = [enumerator2 nextObject]) )
	{
		[aToken writeToData:md]; [md appendData:space]; [aToken2 writeToData:md]; [md appendData:eol];
	}

	[md appendData:[@">>" dataUsingEncoding:NSASCIIStringEncoding]];
}

- (id)objectForKey:(NSString *)aString;
{ 
	return [dict objectForKey:[PDFName nameWithString:aString]];
}

- (NSArray *)keys;
{
	return [dict allKeys];
}

- (PDFDictionary *)dictionaryCopy;
{
	PDFDictionary *newDict = [[PDFDictionary dictionary] retain];
	
	[newDict addEntriesFromDictionary:dict];
	
	return newDict;
}

- (void)addEntriesFromDictionary:(NSDictionary *)aDict;
{
	[dict addEntriesFromDictionary:aDict];
}

- (NSDictionary *)nsDictionary;
{
	return dict;
}

- (int)writeDataLength;
{
	NSMutableData *tmp = [NSMutableData data];
	
	[self writeToData:tmp];
	
	return [tmp length];
}

@end
