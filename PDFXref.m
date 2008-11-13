//
//  PDFXref.m
//  LayerLink
//
//  Created by Eric Ocean on Thu Jul 15 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFXref.h"
#import "PDFXrefItem.h"
#import "PDFParser.h"
#import "PDFIntegerNumber.h"


@implementation PDFXref

- (void)handleParsedIntegerNumberObject:(PDFIntegerNumber *)theInt;
{
	if ( getFirstLine )
	{
		if ( !firstObject )
		{
			firstObject = [theInt retain];
		}
		else
		{	
			lastObject = [theInt retain];
			getFirstLine = NO;
		}
		return;
	}
	
	if ( !tmpOffsetOrObjectNumber )
	{
		tmpOffsetOrObjectNumber = [theInt retain];
	}
	else
	{	
		tmpGeneration = [theInt retain];
	}
}

- (void)handleParsedObjectFreeToken;
{
	id tmp = [PDFXrefItem
					freeObjectWithNumber:[tmpOffsetOrObjectNumber unsignedIntValue]
					generation:[tmpGeneration unsignedIntValue]];
	[toc addObject:tmp];
	[tmpOffsetOrObjectNumber release]; tmpOffsetOrObjectNumber = nil;
	[tmpGeneration release]; tmpGeneration = nil;
	
	if ( [toc count] == [lastObject unsignedIntValue] )
	{
//		NSLog(@"%@", self);
		[parser popCurrentParser];
	}
}

- (void)handleParsedObjectInUseToken;
{
	id tmp = [PDFXrefItem
					inUseObjectWithOffset:[tmpOffsetOrObjectNumber unsignedIntValue]
					generation:[tmpGeneration unsignedIntValue]];
	[toc addObject:tmp];
	[tmpOffsetOrObjectNumber release]; tmpOffsetOrObjectNumber = nil;
	[tmpGeneration release]; tmpGeneration = nil;
	
	if ( [toc count] == [lastObject unsignedIntValue] )
	{
//		NSLog(@"%@", self);
		[parser popCurrentParser];
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

+ xrefWithParser:(PDFParser *)p;
{
	return [[[self alloc] initWithParser:p] autorelease];
}

- initWithParser:(PDFParser *)p;
{
	if ( self = [super init] ) {
		toc = [[NSMutableArray alloc] initWithCapacity:50];
		parser = p; // weak retain
		getFirstLine = YES;
		firstObject = nil;
		lastObject = nil;
		tmpOffsetOrObjectNumber = nil;
		tmpGeneration = nil;
	}
	return self;
}

- (void)dealloc;
{
	[toc release]; toc = nil;
	[firstObject release]; firstObject = nil;
	[lastObject release]; lastObject = nil;
	parser = nil;
	[super dealloc];
}

- (NSString *)description;
{
	return [NSString stringWithFormat:@"\n\nxref\n%@ %@\n%@\n\n", firstObject, lastObject, [toc componentsJoinedByString:@"\n"]];
}

@end
