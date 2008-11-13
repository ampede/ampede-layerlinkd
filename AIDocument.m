//
//  AIDocument.m
//  LayerLink
//
//  Created by Eric Ocean on Tue Jul 13 2004.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "LayerLink.h"

#import "AIDocument.h"
#import "AIDocument-Ragel.h"
#import "AIDocument-Ragel1.h"
#import "AIDocument-Ragel2.h"
#import "AIDocument-Ragel3.h"
#import "AIDocument-Ragel4.h"

#import "PDFTrailer.h"
#import "PDFIntegerNumber.h"
#import "PDFStreamParser.h"
#import "PDFParser.h"
#import "PDFName.h"
#import "PDFDictionary.h"

#import "ozxml.h"

#import "BDAlias.h"
#import "UKKQueue.h"

#ifdef LICENSING_CONTROL_ON
#import <LicenseControl/DetermineOpMode.h>
#endif

#ifndef LICENSING_CONTROL_ON
	#warning LicenseControl NOT ENABLED
#endif

#import "grid_lines.h"

#import <zlib.h>

// Replace characters with basic entities (from OmniFoundation _OFXMLCreateStringWithEntityReferences)
static NSString *
CreateXMLStringWithEntityReferences(
		NSString *sourceString
	)
{
    CFStringInlineBuffer charBuffer;
    CFIndex charIndex, charCount = CFStringGetLength((CFStringRef)sourceString);
    CFStringInitInlineBuffer((CFStringRef)sourceString, &charBuffer, (CFRange){0, charCount});

    CFMutableStringRef result = CFStringCreateMutable(kCFAllocatorDefault, 0);

    for (charIndex = 0; charIndex < charCount; charIndex++) {
        unichar c = CFStringGetCharacterFromInlineBuffer(&charBuffer, charIndex);
        if (c == '&') {
            CFStringAppend(result, (CFStringRef)@"&amp;");
        } else if (c == '<') {
            CFStringAppend(result, (CFStringRef)@"&lt;");
        } else if (c == '\"') {
            CFStringAppend(result, (CFStringRef)@"&quot;");
        } else if (c == '\'') {
            CFStringAppend(result, (CFStringRef)@"&apos;");
        } else if (c == '\'') {
            CFStringAppend(result, (CFStringRef)@"&#39;");
        } else if (c == '>') {
            CFStringAppend(result, (CFStringRef)@"&gt;");
        } else
            CFStringAppendCharacters(result, &c, 1);
    }

    return (NSString *)result;
}

@implementation AIDocument

- init
{
	if ( self = [super init] ) {
		layers = [[NSMutableArray alloc] init];
		folderName = nil;
		folderNameWithNumericExtension = nil;
		folderPath = nil;
		pdfIntegralWidth = 0;
		pdfIntegralHeight = 0;
	}
	return self;
}

- (void)
dealloc;
{
	[layers release]; layers = nil;
	[fileData release]; fileData = nil;
	[folderName release]; folderName = nil;
	[folderNameWithNumericExtension release]; folderNameWithNumericExtension = nil;
	[folderPath release]; folderPath = nil;
	[super dealloc];
}

- (NSString *)
windowNibName
{
    // Implement this to return a nib to load OR implement -makeWindowControllers to manually create your controllers.
    return nil; // @"PDFLayerViewer";
}

- (NSData *)
dataRepresentationOfType:(NSString *)type
{
    // Implement to provide a persistent data representation of your document OR remove this and implement the
	// file-wrapper or file path based save methods.
    return nil;
}

#define CHECK_ERR(err, msg) { \
    if (err != Z_OK) { \
        fprintf(stderr, "%s error: %d\n", msg, err); \
        exit(1); \
    } \
}

