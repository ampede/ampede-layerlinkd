//
//  PDFBoolean.m
//  LayerLink
//
//  Created by Eric Ocean on Thu Jul 15 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFBoolean.h"
#import "PDFParsingProtocol.h"


@implementation PDFBoolean

+ (PDFBoolean *)booleanWithBool:(BOOL)boolValue;
{
	return [[[self alloc] initWithBool:boolValue] autorelease];
}

- initWithBool:(BOOL)boolValue;
{
	if ( self = [super init] ) {
		value = boolValue;
	}
	return self;
}

- (BOOL)value; { return value; }

- (void)acceptPdfParsingVisitor:(id)theVisitor;
{
	[theVisitor handleParsedBooleanObject:self];
}

- (NSString *)description;
{
	return (value) ? @"true" : @"false";
}

@end
