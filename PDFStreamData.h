//
//  PDFStreamData.h
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFObject.h"


@interface PDFStreamData : PDFObject
{
	NSMutableData *data;
}

+ streamDataWithData:(NSData *)theData;

- initWithData:(NSData *)theData;

- (NSData *)data;

@end