- (BOOL)
loadDataRepresentation:(NSData *)data
ofType:(NSString *)type
{
	[super loadDataRepresentation:data ofType:type];
	
#ifdef LICENSING_CONTROL_ON
	if ( OpModeLicensed != licensingLevelCheck().opMode )
	{
		return NO;
	}
#endif

	fileData = [data retain];
	
	pdf = CGPDFDocumentCreateWithURL(   CFURLCreateWithFileSystemPath(	kCFAllocatorDefault,
																		(CFStringRef)[self fileName],
																		kCFURLPOSIXPathStyle,
																		NO  )   );
	
	catalog = CGPDFDocumentGetCatalog( pdf ); CFRetain( catalog );
	page = CGPDFDocumentGetPage( pdf , 1 ); // AI documents only have one page
	pageDict = CGPDFPageGetDictionary( page );
	
	const char *keyName = "Contents";
	BOOL gotStream = NO;
	gotStream = CGPDFDictionaryGetStream( pageDict, keyName, &stream );
	
	if ( gotStream )
	{
		CGPDFDataFormat format;
		streamDict = CGPDFStreamGetDictionary( stream );
		streamData = (NSData *)CGPDFStreamCopyData( stream, &format );
	}
	else NSLog(@"LayerLink error: could not get page content stream.");
	
	// handle FlateDecode here
	if ( [self firstPageContentStreamNeedsInflate] )
	{
		NSMutableData *inflatedStream = [NSMutableData dataWithLength:4096];
		
		//////// taken from example.c, test_large_inflate() in the zlib source distribution
		Byte *compr = (Byte *)[streamData bytes];
		Byte *uncompr = (Byte *)[inflatedStream mutableBytes];
		uLong comprLen = [streamData length];
		uLong uncomprLen = [inflatedStream length];

		int err;
		z_stream d_stream; /* decompression stream */

//		strcpy((char*)uncompr, "garbage");

		d_stream.zalloc = (alloc_func)0;
		d_stream.zfree = (free_func)0;
		d_stream.opaque = (voidpf)0;

		d_stream.next_in  = compr;
		d_stream.avail_in = (uInt)comprLen;

		err = inflateInit(&d_stream);
		CHECK_ERR(err, "LayerLink error: problem with inflateInit");

		for (;;) {
			d_stream.next_out = uncompr;
			d_stream.avail_out = (uInt)uncomprLen;
//			err = inflate(&d_stream, Z_NO_FLUSH);
			err = inflate(&d_stream, Z_SYNC_FLUSH); // changed by Eric Ocean
			if (err == Z_STREAM_END) break;
			// new code from Eric Ocean follows
			else if (err == Z_BUF_ERROR || ((err == Z_OK) && (d_stream.avail_out == 0)))
			{
				// we need to allocate more buffer space
				uncompr = (Byte *)([inflatedStream mutableBytes] + [inflatedStream length]);
				[inflatedStream setLength:([inflatedStream length] + 4096)]; // gives us more space
				// don't need to change uncomprLen, it's already set to 4096
				continue;
			}
			// end new code
			CHECK_ERR(err, "LayerLink error: problem with inflate");
		}

		// new code from Eric Ocean follows
		[inflatedStream setLength:d_stream.total_out]; // truncate allocated buffer to fit
		// end new code
		
		err = inflateEnd(&d_stream);
		CHECK_ERR(err, "LayerLink error: problem with inflateEnd");

//		if (d_stream.total_out != 2*uncomprLen + comprLen/2) {
//			fprintf(stderr, "bad large inflate: %ld\n", d_stream.total_out);
//			exit(1);
//		} else {
//			printf("large_inflate(): OK\n");
//		}
		//////// end example.c code
		
		streamData = inflatedStream;
	}
	
	// end handle FlateDecode
		
	PDFStreamParser *transformedStream = [[PDFStreamParser alloc] init];
	PDFParser *streamParser = [[PDFParser alloc] initWithData:streamData forDocument:(PDFDocument *)transformedStream];

	[streamParser parseStream];

	/////////////////// Create LayerLink folder //////////////////
	
	[self createLayerLinkFolder];
	
	/////////////////// Calculate integral page dimensions //////////////////
	
	[self setPageDimensions];
	
	/////////////////// Calculate Illustrator Version //////////////////
	
	[self setIllustratorVersion];
	
	/////////////////// Break up input into layers //////////////////
	
	NSArray *layerStarts = [[self locateLayerStarts] retain];
//	NSLog(@"layer starts: %@", layerStarts);
	
	/////////////////// Get layer data //////////////////
	
	NSMutableArray *layerData = [[NSMutableArray array] retain];
	
	NSEnumerator *enumerator = [layerStarts objectEnumerator];
	NSNumber *aNumber;
	int lastLocation = [[enumerator nextObject] intValue];
	
	while ( aNumber = [enumerator nextObject] )
	{
		NSData *ld = [NSData	dataWithBytes:([streamData bytes]+lastLocation)
								length:([aNumber intValue]-lastLocation)];
		[layerData addObject:ld];
		lastLocation = [aNumber intValue];
	}
	
	NSData *ld = [NSData	dataWithBytes:([streamData bytes]+lastLocation)
							length:([streamData length] - lastLocation)];
	[layerData addObject:ld];

//	NSLog(@"layer data is: %@", layerData);
	
	/////////////////// Locate hidden layers //////////////////
	NSMutableArray *hiddenLayers = hiddenLayers = (NSMutableArray *)[self locateHiddenLayers];
		
	if ( [hiddenLayers count] < [layerData count] ) [hiddenLayers addObject:[NSNumber numberWithBool:NO]];
		// locateHiddenLayers doesn't capture the last layer if it's not hidden, and I was too lazy to redesign it

//	NSLog(@"hidden layers are: %@", hiddenLayers);
	
	/////////////////// Main PDF Generation Loop //////////////////
	
	NSEnumerator *layerDataEnum = [layerData objectEnumerator];
	NSEnumerator *hiddenLayersEnum = [hiddenLayers objectEnumerator];
	
	id layerStreamData;
	id hiddenLayerBooleanOrName;
	
	// create page object data
	int pageObjectNum = [self firstPageObjectNumber];
	int pageGenerationNum = [self firstPageGenerationNumber];
	NSString *pageObjectString = [NSString stringWithFormat:@"%d %d obj\r",
										pageObjectNum, pageGenerationNum];

	NSData *pageObjectData = [pageObjectString dataUsingEncoding:NSASCIIStringEncoding];
	
	// create content object data
	int contentObjectNum = [self contentObjectNumber];
	int contentGenerationNum = [self contentGenerationNumber];
	NSString *contentObjectString = [NSString stringWithFormat:@"%d %d obj\r<<\r/Length ",
										contentObjectNum, contentGenerationNum];

	NSData *contentObjectData = [contentObjectString dataUsingEncoding:NSASCIIStringEncoding];
	
	// create end object data
	NSString *endObjectString = @"endstream\rendobject\r";
	NSData *endObjectData = [endObjectString dataUsingEncoding:NSASCIIStringEncoding];
	
	int currentLayer = 0;
	
	while	(
				( layerStreamData = [layerDataEnum nextObject] ) &&
				( hiddenLayerBooleanOrName = [hiddenLayersEnum nextObject] )
			)
	{
		int pageObjectLocation = 0;
		currentLayer++;
		
		// create new PDF file data
		NSMutableData *layerFileData = [NSMutableData data];
		
		// append original file
		[layerFileData appendData:fileData];
		
		if ( [hiddenLayerBooleanOrName boolValue] )
		{
			///////////// Need to update page object here /////////////
			pageObjectLocation = [layerFileData length];
			
			PDFDictionary *newPage = [self firstPageDictionaryMutableCopy];
			PDFDictionary *contentDictionary = [self hiddenLayerDictionaryWithName:hiddenLayerBooleanOrName];
			
			[newPage addEntriesFromDictionary:[contentDictionary nsDictionary]];
			
			// new page has now been updated with the values from the hidden layer's dictionary
			
			// append object header (part 1)
			[layerFileData appendData:pageObjectData];
			
			// append object contents
			[newPage writeToData:layerFileData];
			
			// append end object
			NSString *endPageString = @"\rendobject\r";
			NSData *endPageData = [endPageString dataUsingEncoding:NSASCIIStringEncoding];
			[layerFileData appendData:endPageData];
		}
		else
		{
			// append object header (part 1)
			[layerFileData appendData:contentObjectData];
			
			// layer isn't hidden, hiddenLayerBooleanOrName is NSNumber (CFBoolean) object
			// layerStreamData is the data we want to write to the stream, after we've written
			// any necessary transformed prior layers
			NSMutableData *tmpStream = [NSMutableData data];
			[transformedStream writeContentsToData:tmpStream upToButNotIncludingLayer:currentLayer];
			[tmpStream appendData:layerStreamData];
			
			// append stream data length
			NSString *layerLengthString = [NSString stringWithFormat:@"%d\r>>\rstream\r\n", [tmpStream length]];
			NSData *layerLengthData = [layerLengthString dataUsingEncoding:NSASCIIStringEncoding];
			
			[layerFileData appendData:layerLengthData];
			
			// append stream data
			[layerFileData appendData:tmpStream];

			// append endstream, endobject lines
			[layerFileData appendData:endObjectData];
		}
		
		int xref_location = [layerFileData length];
		
		[layerFileData appendData:[@"xref\r0 1\r0000000000 65535 f \r" dataUsingEncoding:NSASCIIStringEncoding]];

		if ( [hiddenLayerBooleanOrName boolValue] )
		{
			// add page object entry
			NSString *xrefString3 = [NSString stringWithFormat:@"%d 1\r%010d %05d n \r",
														pageObjectNum,
														pageObjectLocation,
														pageGenerationNum];
												
			[layerFileData appendData:[xrefString3 dataUsingEncoding:NSASCIIStringEncoding]];
		}
		else
		{
			// add content object entry
			NSString *xrefString2 = [NSString stringWithFormat:@"%d 1\r%010d %05d n \r",
														contentObjectNum,
														[fileData length], // i.e. contentObjectLocation
														contentGenerationNum];
												
			[layerFileData appendData:[xrefString2 dataUsingEncoding:NSASCIIStringEncoding]];
		}
		
		// this should be changed to account for /Root at other object numbers
		NSString *trailerString = [NSString stringWithFormat:@"trailer\r<<\r/Size %d\r/Root 1 0 R\r/Prev %d\r>>\r",
											[self numberOfObjects],
											startxref];
		
		[layerFileData appendData:[trailerString dataUsingEncoding:NSASCIIStringEncoding]];


		NSString *endString = [NSString stringWithFormat:@"startxref\r%d\r", xref_location]; 
		[layerFileData appendData:[endString dataUsingEncoding:NSASCIIStringEncoding]];
		
		
		NSString *eolString = [@"\x25\x25" stringByAppendingString:@"EOF\r"]; 
		[layerFileData appendData:[eolString dataUsingEncoding:NSASCIIStringEncoding]];
		
		// now it's time to write the data out to a file
		[self writeLayerData:layerFileData layer:currentLayer];
	}
	
	NSArray *layerNames = nil;
	
	if ( illustratorVersion == kIllustrator10 ) layerNames = [transformedStream layerNames];
	else if ( illustratorVersion == kIllustratorCS || illustratorVersion == kIllustratorCS2 ) {
		layerNames = [self csLayerNames];
	}
	
	if ( layerNames ) [self generateOzxmlWithHiddenLayers:hiddenLayers layerNames:layerNames];
	
	[self generateLayerLinkInfo];
	
	[[NSApp delegate] addLayerLinkFolder:folderNameWithNumericExtension];
	
    return NO;
}

