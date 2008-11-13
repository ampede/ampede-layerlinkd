//
//  PDFParsingVisitorProtocol.m
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFParsingVisitorProtocol.h"


@implementation NSObject ( PDFParsingVisitorProtocol )

- (void)
acceptPdfParsingVisitor:(id)theVisitor;
{
	NSLog( @"LayerLink error: object of class %@ does not implement the PDFParsingVisitorProtocol", NSStringFromClass( [self class] ) );
}

@end
