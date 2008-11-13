//
//  PDFName.h
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFObject.h"


@interface PDFName : PDFObject
{
	NSString *string;
}

+ nameWithString:(NSString *)theString;

- initWithString:(NSString *)theString;

- (void)acceptPdfParsingVisitor:(id)theVisitor;

- (BOOL)boolValue;

- (NSString *)string;

@end