- (void)
generateLayerLinkInfo;
{
	BDAlias *alias = [BDAlias aliasWithPath:[self fileName]];
	NSData *aliasData = [alias aliasData];
	NSMutableDictionary *info = [NSMutableDictionary dictionary];
	[info setObject:aliasData forKey:@"aliasData"];
	[info	setObject:[[NSFileManager defaultManager] fileAttributesAtPath:[self fileName] traverseLink:YES]
			forKey:@"fileAttributes"];
			
	[info setObject:folderName forKey:@"baseName"];
			
	NSString *error = nil;
	NSData *plistData = [NSPropertyListSerialization	dataFromPropertyList:info
														format:NSPropertyListXMLFormat_v1_0
														errorDescription:&error];
	if (error)
	{
		NSLog(@"LayerLink error: layerlink.info file is corrupt. Reason: %@.", error);
		[error release];
	}
	
	[plistData writeToFile:[NSString stringWithFormat:@"%@/layerlink.info", folderPath] atomically:YES];
	
//	NSLog(@"wrote layerlink.info file");
}

- (void)
generateOzxmlWithHiddenLayers:(NSArray *)hiddenLayers
layerNames:(NSArray *)layerNames;
{
	NSEnumerator *hiddenLayerEnumerator = [hiddenLayers reverseObjectEnumerator];
	NSEnumerator *layerNamesEnumerator = [layerNames reverseObjectEnumerator];
	
	NSMutableData *xmlData = [NSMutableData dataWithCapacity:4096];
	
//	#warning file paths are incorrect for a shipping application
//	NSData *preamble	= [NSData dataWithContentsOfFile:@"/Users/bizman/LayerLink/OZXML/1 static preamble"];
	NSData *preamble = [NSData	dataWithBytesNoCopy:_1_static_preamble
								length:_1_static_preamble_length
								freeWhenDone:NO];

//	NSData *middle		= [NSData dataWithContentsOfFile:@"/Users/bizman/LayerLink/OZXML/6 static middle"];
/*	NSData *middle = [NSData	dataWithBytesNoCopy:_6_static_middle
								length:_6_static_middle_length
								freeWhenDone:NO];
*/
//	NSData *postamble	= [NSData dataWithContentsOfFile:@"/Users/bizman/LayerLink/OZXML/11 static postamble"];
	NSData *postamble = [NSData	dataWithBytesNoCopy:_11_static_postamble
								length:_11_static_postamble_length
								freeWhenDone:NO];

	
	[xmlData appendData:preamble];
	
	///////////////////// do layer loop /////////////////////
	
//	NSData *layer1		= [NSData dataWithContentsOfFile:@"/Users/bizman/LayerLink/OZXML/3a repeat layer static 1"];
	NSData *layer1 = [NSData	dataWithBytesNoCopy:_3a_repeat_layer_static_1
								length:_3a_repeat_layer_static_1_length
								freeWhenDone:NO];
								
//	NSData *layer2		= [NSData dataWithContentsOfFile:@"/Users/bizman/LayerLink/OZXML/3b repeat layer static 1"];
	NSData *layer2 = [NSData	dataWithBytesNoCopy:_3b_repeat_layer_static_1
								length:_3b_repeat_layer_static_1_length
								freeWhenDone:NO];
								
//	NSData *layer3		= [NSData dataWithContentsOfFile:@"/Users/bizman/LayerLink/OZXML/5 repeat layer static 2"];
	NSData *layer3 = [NSData	dataWithBytesNoCopy:_5_repeat_layer_static_2
								length:_5_repeat_layer_static_2_length
								freeWhenDone:NO];

	id hiddenToken = nil;
	id nameToken = nil;
	id xmlNameToken = nil;
	int layerId = 10000;
	int scenenodeId = 20000;
	int clipId = 30000;
	int audioLayerID = 0;
	int masterID = 0;
	
	int theLayer = [hiddenLayers count];
	
	while ( (hiddenToken = [hiddenLayerEnumerator nextObject]) && (nameToken = [layerNamesEnumerator nextObject]) ) {
		layerId++; // must be 10001, 10000 is used in the static xml for the footage id
		scenenodeId++;
		clipId++;
		
		// from "2 repate layer insert 1"
		NSString *insert1 = @"\t<layer name=\"";
		NSString *insert3 = [NSString stringWithFormat:@"\" id=\"%d\">\n", layerId];
		NSString *insert4 = [NSString stringWithFormat:
									@"\t\t<scenenode name=\"%@\" id=\"%d\" factoryID=\"1\">\n",
									[[NSString stringWithFormat:@"%@/%@ (Layer %d).ai", folderPath, folderName, theLayer] lastPathComponent],
									scenenodeId];
									
		[xmlData appendData:[insert1 dataUsingEncoding:NSASCIIStringEncoding]];

		
		// the nameToken needs to be sanitized for XML first; I got code to do this from OmniFoundation/XML
		xmlNameToken = CreateXMLStringWithEntityReferences([nameToken asNSString]);
		[xmlData appendData:[xmlNameToken dataUsingEncoding:NSASCIIStringEncoding]];
		[xmlNameToken release]; // avoid a memory leak
		
		[xmlData appendData:[insert3 dataUsingEncoding:NSASCIIStringEncoding]];
		[xmlData appendData:[insert4 dataUsingEncoding:NSASCIIStringEncoding]];
		
		[xmlData appendData:layer1];
		
		if ( [hiddenToken boolValue] )
		{
			NSString *hiddenString = @"\t\t\t<enabled>0</enabled>\n";
			[xmlData appendData:[hiddenString dataUsingEncoding:NSASCIIStringEncoding]];
		}
		
		[xmlData appendData:layer2];
		
		// from "4 repeat layer insert 2"
		NSString *insert7 = [NSString stringWithFormat:
											@"\t\t\t\t<parameter name=\"Media\" id=\"300\" flags=\"16\" value=\"%d\"/>\n",
											clipId];
		
		[xmlData appendData:[insert7 dataUsingEncoding:NSASCIIStringEncoding]];
		
		[xmlData appendData:layer3];
		
		theLayer--; // we work from the top layer to the bottom
	}
	
    	// TODO: Need to modify this to use the layerId++ for the <audio id=" "> tag, and then layerId++ for the nested
    	// <scenenode id=" "> tag. Right now, if more than 12 layers are generated, Motion will crash

    //	[xmlData appendData:middle];

    	layerId++; // I'm not sure why this is necessary, but the results required it
    	audioLayerID = layerId++;
    	masterID = layerId++;

    	[xmlData appendData:[
    			[NSString stringWithFormat:@"\n\t<audio name=\"audio layer\" id=\"%d\">\n\t\t<scenenode name=\"Master\" id=\"%d\" factoryID=\"2\">\n\t\t\t<flags>0</flags>\n\t\t\t<timing in=\"0\" out=\"300\" offset=\"0\"/>\n\t\t\t<foldFlags>0</foldFlags>\n\t\t\t<baseFlags>524304</baseFlags>\n\t\t\t<parameter name=\"Properties\" id=\"1\" flags=\"4112\"/>\n\t\t\t<parameter name=\"Object\" id=\"2\" flags=\"4112\">\n\t\t\t\t<parameter name=\"Mute\" id=\"100\" flags=\"18\" value=\"0\"/>\n\t\t\t\t<parameter name=\"Level\" id=\"101\" flags=\"25165840\" value=\"1\"/>\n\t\t\t\t<parameter name=\"Pan\" id=\"102\" flags=\"16777232\" value=\"0\"/>\n\t\t\t</parameter>\n\t\t</scenenode>\n\t\t<flags>0</flags>\n\t\t<timing in=\"0\" out=\"-1\" offset=\"0\"/>\n\t\t<foldFlags>0</foldFlags>\n\t\t<baseFlags>524304</baseFlags>\n\t\t<parameter name=\"Properties\" id=\"1\" flags=\"4112\"/>\n\t\t<parameter name=\"Object\" id=\"2\" flags=\"4112\"/>\n\t</audio>\n\n\t<footage name=\"Footage Layer\" id=\"10000\">\n\n", audioLayerID, masterID]
    			dataUsingEncoding:NSASCIIStringEncoding]];
	
	///////////////////// do clip loop /////////////////////
	
//	NSData *layer4		= [NSData dataWithContentsOfFile:@"/Users/bizman/LayerLink/OZXML/8 repeat clip static 1"];
	NSData *layer4 = [NSData	dataWithBytesNoCopy:_8_repeat_clip_static_1
								length:_8_repeat_clip_static_1_length
								freeWhenDone:NO];

//	NSData *layer5		= [NSData dataWithContentsOfFile:@"/Users/bizman/LayerLink/OZXML/10 repeat clip static 2"];
	NSData *layer5 = [NSData	dataWithBytesNoCopy:_10_repeat_clip_static_2
								length:_10_repeat_clip_static_2_length
								freeWhenDone:NO];


	theLayer = [hiddenLayers count];
	clipId = 30000;

	while ( theLayer != 0 ) {
		clipId++;
		
		// from "2 repate layer insert 1"
		NSString *insert1 = [NSString stringWithFormat:
									@"\t\t<clip name=\"%@\" id=\"%d\">\n",
									[[NSString stringWithFormat:@"%@/%@ (Layer %d).ai", folderPath, folderName, theLayer] lastPathComponent],
									clipId];
		NSURL *tmpURL = [NSURL fileURLWithPath:
									[NSString stringWithFormat:@"%@/%@ (Layer %d).ai", folderPath, folderName, theLayer]];
		NSString *insert2 = [NSString stringWithFormat:
									@"\t\t\t<pathURL>%@</pathURL>\n",
									[tmpURL absoluteString]];
		NSString *insert3 = [NSString stringWithFormat:
									@"\t\t\t<missingWidth>%d</missingWidth>\n\t\t\t<missingHeight>%d</missingHeight>\n",
									pdfIntegralWidth,
									pdfIntegralHeight];
									
		[xmlData appendData:[insert1 dataUsingEncoding:NSASCIIStringEncoding]];
		[xmlData appendData:[insert2 dataUsingEncoding:NSASCIIStringEncoding]];
		[xmlData appendData:[insert3 dataUsingEncoding:NSASCIIStringEncoding]];
		
		[xmlData appendData:layer4];
		
		NSString *insert5 = [NSString stringWithFormat:
									@"\t\t\t<parameter name=\"Fixed Width\" id=\"114\" flags=\"0\" value=\"%d\"/>\n",
									pdfIntegralWidth];
		NSString *insert6 = [NSString stringWithFormat:
									@"\t\t\t<parameter name=\"Fixed Height\" id=\"115\" flags=\"0\" value=\"%d\"/>\n",
									pdfIntegralHeight];
		
		[xmlData appendData:[insert5 dataUsingEncoding:NSASCIIStringEncoding]];
		[xmlData appendData:[insert6 dataUsingEncoding:NSASCIIStringEncoding]];
		
		[xmlData appendData:layer5];
		
		theLayer--; // we work from the top layer down to match the layer loop above
	}

	[xmlData appendData:postamble];
	
	NSString *tmpFilename = [NSString stringWithFormat:@"%@/%@.motn", folderPath, folderName];
	
	[xmlData writeToFile:tmpFilename atomically:YES];
	
	[[NSWorkspace sharedWorkspace] openFile:tmpFilename];
}

