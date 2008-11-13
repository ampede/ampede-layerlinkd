//
//  PDFToken.h
//  LayerLink
//
//  Created by Eric Ocean on Fri Jul 16 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFObject.h"


// This class represents tokens that are not objects themselves, but serve to delimit actual objects

@interface PDFToken : PDFObject
{
	NSString *shortName;
	SEL tokenSelector;
}

+ (id)pdfNull;
+ (id)objectReference;
+ (id)beginIndirectObject;
+ (id)endIndirectObject;
+ (id)beginArray;
+ (id)endArray;
+ (id)beginDict;
+ (id)endDict;
+ (id)beginStream;
+ (id)endStream;
+ (id)xref;
+ (id)trailer;
+ (id)startxref;
+ (id)trailer;
+ (id)startxref;
+ (id)pdfFree;
+ (id)inUse;

- initWithString:(NSString *)aShortName;

// PDFParsingVisitorProtocol
- (void)acceptPdfParsingVisitor:(id)theVisitor;

@end
