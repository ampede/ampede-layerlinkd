//
//  PDFStream.h
//  LayerLink
//
//  Created by Eric Ocean on Thu Jul 15 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFObject.h"


@class PDFDictionary, PDFStreamData, PDFParser;

@interface PDFStream : PDFObject
{
	PDFDictionary *dict;
	PDFStreamData *bytes;
	PDFParser *parser;
}

+ streamWithDictionary:(PDFDictionary *)d parser:(PDFParser *)p;

- initWithDictionary:(PDFDictionary *)d parser:(PDFParser *)p;

- (NSData *)streamData;

@end
