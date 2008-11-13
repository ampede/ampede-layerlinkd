//
//  AIDocument-Ragel1.h
//  LayerLink
//
//  Created by Eric Ocean on Wed Jul 14 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "AIDocument.h"


@interface AIDocument (Ragel1)

- (int)locateLayerAfterByte:(int)start;

- (NSArray *)locateLayerStarts;

- (NSArray *)locateHiddenLayers;

@end
