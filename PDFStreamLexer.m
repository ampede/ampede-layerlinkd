//
//  PDFStreamLexer.m
//  LayerLink
//
//  Created by Eric Ocean on 9/23/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "PDFStreamLexer.h"


@implementation PDFStreamLexer

- initWithData:(NSData *)theData;
{
	if ( self = [super initWithData:theData] ) {
		streamFsm = malloc( sizeof( struct PDFStreamParsingMachine ) );
		PDFStreamParsingMachine_init( streamFsm );
		streamFsm->self = self;
	}
	return self;
}

- (void)dealloc;
{
	free( streamFsm );
	[super dealloc];
}

- (int)executeMachineWithBuffer:(unsigned char *)buffer length:(int)length;
{
	return PDFStreamParsingMachine_execute( streamFsm, buffer, length );
}

- (int)finishMachine;
{
	return PDFStreamParsingMachine_finish( streamFsm );
}

@end
