//
//  IFImageInspectorWindowController.m
//  ImageFlow
//
//  Created by Michel Schinz on 08.08.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFImageInspectorWindowController.h"
#import "IFDocument.h"
#import "IFFilterController.h"
#import "IFAnnotation.h"
#import "IFErrorConstantExpression.h"
#import "IFAppController.h"
#import "NSAffineTransformIFAdditions.h"
#import "IFTreeViewWindowController.h"

@interface IFImageInspectorWindowController (Private)
- (void)setCurrentDocument:(IFDocument*)newDocument;
@end

@implementation IFImageInspectorWindowController

static NSString* IFImageViewModeDidChange = @"IFImageViewModeDidChange";
static NSString* IFCanvasBoundsDidChange = @"IFCanvasBoundsDidChange";
static NSString* IFActiveViewDidChange = @"IFActiveViewDidChange";

static NSString* IFToolbarModeItemIdentifier = @"IFToolbarModeItemIdentifier";
static NSString* IFToolbarVariantItemIdentifier = @"IFToolbarVariantItemIdentifier";
static NSString* IFToolbarLockedItemIdentifier = @"IFToolbarLockedItemIdentifier";

- (id)init;
{
  if (![super initWithWindowNibName:@"IFImageWindow"])
    return nil;
  currentDocument = nil;
  imageViewController = [IFImageViewController new];
  hudWindowController = [IFHUDWindowController new];
  
  proxy = [[NSValue valueWithNonretainedObject:self] retain];
  
  [imageViewController addObserver:self forKeyPath:@"mode" options:0 context:IFImageViewModeDidChange];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(documentDidChange:)
                                               name:IFCurrentDocumentDidChangeNotification
                                             object:nil];
  return self;
}

- (void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [imageViewController removeObserver:self forKeyPath:@"mode"];
  
  OBJC_RELEASE(modeToolbarItem);
  OBJC_RELEASE(variantToolbarItem);
  OBJC_RELEASE(lockedToolbarItem);
  OBJC_RELEASE(proxy);
  OBJC_RELEASE(hudWindowController);
  OBJC_RELEASE(imageViewController);
  [self setCurrentDocument:nil];
  [super dealloc];
}

- (void)windowDidLoad;
{
  [super windowDidLoad];

  [[self window] setFrameAutosaveName:@"IFImageInspector"];
  [[self window] setDisplaysWhenScreenProfileChanges:YES];
  
  [[self window] setContentView:[imageViewController topLevelView]];
  [hudWindowController setUnderlyingWindow:[self window]];
  [hudWindowController setUnderlyingView:[imageViewController activeView]];
  [imageViewController addObserver:self forKeyPath:@"activeView" options:0 context:IFActiveViewDidChange];

  [self setCurrentDocument:(IFDocument*)[[NSDocumentController sharedDocumentController] currentDocument]];
  
  // Configure toolbar
  NSNib* toolbarItemsNib = [[NSNib alloc] initWithNibNamed:@"IFImageViewToolbarItems" bundle:nil];
  NSArray* nibObjects = nil;
  BOOL nibOk = [toolbarItemsNib instantiateNibWithOwner:proxy topLevelObjects:&nibObjects];
  NSAssert1(nibOk, @"error during nib instantiation %@", toolbarItemsNib);

  NSArray* topLevelViews = (NSArray*)[[nibObjects select] __isKindOfClass:[NSView class]];
  NSAssert([topLevelViews count] == 1, @"incorrect number of views in Nib");
  toolbarItems = [[topLevelViews objectAtIndex:0] retain];

  NSToolbar* toolbar = [[[NSToolbar alloc] initWithIdentifier:@"IFImageView"] autorelease];
  [toolbar setAllowsUserCustomization:YES];
  [toolbar setDelegate:self];
  [[self window] setToolbar:toolbar];
}

- (IFImageViewController*)imageViewController;
{
  return imageViewController;
}

- (NSRect)windowWillUseStandardFrame:(NSWindow*)window defaultFrame:(NSRect)defaultFrame;
{
  // TODO take settings sub-view into account, as well as sliders (if possible)
  NSView* imageView = [imageViewController activeView];
  NSRect windowFrame = [window frame];
  NSSize visibleViewSize = [imageView visibleRect].size;
  NSSize idealViewSize = [imageView bounds].size;
  NSSize minSize = [window minSize];

  float deltaW = fmax(idealViewSize.width - visibleViewSize.width,  minSize.width - NSWidth(windowFrame));
  float deltaH = fmax(idealViewSize.height - visibleViewSize.height, minSize.height - NSHeight(windowFrame));

  windowFrame.size.width += deltaW;
  windowFrame.size.height += deltaH;
  windowFrame.origin.y -= deltaH;
  return windowFrame;
}

