//
//  PDFString.h
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFObject.h"


@interface PDFString : PDFObject
{
	NSMutableData *data;
}

+ stringWithData:(NSData *)theData;

- initWithData:(NSData *)theData;

- (void)acceptPdfParsingVisitor:(id)theVisitor;

- (NSData *)data;

- (NSString *)asNSString;

@end
