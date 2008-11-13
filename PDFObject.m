//
//  PDFObject.m
//  LayerLink
//
//  Created by Eric Ocean on 9/21/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFObject.h"
#import "PDFIntegerNumber.h"
#import "PDFArray.h"
#import "PDFDictionary.h"


@implementation PDFObject

- (void)
findIndirectObjectValuesInArray:(NSArray *)anArray
number:(PDFIntegerNumber **)numP
generation:(PDFIntegerNumber **)genP;
{
	NSEnumerator *enumerator = [anArray reverseObjectEnumerator];
	id aToken;
	BOOL didNotSetGeneration = YES;
	
	*numP = nil; *genP = nil; // caller expects missing objects to be nil
	
	// note: no validation being done to insure input is correct
	// note: we work from the end of the array back because we want the last two numbers (the array normally contains
	//   all of the tokens encountered by a given parser)
	while ( aToken = [enumerator nextObject] )
	{
		if ( [aToken class] == [PDFIntegerNumber class] )
		{
			// set generation
			if ( didNotSetGeneration )
			{
				didNotSetGeneration = NO;
				*genP = aToken;
			}
			else // set one of the numbers
			{
				*numP = aToken;
				break; // we found what we were looking for
			}
		}
	}
}

- (id)copyWithZone:(NSZone *)aZone;
{
	return [self retain];
}

- (NSString *)quotedStringRepresentation;
{
	return NSStringFromClass( [self class] );
}

- (void)writeToData:(NSMutableData *)md;
{
	[md appendData:[[self description] dataUsingEncoding:NSASCIIStringEncoding]];
}

- (id)objectForKey:(NSString *)aKey;
{
	if ( [[self value] class] == [PDFDictionary class] )
	{
		return [[self value] objectForKey:aKey];
	}
	else return nil;
}

- (id)objectAtIndex:(unsigned)index;
{
	if ( [[self value] class] == [PDFArray class] )
	{
		return [[self value] objectAtIndex:index];
	}
	else return nil;
}

- (id)value;
{
	return nil;
}

@end