- (void)
writeLayerData:(NSData *)theData
layer:(int)theLayer;
{
	unsigned long creator = 'ART5';
	unsigned long type = 'PDF ';
	NSString *tmpPath = [NSString stringWithFormat:@"%@/%@ (Layer %d).ai", folderPath, folderName, theLayer];
	
	theData = NormalizePDFForDisplay( theData );

	if ( theData == nil ) return; // something is wrong with the licensing

#ifdef LICENSING_CONTROL_ON
	if ( OpModeLicensed != licensingLevelCheck().opMode )
	{
		return;
	}
#endif

	[[NSFileManager defaultManager]
			createFileAtPath:tmpPath
			contents:theData
			attributes:[NSDictionary	dictionaryWithObjects:[NSArray arrayWithObjects:
																			[NSNumber numberWithUnsignedLong:creator],
																			[NSNumber numberWithUnsignedLong:type],
																			[NSNumber numberWithInt:0664], // octal
																			nil]
												forKeys:[NSArray arrayWithObjects:
																			NSFileHFSCreatorCode,
																			NSFileHFSTypeCode,
																			NSFilePosixPermissions,
																			nil]	]	];
}

- (void)
createLayerLinkFolder;
{
	NSString *path = [self fileName];
	NSString *name = [[path lastPathComponent] stringByDeletingPathExtension];
	
	NSString *tmpPath = nil;

	int instance = -1;
	BOOL instanceIsInvalid = YES;
	BOOL isDirectorBool = YES; // lame
	
	do {
		instance++;
		
		if ( instance )
		{
			// check for folder with numeric ending
			tmpPath = [NSString stringWithFormat:@"~/Library/Application Support/LayerLink/%@%d", name, instance];
		}
		else
		{
			// check without numeric ending
			tmpPath = [NSString stringWithFormat:@"~/Library/Application Support/LayerLink/%@", name];
		}
		
		tmpPath = [tmpPath stringByExpandingTildeInPath];
		
		instanceIsInvalid = [[NSFileManager defaultManager] fileExistsAtPath:tmpPath isDirectory:&isDirectorBool];
		
	} while ( instanceIsInvalid );
	
	// create folder (returns a BOOL, could test for failure)
	[[NSFileManager defaultManager] createDirectoryAtPath:tmpPath attributes:nil];
	
//	// create backup folder
//	[[NSFileManager defaultManager]	createDirectoryAtPath:[tmpPath stringByAppendingPathComponent:@"Attic"]
//									attributes:nil];;
	
	// set base folder name (no numeric extension), used by writeLayerData:layer:
	folderName = [name retain];
	folderNameWithNumericExtension = [[tmpPath lastPathComponent] retain];
	folderPath = [tmpPath retain];
}

