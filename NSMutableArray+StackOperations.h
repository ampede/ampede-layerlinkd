//
//  NSMutableArray+StackOperations.h
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSMutableArray ( StackOperations )

- (id)top;
- (void)pop;
- (void)push:(id)anObject;

@end
