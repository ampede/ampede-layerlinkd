//
//  LayerLink.m
//  LayerLink
//
//  Created by Eric Ocean on 10/4/04.
//  Copyright (c) 2004 Eric Daniel Ocean. All rights reserved.
//

#import "LayerLink.h"

#ifdef LICENSING_CONTROL_ON
#import <LicenseControl/LicenseControl.h>
#import <LicenseControl/LicensingLauncherC.h>
#import <LicenseControl/DetermineOpMode.h>
#endif

#import "UKKQueue.h"
#import "AIDocument.h"
#import "BDAlias.h"

//#import <ILCrashReporter/ILCrashReporter.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>


@implementation LayerLink

- init
{
	if ( self = [super init] ) {
	
		defaults = [[NSUserDefaults standardUserDefaults] retain];
		[defaults addSuiteNamed:@"com.ampede.layerlink.defaultsSuite"];
		kqueue = [[UKKQueue alloc] init];
		filePathToLayerLinkFolder = [[NSMutableDictionary alloc] init];
		pendingAiFiles = [[NSMutableDictionary alloc] init];
		
		[[[NSWorkspace sharedWorkspace] notificationCenter]
				addObserver:self
				selector:@selector(fileRenamedNotification:)
				name:UKKQueueFileRenamedNotification
				object:nil];
				
		[[[NSWorkspace sharedWorkspace] notificationCenter]
				addObserver:self
				selector:@selector(fileWrittenToNotification:)
				name:UKKQueueFileWrittenToNotification
				object:nil];
				
		[[[NSWorkspace sharedWorkspace] notificationCenter]
				addObserver:self
				selector:@selector(fileDeletedNotification:)
				name:UKKQueueFileDeletedNotification
				object:nil];
		
//		[[ILCrashReporter defaultReporter]
//				launchReporterForCompany:@"Ampede Inc."
//				reportAddr:@"layerlink-crash@ampede.com"];

#ifdef LICENSING_CONTROL_ON
		if ( OpModeLicensed == usageLevelCheck().opMode )
		{
//			NSLog(@"posting com.ampede.layerlink.licensed notification");
			
			[[NSDistributedNotificationCenter defaultCenter]
				postNotificationName:@"com.ampede.layerlink.licensed"
				object:nil];
		}
#endif
	}
	return self;
}

- (void)dealloc;
{
	[defaults release]; defaults = nil;
	[kqueue release]; kqueue = nil;
	[defaults release]; defaults = nil;
	[filePathToLayerLinkFolder release]; filePathToLayerLinkFolder = nil;
	[pendingAiFiles release]; pendingAiFiles = nil;
	[super dealloc];
}

- (UKKQueue *)kqueue;
{
	return kqueue;
}

- (void)
fileRenamedNotification:(NSNotification *)note;
{
//	NSLog(@"fileRenamedNotification: called");
//	NSString *path = [note object];
}

- (void)
fileWrittenToNotification:(NSNotification *)note;
{
//	NSLog(@"fileWrittenToNotification: called");
	
	NSString *aiFilePath = [note object];

	NSArray *linkFolders = [filePathToLayerLinkFolder objectForKey:aiFilePath];
	NSData *fileData = [NSData dataWithContentsOfFile:aiFilePath];
	
	NSString *layerLinkFolderPath = [@"~/Library/Application Support/LayerLink/" stringByExpandingTildeInPath];

	NSEnumerator *e = [linkFolders objectEnumerator];
	id folder;
	while ( folder = [e nextObject] )
	{
		NSString *folderPath = [layerLinkFolderPath stringByAppendingPathComponent:folder];
		
//		NSLog(@"folderPath is %@", folderPath);
		
		NSData *plistData = [NSData dataWithContentsOfFile:[folderPath stringByAppendingPathComponent:@"layerlink.info"]];
		
		NSString *error = nil;
		NSPropertyListFormat format;
		
		if ( !plistData ) continue;
		
		NSDictionary *info = [NSPropertyListSerialization	propertyListFromData:plistData
															mutabilityOption:NSPropertyListImmutable
															format:&format
															errorDescription:&error];
		if (error) 
		{
			NSLog(@"LayerLink error: layerlink.info at %@ was corrupt and could not be read. Reason: %@.", folderPath, error);
			[error release];
			continue;
		}
		
		if ( fileData == nil ) continue; // safety precaution

		AIDocument *doc = [[AIDocument alloc] init];
		[doc	reloadDataRepresentation:fileData
				ofType:@"Adobe Illustrator"
				withFileName:aiFilePath
				folderPath:folderPath
				folderName:[info objectForKey:@"baseName"]];
		[doc release];
	}
}