- (void)
setPageDimensions;
{
//	#warning pdf page dimensions not implemented
	CGRect box = CGPDFPageGetBoxRect( page, kCGPDFMediaBox );
	
	pdfIntegralWidth = ceil( box.size.width ); // - 70; // 650;
	pdfIntegralHeight = ceil( box.size.height ); // - 133; // 407;
	
	// NSLog(@"page dimensions are %d wide by %d high", pdfIntegralWidth, pdfIntegralHeight );
}

- (void)
reloadDataRepresentation:(NSData *)data
ofType:(NSString *)type
withFileName:(NSString *)theFileName
folderPath:(NSString *)theFolderPath
folderName:(NSString *)theFolderName;
{
	[super loadDataRepresentation:data ofType:type];
	
#ifdef LICENSING_CONTROL_ON
	if ( OpModeLicensed != licensingLevelCheck().opMode )
	{
		return;
	}
#endif

	[self setFileName:theFileName]; // hack to get NSDocument open behavior
	
	fileData = [data retain];
	folderPath = theFolderPath;
	folderName = theFolderName;
	
	pdf = CGPDFDocumentCreateWithURL(   CFURLCreateWithFileSystemPath(	kCFAllocatorDefault,
																		(CFStringRef)[self fileName],
																		kCFURLPOSIXPathStyle,
																		NO  )   );
	
	catalog = CGPDFDocumentGetCatalog( pdf ); CFRetain( catalog );
	page = CGPDFDocumentGetPage( pdf , 1 ); // AI documents only have one page
	pageDict = CGPDFPageGetDictionary( page );
	
	const char *keyName = "Contents";
	BOOL gotStream = NO;
	gotStream = CGPDFDictionaryGetStream( pageDict, keyName, &stream );
	
	if ( gotStream )
	{
		CGPDFDataFormat format;
		streamDict = CGPDFStreamGetDictionary( stream );
		streamData = (NSData *)CGPDFStreamCopyData( stream, &format );
	}
	else NSLog(@"LayerLink error: could not get page content stream.");
		
	// handle FlateDecode here
	if ( [self firstPageContentStreamNeedsInflate] )
	{
		NSMutableData *inflatedStream = [NSMutableData dataWithLength:4096];
		
		//////// taken from example.c, test_large_inflate() in the zlib source distribution
		Byte *compr = (Byte *)[streamData bytes];
		Byte *uncompr = (Byte *)[inflatedStream mutableBytes];
		uLong comprLen = [streamData length];
		uLong uncomprLen = [inflatedStream length];

		int err;
		z_stream d_stream; /* decompression stream */

//		strcpy((char*)uncompr, "garbage");

		d_stream.zalloc = (alloc_func)0;
		d_stream.zfree = (free_func)0;
		d_stream.opaque = (voidpf)0;

		d_stream.next_in  = compr;
		d_stream.avail_in = (uInt)comprLen;

		err = inflateInit(&d_stream);
		CHECK_ERR(err, "LayerLink error: problem with inflateInit");

		for (;;) {
			d_stream.next_out = uncompr;
			d_stream.avail_out = (uInt)uncomprLen;
//			err = inflate(&d_stream, Z_NO_FLUSH);
			err = inflate(&d_stream, Z_SYNC_FLUSH); // changed by Eric Ocean
			if (err == Z_STREAM_END) break;
			// new code from Eric Ocean follows
			else if (err == Z_BUF_ERROR || ((err == Z_OK) && (d_stream.avail_out == 0)))
			{
				// we need to allocate more buffer space
				uncompr = (Byte *)([inflatedStream mutableBytes] + [inflatedStream length]);
				[inflatedStream setLength:([inflatedStream length] + 4096)]; // gives us more space
				// don't need to change uncomprLen, it's already set to 4096
				continue;
			}
			// end new code
			CHECK_ERR(err, "LayerLink error: problem with inflate");
		}

		// new code from Eric Ocean follows
		[inflatedStream setLength:d_stream.total_out]; // truncate allocated buffer to fit
		// end new code
		
		err = inflateEnd(&d_stream);
		CHECK_ERR(err, "LayerLink error: problem with inflateEnd");

//		if (d_stream.total_out != 2*uncomprLen + comprLen/2) {
//			fprintf(stderr, "bad large inflate: %ld\n", d_stream.total_out);
//			exit(1);
//		} else {
//			printf("large_inflate(): OK\n");
//		}
		//////// end example.c code
		
		streamData = inflatedStream;
	}
	
	// end handle FlateDecode
		
	PDFStreamParser *transformedStream = [[PDFStreamParser alloc] init];
	PDFParser *streamParser = [[PDFParser alloc] initWithData:streamData forDocument:(PDFDocument *)transformedStream];

	[streamParser parseStream];

	/////////////////// Create LayerLink folder //////////////////
	
//	[self createLayerLinkFolder]; // we set these variables at top of method
	
	/////////////////// Calculate integral page dimensions //////////////////
	
	[self setPageDimensions];
	
	/////////////////// Calculate Illustrator Version //////////////////
	
	[self setIllustratorVersion];
	
	/////////////////// Break up input into layers //////////////////
	
	NSArray *layerStarts = [[self locateLayerStarts] retain];
//	NSLog(@"layer starts: %@", layerStarts);
	
	/////////////////// Get layer data //////////////////
	
	NSMutableArray *layerData = [[NSMutableArray array] retain];
	
	NSEnumerator *enumerator = [layerStarts objectEnumerator];
	NSNumber *aNumber;
	int lastLocation = [[enumerator nextObject] intValue];
	
	while ( aNumber = [enumerator nextObject] )
	{
		NSData *ld = [NSData	dataWithBytes:([streamData bytes]+lastLocation)
								length:([aNumber intValue]-lastLocation)];
		[layerData addObject:ld];
		lastLocation = [aNumber intValue];
	}
	
	NSData *ld = [NSData	dataWithBytes:([streamData bytes]+lastLocation)
							length:([streamData length] - lastLocation)];
	[layerData addObject:ld];

//	NSLog(@"layer data is: %@", layerData);
	
	/////////////////// Locate hidden layers //////////////////
	
	NSMutableArray *hiddenLayers = (NSMutableArray *)[self locateHiddenLayers];
	
	if ( [hiddenLayers count] < [layerData count] ) [hiddenLayers addObject:[NSNumber numberWithBool:NO]];
		// locateHiddenLayers doesn't capture the last layer if it's not hidden, and I was too lazy to redesign it
	
//	NSLog(@"hidden layers are: %@", hiddenLayers);
	
	/////////////////// Main PDF Generation Loop //////////////////
	
	NSEnumerator *layerDataEnum = [layerData objectEnumerator];
	NSEnumerator *hiddenLayersEnum = [hiddenLayers objectEnumerator];
	
	id layerStreamData;
	id hiddenLayerBooleanOrName;
	
	// create page object data
	int pageObjectNum = [self firstPageObjectNumber];
	int pageGenerationNum = [self firstPageGenerationNumber];
	NSString *pageObjectString = [NSString stringWithFormat:@"%d %d obj\r",
										pageObjectNum, pageGenerationNum];

	NSData *pageObjectData = [pageObjectString dataUsingEncoding:NSASCIIStringEncoding];
	
	// create content object data
	int contentObjectNum = [self contentObjectNumber];
	int contentGenerationNum = [self contentGenerationNumber];
	NSString *contentObjectString = [NSString stringWithFormat:@"%d %d obj\r<<\r/Length ",
										contentObjectNum, contentGenerationNum];

	NSData *contentObjectData = [contentObjectString dataUsingEncoding:NSASCIIStringEncoding];
	
	// create end object data
	NSString *endObjectString = @"endstream\rendobject\r";
	NSData *endObjectData = [endObjectString dataUsingEncoding:NSASCIIStringEncoding];
	
	int currentLayer = 0;
	
	while	(
				( layerStreamData = [layerDataEnum nextObject] ) &&
				( hiddenLayerBooleanOrName = [hiddenLayersEnum nextObject] )
			)
	{
		int pageObjectLocation = 0;
		currentLayer++;
		
		// create new PDF file data
		NSMutableData *layerFileData = [NSMutableData data];
		
		// append original file
		[layerFileData appendData:fileData];
		
		if ( [hiddenLayerBooleanOrName boolValue] )
		{
			///////////// Need to update page object here /////////////
			pageObjectLocation = [layerFileData length];
			
			PDFDictionary *newPage = [self firstPageDictionaryMutableCopy];
			PDFDictionary *contentDictionary = [self hiddenLayerDictionaryWithName:hiddenLayerBooleanOrName];
			
			[newPage addEntriesFromDictionary:[contentDictionary nsDictionary]];
			
			// new page has now been updated with the values from the hidden layer's dictionary
			
			// append object header (part 1)
			[layerFileData appendData:pageObjectData];
			
			// append object contents
			[newPage writeToData:layerFileData];
			
			// append end object
			NSString *endPageString = @"\rendobject\r";
			NSData *endPageData = [endPageString dataUsingEncoding:NSASCIIStringEncoding];
			[layerFileData appendData:endPageData];
		}
		else
		{
			// append object header (part 1)
			[layerFileData appendData:contentObjectData];
			
			// layer isn't hidden, hiddenLayerBooleanOrName is NSNumber (CFBoolean) object
			// layerStreamData is the data we want to write to the stream, after we've written
			// any necessary transformed prior layers
			NSMutableData *tmpStream = [NSMutableData data];
			[transformedStream writeContentsToData:tmpStream upToButNotIncludingLayer:currentLayer];
			[tmpStream appendData:layerStreamData];
			
			// append stream data length
			NSString *layerLengthString = [NSString stringWithFormat:@"%d\r>>\rstream\r\n", [tmpStream length]];
			NSData *layerLengthData = [layerLengthString dataUsingEncoding:NSASCIIStringEncoding];
			
			[layerFileData appendData:layerLengthData];
			
			// append stream data
			[layerFileData appendData:tmpStream];

			// append endstream, endobject lines
			[layerFileData appendData:endObjectData];
		}
		
		int xref_location = [layerFileData length];
		
		[layerFileData appendData:[@"xref\r0 1\r0000000000 65535 f \r" dataUsingEncoding:NSASCIIStringEncoding]];

		if ( [hiddenLayerBooleanOrName boolValue] )
		{
			// add page object entry
			NSString *xrefString3 = [NSString stringWithFormat:@"%d 1\r%010d %05d n \r",
														pageObjectNum,
														pageObjectLocation,
														pageGenerationNum];
												
			[layerFileData appendData:[xrefString3 dataUsingEncoding:NSASCIIStringEncoding]];
		}
		else
		{
			// add content object entry
			NSString *xrefString2 = [NSString stringWithFormat:@"%d 1\r%010d %05d n \r",
														contentObjectNum,
														[fileData length], // i.e. contentObjectLocation
														contentGenerationNum];
												
			[layerFileData appendData:[xrefString2 dataUsingEncoding:NSASCIIStringEncoding]];
		}
		
		// this should be changed to account for /Root at other object numbers
		NSString *trailerString = [NSString stringWithFormat:@"trailer\r<<\r/Size %d\r/Root 1 0 R\r/Prev %d\r>>\r",
											[self numberOfObjects],
											startxref];
		
		[layerFileData appendData:[trailerString dataUsingEncoding:NSASCIIStringEncoding]];


		NSString *endString = [NSString stringWithFormat:@"startxref\r%d\r", xref_location]; 
		[layerFileData appendData:[endString dataUsingEncoding:NSASCIIStringEncoding]];
		
		
		NSString *eolString = [@"\x25\x25" stringByAppendingString:@"EOF\r"]; 
		[layerFileData appendData:[eolString dataUsingEncoding:NSASCIIStringEncoding]];
		
		// now it's time to UPDATE the data out to a file
		[self updateLayerData:layerFileData layer:currentLayer];
	}
	
	[self generateLayerLinkInfo]; // multi-use safe
}

