//
//  PDFBoolean.h
//  LayerLink
//
//  Created by Eric Ocean on Thu Jul 15 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFObject.h"


@interface PDFBoolean : PDFObject
{
	BOOL value;
}

+ (PDFBoolean *)booleanWithBool:(BOOL)boolValue;

- initWithBool:(BOOL)boolValue;

- (BOOL)value;

@end
