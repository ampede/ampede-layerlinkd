//
//  NSMutableArray+StackOperations.m
//  LayerLink
//
//  Created by Eric Ocean on 9/19/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "NSMutableArray+StackOperations.h"


@implementation NSMutableArray ( StackOperations )

- (id)top; { return [self lastObject]; }
- (void)pop; { [self removeLastObject]; }
- (void)push:(id)anObject; { [self addObject:anObject]; }

@end
