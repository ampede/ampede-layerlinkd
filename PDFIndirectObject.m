//
//  PDFIndirectObject.m
//  LayerLink
//
//  Created by Eric Ocean on Thu Jul 15 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFIndirectObject.h"
#import "PDFParsingProtocol.h"
#import "PDFArray.h"
#import "PDFBoolean.h"
#import "PDFComment.h"
#import "PDFDictionary.h"
#import "PDFIntegerNumber.h"
#import "PDFName.h"
#import "PDFObjectReference.h"
#import "PDFRealNumber.h"
#import "PDFStream.h"
#import "PDFStreamData.h"
#import "PDFString.h"
#import "PDFNull.h"
#import "PDFParser.h"

#import "LOG_PDFPARSING_CALLBACKS_IMP.h"


@implementation PDFIndirectObject

- (void)handleParsedBooleanObject:(PDFBoolean *)theBoolean;
{
	LOG_PDFPARSING_CALLBACKS_IMP
	[self setValue:theBoolean];
}

- (void)handleParsedIntegerNumberObject:(PDFIntegerNumber *)theInt;
{
	LOG_PDFPARSING_CALLBACKS_IMP
	[self setValue:theInt];
}

- (void)handleParsedRealNumberObject:(PDFRealNumber *)theReal;
{
	LOG_PDFPARSING_CALLBACKS_IMP
	[self setValue:theReal];
}

- (void)handleParsedNameObject:(PDFName *)theName;
{
	LOG_PDFPARSING_CALLBACKS_IMP
	[self setValue:theName];
}

- (void)handleParsedStringObject:(PDFString *)theString;
{
	LOG_PDFPARSING_CALLBACKS_IMP
	[self setValue:theString];
}

- (void)handleParsedPdfNullToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP
	[self setValue:[PDFNull null]];
}

- (void)handleParsedCommentObject:(PDFComment *)theComment;
{
	LOG_PDFPARSING_CALLBACKS_IMP
	[tokens addObject:theComment];
}

////////////// Tokens ///////////////

- (void)handleParsedEndIndirectObjectToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP
//	NSLog(@"\n%@", [self description]);
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
		[self setValue:[PDFObjectReference objectReferenceWithNumber:num generation:gen]];
	}
}

- (void)handleParsedArrayBeginToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	id array = [PDFArray arrayWithParser:parser];
	[self setValue:array];
	[parser pushParser:array];
}

- (void)handleParsedDictionaryBeginToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	id dict = [PDFDictionary dictionaryWithParser:parser];
	[self setValue:dict];
	[parser pushParser:dict];
}

- (void)handleParsedStreamBeginToken;
{
	LOG_PDFPARSING_CALLBACKS_IMP

	// here we replace our previous dictionary value with a stream object (that contains the dictionary)
	id stream = [PDFStream streamWithDictionary:value parser:parser];
	[self setValue:stream];
	[parser pushParser:stream];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// designated initializer
- initWithNumber:(PDFIntegerNumber *)num generation:(PDFIntegerNumber *)gen parser:(PDFParser *)p;
{
	if ( self = [super init] ) {
		number = [num retain];
		generation = [gen retain];
		value = nil;
		tokens = [[NSMutableArray alloc] init];
		parser = p; // weak retain
	}
	return self;
}

- initWithNumber:(PDFIntegerNumber *)num generation:(PDFIntegerNumber *)gen;
{
	return [self initWithNumber:num generation:gen parser:nil];
}

- (void)dealloc;
{
	[number release]; number = nil;
	[generation release]; generation = nil;
	[value release]; value = nil;
	[tokens release]; tokens = nil;
	parser = nil;
	[super dealloc];
}

- (NSString *)description;
{
	return [NSString stringWithFormat:@"\n%@ %@ obj\n%@\n\n", number, generation, value];
}

- (void)setValue:(id)aValue;
{
	[tokens addObject:aValue];
	[value release]; // value can never dissappear on us because it is always held in the tokens dictionary
	value = [aValue retain];
}

- (BOOL)isObjectOfReference:(PDFObjectReference *)ref;
{
	if ( [number isEqual:[ref number]] && [generation isEqual:[ref generation]] ) return YES;
	else return NO;
}

- (id)value;
{
	return value;
}

@end
