//
//  PDFParsingVisitorProtocol.h
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFParsingProtocol.h" // convenience, so other implementors don't have to do it


@interface NSObject ( PDFParsingVisitorProtocol )

- (void)acceptPdfParsingVisitor:(id)theVisitor;

@end
