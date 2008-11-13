//
//  PDFName.m
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFName.h"
#import "PDFParsingProtocol.h"


@implementation PDFName

+ nameWithString:(NSString *)theString;
{
	return [[[self alloc] initWithString:theString] autorelease];
}

- initWithString:(NSString *)theString;
{
	if ( self = [super init] ) {
		string = [theString retain];
	}
	return self;
}

- (void)dealloc;
{
	[string release]; string = nil;
	[super dealloc];
}

- (void)acceptPdfParsingVisitor:(id)theVisitor;
{
	[theVisitor handleParsedNameObject:self];
}

- (NSString *)quotedStringRepresentation;
{
	return [string copy];
}

- (NSString *)description;
{
	return [NSString stringWithFormat:@"/%@", string];
}

- (unsigned)hash;
{
	return [string hash];
}

- (BOOL)isEqual:(id)anObject;
{
	return [string isEqualToString:[anObject string]];
}

- (BOOL)boolValue;
{
	return YES; // see AIDocument-Ragel1.rl for usage
}

- (NSString *)string;
{
	return string;
}

- nsNumber;
{
	return nil;
}

@end
