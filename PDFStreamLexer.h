//
//  PDFStreamLexer.h
//  LayerLink
//
//  Created by Eric Ocean on 9/23/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFLexer.h"
#import "PDFStreamLexer-Ragel.h"


@interface PDFStreamLexer : PDFLexer
{
	struct PDFStreamParsingMachine *streamFsm;
}

@end