unsigned int
InodeForFileDescriptor( int fd )
{
	struct stat sb;
	
	if ( fstat( fd, &sb ) == 0 ) return sb.st_ino; // fstat() returns 0 on success
	else return 0;
}

- (void)
fileDeletedNotification:(NSNotification *)note;
{
//	NSLog(@"fileDeletedNotification: called");
	
	NSString *path = [note object];
	
	unsigned int inode = [kqueue inodeForPathInQueue:path];
	[kqueue removePathFromQueue:path];

	if ( inode )
	{
		NSString *parentDirectory = [path stringByDeletingLastPathComponent];
		NSArray *files = [[NSFileManager defaultManager] directoryContentsAtPath:parentDirectory];
		
		NSEnumerator *e = [files objectEnumerator];
		NSString *lastPathComponent;
		
		while ( lastPathComponent = [e nextObject] )
		{
			BOOL isDirectory = NO;
			NSString *fullPath = [parentDirectory stringByAppendingPathComponent:lastPathComponent];
			[[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDirectory];
			
			if ( isDirectory == NO )
			{
				NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:fullPath];
				int fd = [fh fileDescriptor];
				if ( InodeForFileDescriptor( fd ) == inode )
				{	
					// hack to get file to actually delete
					BOOL shouldUnlink = [defaults boolForKey:@"doManualUnlink"];
					if ( shouldUnlink )
					{
//						NSLog(@"doing manual unlink()");
						unlink( [fullPath fileSystemRepresentation] );
					}
//					else NSLog(@"skipping manual unlink()");
					break;
				}
			}
		}
	}
	
	[kqueue addPathToQueue:path]; // the file exists again by the time we get here
	
	[self fileWrittenToNotification:note];
}

- (void)
addLayerLinkFolder:(NSString *)folderName;
{
	NSString *path = [NSString stringWithFormat:@"~/Library/Application Support/LayerLink/%@/layerlink.info", folderName];
	path = [path stringByExpandingTildeInPath];
	NSData *plistData = [NSData dataWithContentsOfFile:path];
	NSString *error = nil;
	NSPropertyListFormat format;
	
	if ( !plistData )
	{
//		NSLog(@"plistData in addLayerLinkFolder: was nil");
		return;
	}
	
	NSDictionary *info = [NSPropertyListSerialization	propertyListFromData:plistData
														mutabilityOption:NSPropertyListImmutable
														format:&format
														errorDescription:&error];
	if (error) 
	{
		NSLog(@"LayerLink error: layerlink.info was corrupt and could not be read. Reason: %@.", error);
		[error release];
		return;
	}

	BDAlias *alias = [BDAlias aliasWithData:[info objectForKey:@"aliasData"]];
	NSString *aliasPath = [alias fullPath];
	
//	NSLog(@"aliasPath is %@", aliasPath);
	
	[kqueue removePathFromQueue:aliasPath]; // to be safe; we don't want to monitor more than once
	[kqueue addPathToQueue:aliasPath];
	
	// update ai file mapping
	NSMutableArray *linkArray = [filePathToLayerLinkFolder objectForKey:aliasPath];
	if ( linkArray ) [linkArray addObject:folderName];
	else [filePathToLayerLinkFolder setObject:[NSMutableArray arrayWithObject:folderName] forKey:aliasPath];
}