- (void)
updateLayerData:(NSData *)theData
layer:(int)theLayer;
{
	unsigned long creator = 'ART5';
	unsigned long type = 'PDF ';
	NSString *tmpPath = [NSString stringWithFormat:@"%@/%@ (Layer %d).ai", folderPath, folderName, theLayer];
	
	theData = NormalizePDFForDisplay( theData );
	
	if ( theData == nil ) return; // something is wrong with the licensing

	NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:tmpPath];
	
	if (fh)
	{
//		NSLog(@"updated an existing layer");
		[fh truncateFileAtOffset:0]; // empty the file
		[fh writeData:theData];
		[fh closeFile];
	}
	else
	{
//		NSLog(@"added a new layer after an update");
		
		// This could fail if for some reason folderName doesn't really exist (could happen if the user deletes
		// a folder while it's still being monitored). In that case, fh will always be nil and this method
		// will simply silently fail, which althought somewhat inefficient, is the correct behavior.
		[[NSFileManager defaultManager]
				createFileAtPath:tmpPath
				contents:theData
				attributes:[NSDictionary	dictionaryWithObjects:[NSArray arrayWithObjects:
																				[NSNumber numberWithUnsignedLong:creator],
																				[NSNumber numberWithUnsignedLong:type],
																				[NSNumber numberWithInt:0664], // octal
																				nil]
													forKeys:[NSArray arrayWithObjects:
																				NSFileHFSCreatorCode,
																				NSFileHFSTypeCode,
																				NSFilePosixPermissions,
																				nil]	]	];
	}
}

