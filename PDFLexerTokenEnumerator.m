//
//  PDFLexerTokenEnumerator.m
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFLexerTokenEnumerator.h"
#import "PDFLexer.h"


@implementation PDFLexerTokenEnumerator

- initWithLexer:(PDFLexer *)theLexer;
{	
	if ( self = [super init] ) {
		lexer = theLexer; // weak retain
	}
	return self;
}

- (id)
nextObject;
{
	return [lexer nextToken];
}

@end
