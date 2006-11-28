//
//  IFImageInspectorWindowController.h
//  ImageFlow
//
//  Created by Michel Schinz on 08.08.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFDocument.h"
#import "IFImageViewController.h"
#import "IFHUDWindowController.h"

@interface IFImageInspectorWindowController : NSWindowController {
  IFDocument* currentDocument;
  IFImageViewController* imageViewController;
  IFHUDWindowController* hudWindowController;

  // Toolbar
  NSValue* proxy;
  NSView* toolbarItems;
  NSToolbarItem* modeToolbarItem;
  NSToolbarItem* variantToolbarItem;
  NSToolbarItem* lockedToolbarItem;
}

- (IFImageViewController*)imageViewController;

@end