- (void)
setIllustratorVersion;
{
	NSString *producer = [self producerAsNSString];
	NSString *creator = [self creatorAsNSString];
	
	if ( [producer isEqualToString:@"Adobe PDF library 6.66"] ) illustratorVersion = kIllustratorCS;
	else if ( [producer isEqualToString:@"Adobe PDF library 5.00"] ) illustratorVersion = kIllustrator10;
	else if ( [producer isEqualToString:@"Adobe PDF library 7.77"] ) illustratorVersion = kIllustratorCS2;
	else illustratorVersion = kIllustratorVersionUnknown;

	if ( illustratorVersion == kIllustratorVersionUnknown )
	{
	    // try another method to get the illustrator version
    	if ( [creator isEqualToString:@"Illustrator"] ) illustratorVersion = kIllustratorCS;
    	else if ( [creator isEqualToString:@"Adobe Illustrator 10"] ) illustratorVersion = kIllustrator10;
    	else if ( [creator isEqualToString:@"Adobe Illustrator CS2"] ) illustratorVersion = kIllustratorCS2;
	}
}

- (PDFDictionary *)
hiddenLayerDictionaryWithName:(PDFName *)aName;
{
	if ( illustratorVersion == kIllustrator10 )
	{
		PDFObjectReference *rootObjectRef = [trailer objectForKey:@"Root"];
		PDFIndirectObject *rootObject = [self objectForReference:rootObjectRef];

		PDFObjectReference *pagesRef = [rootObject objectForKey:@"Pages"];
		PDFIndirectObject *pagesObject = [self objectForReference:pagesRef];

		PDFObjectReference *pageRef = [[pagesObject objectForKey:@"Kids"] objectAtIndex:0];
		PDFIndirectObject *pageObject = [self objectForReference:pageRef];
		
		PDFObjectReference *hiddenLayerRef = [[[pageObject objectForKey:@"Resources"]
														   objectForKey:@"Properties"]
														   objectForKey:[aName string]];
		PDFIndirectObject *hiddenLayer = [self objectForReference:hiddenLayerRef];
		
		return [hiddenLayer value];
	}
	else if ( illustratorVersion == kIllustratorCS || illustratorVersion == kIllustratorCS2 )
	{
		PDFObjectReference *rootObjectRef = [trailer objectForKey:@"Root"];
		PDFIndirectObject *rootObject = [self objectForReference:rootObjectRef];

		PDFObjectReference *pagesRef = [rootObject objectForKey:@"Pages"];
		PDFIndirectObject *pagesObject = [self objectForReference:pagesRef];

		PDFObjectReference *pageRef = [[pagesObject objectForKey:@"Kids"] objectAtIndex:0];
		PDFIndirectObject *pageObject = [self objectForReference:pageRef];
		
		PDFDictionary *hiddenLayerDict = [[[pageObject objectForKey:@"Resources"]
														   objectForKey:@"Properties"]
														   objectForKey:[aName string]];
		return hiddenLayerDict;
	}
	else return [NSDictionary dictionary];
}

