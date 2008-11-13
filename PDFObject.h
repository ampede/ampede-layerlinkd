//
//  PDFObject.h
//  LayerLink
//
//  Created by Eric Ocean on 9/21/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>


// superclass of all PDF classes; implements basic parsing behavior

@class PDFIntegerNumber;

@interface PDFObject : NSObject < NSCopying >
{
	
}

- (void)
findIndirectObjectValuesInArray:(NSArray *)anArray
number:(PDFIntegerNumber **)numP
generation:(PDFIntegerNumber **)genP;

- (void)writeToData:(NSMutableData *)md;

- (id)objectForKey:(NSString *)aKey;
- (id)objectAtIndex:(unsigned)index;

- (id)value;

@end