- (void)
monitorLayerLinkFolder;
{
//	NSLog(@"monitorLayerLinkFolder called");
	
	// only monitor if we're licensed
	// (we don't want to "update" good files with pink lines when a license is uninstalled)
#ifdef LICENSING_CONTROL_ON
	if ( OpModeLicensed != usageLevelCheck().opMode ) 
	{
		NSLog(@"LayerLink is currently unlicensed; file monitoring/updating is disabled.");
		return;
	}
#endif

	// for each layerlink folder, begin monitoring the original file (if it exists)
	NSString *layerLinkFolderPath = [@"~/Library/Application Support/LayerLink/" stringByExpandingTildeInPath];
	NSArray *layerLinkDirectories = [[NSFileManager defaultManager] directoryContentsAtPath:layerLinkFolderPath];
											
	NSEnumerator *e = [layerLinkDirectories objectEnumerator];
	id anObject;
	
	while ( anObject = [e nextObject] )
	{
		NSString *path = [NSString stringWithFormat:
										@"%@/layerlink.info",
										[layerLinkFolderPath stringByAppendingPathComponent:anObject]];
		NSData *plistData = [NSData dataWithContentsOfFile:path];
		NSString *error = nil;
		NSPropertyListFormat format;
		
		if ( !plistData ) continue;
		
		NSDictionary *info = [NSPropertyListSerialization	propertyListFromData:plistData
															mutabilityOption:NSPropertyListImmutable
															format:&format
															errorDescription:&error];
		if (error) 
		{
			NSLog(@"LayerLink error: layerlink.info was corrupt and could not be read. Reason: %@.", error);
			[error release];
			continue;
		}

		BDAlias *alias = [BDAlias aliasWithData:[info objectForKey:@"aliasData"]];
		NSString *aliasPath = [alias fullPath];
		
		[kqueue removePathFromQueue:aliasPath]; // to be safe; we don't want to monitor more than once
		[kqueue addPathToQueue:aliasPath];
		
		NS_DURING
			// update ai file mapping
			NSMutableArray *linkArray = [filePathToLayerLinkFolder objectForKey:aliasPath];
			if ( linkArray ) [linkArray addObject:anObject];
			else [filePathToLayerLinkFolder setObject:[NSMutableArray arrayWithObject:anObject] forKey:aliasPath];
		NS_HANDLER
			// The error is typically because aliasPath could not be determined, which means the file was copied AND moved. Ouch.
			// What we could do is ask the user where the original file is, and then update our mapping. That might be the best way to go about things. But not this release.
			NSLog(@"LayerLink error: a file being monitored has disappeared.");
		NS_ENDHANDLER
		
		// for each file monitored, make sure that the layers are current for that file
		NSDate *oldDate = [[info objectForKey:@"fileAttributes"] objectForKey:NSFileModificationDate];
		NSDate *currentDate = [[[NSFileManager defaultManager]	fileAttributesAtPath:aliasPath traverseLink:YES]
									objectForKey:NSFileModificationDate];
		
		if ( ![oldDate isEqualToDate:currentDate] )
		{
			// if the layers aren't current, regenerate them. This will require modifications to the current method for generating layers, because we need to modify the current files, and we don't need to generate XML. The best bet is probably to factor out the layer generation code, and call different routines for opening files and for updating files.
			
			NSData *fileData = [NSData dataWithContentsOfFile:aliasPath];
			if ( fileData == nil ) continue; // safety precaution
			
			AIDocument *doc = [[AIDocument alloc] init];
			[doc	reloadDataRepresentation:fileData
					ofType:@"Adobe Illustrator"
					withFileName:aliasPath
					folderPath:[layerLinkFolderPath stringByAppendingPathComponent:anObject]
					folderName:[info objectForKey:@"baseName"]];
			[doc release];
		}
	}
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)app;
{
	return NO;
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)app;
{
	return NO;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification;
{
//	NSLog(@"applicationWillFinishLaunching: called");

	[[NSDistributedNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(launchLicensing)
			name:@"com.ampede.layerlink.launchLicenseControl"
			object:nil];
			
	[[NSDistributedNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(handleImportRequest:)
			name:@"com.ampede.layerlink.handleImportRequest"
			object:nil];
	
	[[NSDistributedNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(terminate:)
			name:@"com.ampede.layerlink.terminate"
			object:nil];
	
	[[NSDistributedNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(noteFirstRegistration:)
			name:@"com.Derman.LicenseControl.LiceningStatusChanged"
			object:nil];
			
	// make sure there is a LayerLink folder to monitor
	NSString *layerlinkPath = [@"~/Library/Application Support/LayerLink" stringByExpandingTildeInPath];
	BOOL exists = NO;
	[[NSFileManager defaultManager] fileExistsAtPath:layerlinkPath isDirectory:&exists];
	
	if ( !exists ) [[NSFileManager defaultManager] createDirectoryAtPath:layerlinkPath attributes:nil];
	
#ifdef LICENSING_CONTROL_ON
	if ( OpModeLicensed == licensingLevelCheck().opMode )
	{
		[self monitorLayerLinkFolder];
	}
#else
	[self monitorLayerLinkFolder];
#endif
}

- (void)
noteFirstRegistration:(NSNotification *)note;
{
	if ( [defaults boolForKey:@"LayerLink::hasBeenLicensed"] == NO )
	{
		NSLog(@"LayerLink has been registered.");
		[defaults setBool:YES forKey:@"LayerLink::hasBeenLicensed"];
	}
}

- (void)
terminate:(NSNotification *)note;
{
	[NSApp terminate:nil];
}

- (void)
handleImportRequest:(NSNotification *)note;
{
//	NSLog(@"handleImportRequest: called");
//	NSLog(@"fileURL is %@", [note object]);
	
	[[NSDocumentController sharedDocumentController]
				openDocumentWithContentsOfURL:[NSURL URLWithString:[note object]]
				display:NO];
}

- (void)launchLicensing;
{
#ifdef LICENSING_CONTROL_ON
	lauchLicensing();
#else
	NSLog(@"launchLicensing called");
#endif
}

- (NSUserDefaults *)defaults;
{
	return defaults;
}

@end