- (NSArray *)csLayerNames;
{
	PDFObjectReference *rootObjectRef = [trailer objectForKey:@"Root"];
	PDFIndirectObject *rootObject = [self objectForReference:rootObjectRef];

	PDFObjectReference *pagesRef = [rootObject objectForKey:@"Pages"];
	PDFIndirectObject *pagesObject = [self objectForReference:pagesRef];

	PDFObjectReference *pageRef = [[pagesObject objectForKey:@"Kids"] objectAtIndex:0];
	PDFIndirectObject *pageObject = [self objectForReference:pageRef];
	
	PDFDictionary *layersDict = [[pageObject objectForKey:@"Resources"] objectForKey:@"Properties"];
	
	NSMutableArray *layerNames = [NSMutableArray array];
	NSString *layerNamePrefix = @"MC";
	int currentLayer = 0;
	NSString *layerName = [layerNamePrefix stringByAppendingString:[NSString stringWithFormat:@"%d", currentLayer]];
	
	PDFDictionary *layerDict = [layersDict objectForKey:layerName];
	
	while ( layerDict )
	{
		NSString *title = nil;
		title = [layerDict objectForKey:@"Title"];
		if ( title ) [layerNames addObject:title];
		
		currentLayer++;
		layerName = [layerNamePrefix stringByAppendingString:[NSString stringWithFormat:@"%d", currentLayer]];
		layerDict = [layersDict objectForKey:layerName];
	}
	
	return layerNames;
}

@end

size_t
putBytes(void *info, const void *buffer, size_t count)
{
	[(NSMutableData *)info appendBytes:buffer length:count];
	return count;
}

NSData *
NormalizePDFForDisplay( NSData *theData )
{
	return theData;
}
//{
//	// turn theData into something we can draw
//	CGDataProviderRef data_p = CGDataProviderCreateWithData( NULL, [theData bytes], [theData length], NULL );
//	CGPDFDocumentRef old_pdf = CGPDFDocumentCreateWithProvider( data_p );
//	
//	// create a new PDF context to draw into
//	NSMutableData *new_pdf_data = [NSMutableData data];
//	CGDataConsumerCallbacks dc_c = { putBytes, NULL };
//	CGDataConsumerRef data_c = CGDataConsumerCreate( new_pdf_data, &dc_c );
//	
//	CGRect media_box = CGPDFDocumentGetMediaBox( old_pdf, 1 );
//
//	CGContextRef new_pdf_context = CGPDFContextCreate( data_c, &media_box, NULL );
//	
//	// begin a new page
//	CGContextBeginPage( new_pdf_context, &media_box );
//	
//	// draw the old PDF into the new context
//	CGPDFPageRef old_page = CGPDFDocumentGetPage( old_pdf, 1 );
//	CGContextDrawPDFPage( new_pdf_context, old_page );
//
//#ifdef LICENSING_CONTROL_ON
//	if ( OpModeTrial == licensingLevelCheck().opMode )
//	{
//		// add purple lines across the front
//		NSLog(@"LayerLink is operating in demo mode.");
//		
//		// turn grid_lines into something we can draw
//		NSData *grid_data = [NSData	dataWithBytesNoCopy:grid_lines
//									length:grid_lines_length
//									freeWhenDone:NO];
//		CGDataProviderRef grid_data_p = CGDataProviderCreateWithData( NULL, [grid_data bytes], [grid_data length], NULL );
//		CGPDFDocumentRef grid_pdf = CGPDFDocumentCreateWithProvider( grid_data_p );
//		
//		// draw the grid pdf into the new context
//		CGContextDrawPDFDocument( new_pdf_context, media_box, grid_pdf, 1 );
//		
//		// clean up
//		CGDataProviderRelease( grid_data_p );
//		CGPDFDocumentRelease( grid_pdf );
//	}
//	else if ( OpModeLicensed != licensingLevelCheck().opMode )
//	{
//		return nil; // if we're not in trial mode and we're not licensed, create empty files
//	}
//#endif
//
//	// end the page
//	CGContextEndPage( new_pdf_context );
//	
//	// close the pdf context
//	CGContextRelease( new_pdf_context );
//	
//	// clean up
//	CGDataProviderRelease( data_p );
//	CGPDFDocumentRelease( old_pdf );
//	CGDataConsumerRelease( data_c );
//	
//	return new_pdf_data;
//}


