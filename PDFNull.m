//
//  PDFNull.m
//  LayerLink
//
//  Created by Eric Ocean on 9/21/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFNull.h"


@implementation PDFNull

+ null;
{
	static PDFNull *nullObject = nil;
	static BOOL doneOnce = NO;
	
	if ( doneOnce ) return nullObject;
	else
	{
		nullObject = [self alloc]; // don't initialize (there are no ivars anyway, and super is already set)
		doneOnce = YES;
		return nullObject;
	}
}

- init
{
	// can't create instances of PDFNull
	exit(111);
	return nil; // keep compiler happy
}

- (id)retain;
{
	return self; // singleton is immutable
}

- (oneway void)release;
{
	; // can't delete singleton instance
}

- (NSString *)description;
{
	return @"null";
}

@end