- (void)documentDidChange:(NSNotification*)notification;
{
  IFDocument* newDocument = [[notification userInfo] objectForKey:IFNewDocumentKey];
  if (newDocument == (id)[NSNull null]) newDocument = nil;
  [self setCurrentDocument:newDocument];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context;
{
  if (context == IFActiveViewDidChange) {
    [hudWindowController setUnderlyingView:[imageViewController activeView]];
  } else if (context == IFImageViewModeDidChange) {
    [hudWindowController setVisible:([imageViewController mode] == IFImageViewModeEdit)];
  } else if (context == IFCanvasBoundsDidChange) {
    [imageViewController setCanvasBounds:[currentDocument canvasBounds]];
  } else
    NSAssert1(NO, @"unexpected context %@", context);
}

#pragma mark Toolbar

- (NSArray*)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar;
{
  return [NSArray arrayWithObjects:
    IFToolbarModeItemIdentifier,
    IFToolbarVariantItemIdentifier,
    IFToolbarLockedItemIdentifier,
    NSToolbarCustomizeToolbarItemIdentifier,
    NSToolbarFlexibleSpaceItemIdentifier,
    NSToolbarSpaceItemIdentifier,
    NSToolbarSeparatorItemIdentifier,
    nil];
}

- (NSArray*)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar;
{
  return [NSArray arrayWithObjects:
    IFToolbarModeItemIdentifier,
    IFToolbarVariantItemIdentifier,
    IFToolbarLockedItemIdentifier,
    NSToolbarFlexibleSpaceItemIdentifier,
    NSToolbarCustomizeToolbarItemIdentifier,
    nil];
}

- (NSToolbarItem*)toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString*)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;
{
  if ([itemIdentifier isEqualToString:IFToolbarModeItemIdentifier]) {
    if (modeToolbarItem == nil) {
      modeToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:IFToolbarModeItemIdentifier];
      [modeToolbarItem setLabel:@"Mode"];
      [modeToolbarItem setPaletteLabel:@"Mode"];
      NSView* modeItemView = [[toolbarItems viewWithTag:0] retain];
      [modeItemView removeFromSuperview];
      [modeToolbarItem setView:modeItemView];
      [modeToolbarItem setMinSize:[modeItemView bounds].size];
      [modeItemView release];
    }
    return modeToolbarItem;
  } else if ([itemIdentifier isEqualToString:IFToolbarVariantItemIdentifier]) {
    if (variantToolbarItem == nil) {
      variantToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:IFToolbarVariantItemIdentifier];
      [variantToolbarItem setLabel:@"Variant"];
      [variantToolbarItem setPaletteLabel:@"Variant"];
      NSView* variantItemView = [[toolbarItems viewWithTag:1] retain];
      [variantItemView removeFromSuperview];
      [variantToolbarItem setView:variantItemView];
      [variantToolbarItem setMinSize:[variantItemView bounds].size];
      [variantItemView release];
    }
    return variantToolbarItem;    
  } else if ([itemIdentifier isEqualToString:IFToolbarLockedItemIdentifier]) {
    if (lockedToolbarItem == nil) {
      lockedToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:IFToolbarLockedItemIdentifier];
      [lockedToolbarItem setLabel:@"Locked"];
      [lockedToolbarItem setPaletteLabel:@"Locked"];
      NSView* lockedItemView = [[toolbarItems viewWithTag:2] retain];
      [lockedItemView removeFromSuperview];
      [lockedToolbarItem setView:lockedItemView];
      [lockedToolbarItem setMinSize:[lockedItemView bounds].size];
      [lockedItemView release];
    }
    return lockedToolbarItem;
  } else
    return nil;
}

@end

@implementation IFImageInspectorWindowController (Private)

- (void)setCurrentDocument:(IFDocument*)newDocument;
{
  if (newDocument == currentDocument)
    return;

  if (currentDocument != nil) {
    [currentDocument removeObserver:self forKeyPath:@"canvasBounds"];
    [currentDocument release];
  }
  if (newDocument != nil) {
    [newDocument addObserver:self forKeyPath:@"canvasBounds" options:0 context:IFCanvasBoundsDidChange];
    [newDocument retain];
    
    IFExpressionEvaluator* evaluator = [newDocument evaluator];
    [hudWindowController setEvaluator:evaluator];
    [imageViewController setEvaluator:evaluator];

    NSArray* controllers = [newDocument windowControllers];
    NSAssert([controllers count] == 1, @"unexpected number of controllers");
    IFTreeCursorPair* cursors = [(IFTreeViewWindowController*)[controllers objectAtIndex:0] cursorPair];
    [hudWindowController setCursorPair:cursors];
    [imageViewController setCursorPair:cursors];
    
    [imageViewController setCanvasBounds:[newDocument canvasBounds]];
  } else {
    [hudWindowController setEvaluator:nil];
    [imageViewController setEvaluator:nil];
    [hudWindowController setCursorPair:nil];
    [imageViewController setCursorPair:nil];
  }
  currentDocument = newDocument;
}

@end
