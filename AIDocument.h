//
//  AIDocument.h
//  LayerLink
//
//  Created by Eric Ocean on Tue Jul 13 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PDFDocument.h"


typedef enum {
	kIllustratorVersionUnknown = 0,
	kIllustrator10,
	kIllustratorCS,
	kIllustratorCS2
} IllustratorVersion;

@interface AIDocument : PDFDocument
{
	NSData *fileData;
	NSMutableArray *layers;
	CGPDFDocumentRef pdf;
	CGPDFDictionaryRef catalog;
	CGPDFPageRef page;
	CGPDFDictionaryRef pageDict;
	CGPDFStreamRef stream;
	CGPDFDictionaryRef streamDict;
	NSData *streamData;
	
	NSString *folderName;
	NSString *folderNameWithNumericExtension;
	NSString *folderPath;
	
	int pdfIntegralWidth;
	int pdfIntegralHeight;
	
	IllustratorVersion illustratorVersion;
}

- (void)
generateOzxmlWithHiddenLayers:(NSArray *)hiddenLayers
layerNames:(NSArray *)layerNames;

- (void)
writeLayerData:(NSData *)theData
layer:(int)theLayer;

- (void)
createLayerLinkFolder;

- (void)
setPageDimensions;

- (void)
generateLayerLinkInfo;

- (void)
reloadDataRepresentation:(NSData *)data
ofType:(NSString *)type
withFileName:(NSString *)theFileName
folderPath:(NSString *)theFolderPath
folderName:(NSString *)theFolderName;

- (void)
updateLayerData:(NSData *)theData
layer:(int)theLayer;

- (void)
setIllustratorVersion;

- (PDFDictionary *)
hiddenLayerDictionaryWithName:(PDFName *)aName;

- (NSArray *)csLayerNames;

@end

NSData * NormalizePDFForDisplay( NSData * theData );
