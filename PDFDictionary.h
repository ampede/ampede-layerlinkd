//
//  PDFDictionary.h
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFObject.h"


@class PDFParser, PDFName;

@interface PDFDictionary : PDFObject
{
	NSMutableDictionary *dict;
	PDFParser *parser;
	NSMutableArray *tokens;
	BOOL needKey;
	PDFName *pendingKey;
	id numberPending;
}

+ dictionaryWithParser:(PDFParser *)p;
+ dictionary;

- initWithParser:(PDFParser *)p;

- (void)addKey:(id)aKey;
- (void)addObject:(id)anObject;

- (id)objectForKey:(NSString *)aString;

- (NSArray *)keys;

- (PDFDictionary *)dictionaryCopy;

- (NSDictionary *)nsDictionary;

- (int)writeDataLength;

- (void)addEntriesFromDictionary:(NSDictionary *)aDict;

@end
