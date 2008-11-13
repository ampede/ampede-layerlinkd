//
//  PDFTrailer.h
//  LayerLink
//
//  Created by Eric Ocean on Thu Jul 15 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFObject.h"


@class PDFDictionary, PDFParser, PDFObjectReference;

@interface PDFTrailer : PDFObject
{
	PDFDictionary *dict;
	PDFParser *parser;
}

+ trailerWithParser:(PDFParser *)p;

- initWithParser:(PDFParser *)p;

- (PDFIntegerNumber *)size;

- (id)objectForKey:(NSString *)aString;

- (PDFObjectReference *)infoObjectReference;

@end
