//
//  PDFLexerTokenEnumerator.h
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class PDFLexer;

@interface PDFLexerTokenEnumerator : NSEnumerator
{
	PDFLexer *lexer;
}

- initWithLexer:(PDFLexer *)theLexer;

@end
