//
//  IFAppController.m
//  ImageFlow
//
//  Created by Michel Schinz on 21.06.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFAppController.h"
#import "IFDirectoryManager.h"

#import "IFDocumentInspectorWindowController.h"

#import "IFPercentValueTransformer.h"

#import "IFAverageCIFilter.h"
#import "IFCropImageWithMaskCIFilter.h"
#import "IFMaskCIFilter.h"
#import "IFMaskOverlayCIFilter.h"
#import "IFSetAlphaCIFilter.h"
#import "IFSingleColorCIFilter.h"
#import "IFThresholdCIFilter.h"
#import "IFCircleGeneratorCIFilter.h"
#import "IFChannelToMaskCIFilter.h"
#import "IFMaskToImageCIFilter.h"
#import "IFMaskInvertCIFilter.h"
#import "IFMaskThresholdCIFilter.h"
#import "IFRectangularWindowCIFilter.h"

NSString* IFCurrentDocumentDidChangeNotification = @"IFCurrentDocumentDidChangeNotification";
NSString* IFNewDocumentKey = @"IFNewDocumentKey";

@interface IFAppController ()
- (IFInspectorWindowController*)openInspectorOfClass:(Class)class sender:(id)sender;
- (void)mainWindowDidChange:(NSNotification*)notification;
- (void)mainWindowDidResign:(NSNotification*)notification;
@end

@implementation IFAppController

- (id)init;
{
  if (![super init])
    return nil;
  inspectorControllers = [NSMutableSet new];
  sharedPreferencesController = nil;

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(mainWindowDidChange:)
                                               name:NSWindowDidBecomeMainNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(mainWindowDidResign:)
                                               name:NSWindowDidResignMainNotification
                                             object:nil];
  return self;
}

- (void) dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  OBJC_RELEASE(sharedPreferencesController);
  OBJC_RELEASE(inspectorControllers);
  [super dealloc];
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification;
{
  // Register value transformers
  [IFPercentValueTransformer class];

  // Register filters
  [IFAverageCIFilter class];
  [IFCropImageWithMaskCIFilter class];
  [IFMaskCIFilter class];
  [IFMaskOverlayCIFilter class];
  [IFSetAlphaCIFilter class];
  [IFSingleColorCIFilter class];
  [IFThresholdCIFilter class];
  [IFCircleGeneratorCIFilter class];
  [IFChannelToMaskCIFilter class];
  [IFMaskToImageCIFilter class];
  [IFMaskInvertCIFilter class];
  [IFMaskThresholdCIFilter class];
  [IFRectangularWindowCIFilter class];

  NSFileManager* fileMgr = [NSFileManager defaultManager];
  IFDirectoryManager* dirMgr = [IFDirectoryManager sharedDirectoryManager];

  // Setup templates menu
  NSString* docTemplatesPath = [dirMgr documentTemplatesDirectory];
  NSArray* templateFiles = [fileMgr directoryContentsAtPath:docTemplatesPath];
  for (int i = 0; i < [templateFiles count]; ++i) {
    NSString* templateName = [templateFiles objectAtIndex:i];
    NSMenuItem* newItem = [templatesMenu addItemWithTitle:templateName action:@selector(newDocumentFromTemplate:) keyEquivalent:@""];
    [newItem setRepresentedObject:[docTemplatesPath stringByAppendingPathComponent:templateName]];
  }

  // Configure color wells
  [NSColor setIgnoresAlpha:NO];
}

- (IBAction)showPreferencesPanel:(id)sender;
{
  if (sharedPreferencesController == nil)
    sharedPreferencesController = [IFPreferencesWindowController new];
  [sharedPreferencesController showWindow:self];
}

- (void)newDocumentFromTemplate:(id)sender;
{
  NSDocumentController* documentController = [NSDocumentController sharedDocumentController];
  NSString* docType = [documentController defaultType];
  NSError* error;
  IFDocument* doc = [documentController openUntitledDocumentAndDisplay:YES error:&error];
  if (doc == nil) {
    [documentController presentError:error];
    return;
  }
  NSURL* docURL = [NSURL fileURLWithPath:[sender representedObject]];
  [doc readFromURL:docURL ofType:docType error:&error];
  if (error != nil) {
    [documentController presentError:error];
    return;
  }
  [[doc undoManager] removeAllActions];
}

- (void)inspectorWindowWillClose:(NSNotification*)notification;
{
  NSWindow* window = [notification object];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:window];
  NSAssert([inspectorControllers containsObject:[window windowController]], @"unexpected window");
  [inspectorControllers removeObject:[window windowController]];
}

- (IBAction)openDocumentSettingsInspector:(id)sender;
{
  [self openInspectorOfClass:[IFDocumentInspectorWindowController class] sender:sender];
}

// MARK: -
// MARK: PRIVATE

- (IFInspectorWindowController*)openInspectorOfClass:(Class)class sender:(id)sender;
{
  IFInspectorWindowController* controller = [class new];
  [controller showWindow:sender];
  [inspectorControllers addObject:controller];
  [controller release];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inspectorWindowWillClose:) name:NSWindowWillCloseNotification object:[controller window]];

  return controller;
}

- (void)mainWindowDidChange:(NSNotification*)notification;
{
  NSDocument* doc = [[[notification object] windowController] document];
  [[NSNotificationCenter defaultCenter] postNotificationName:IFCurrentDocumentDidChangeNotification
                                                      object:nil
                                                    userInfo:[NSDictionary dictionaryWithObject:doc forKey:IFNewDocumentKey]];
}

- (void)mainWindowDidResign:(NSNotification*)notification;
{
  [[NSNotificationCenter defaultCenter] postNotificationName:IFCurrentDocumentDidChangeNotification
                                                      object:nil
                                                    userInfo:[NSDictionary dictionaryWithObject:[NSNull null] forKey:IFNewDocumentKey]];
}

@end
