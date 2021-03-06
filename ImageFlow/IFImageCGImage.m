//
//  IFImageCGImage.m
//  ImageFlow
//
//  Created by Michel Schinz on 03.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import "IFImageCGImage.h"


@implementation IFImageCGImage

- (id)initWithCGImage:(CGImageRef)theImage kind:(IFImageKind)theKind;
{
  if (![super initWithKind:theKind])
    return nil;
  image = theImage;
  CGImageRetain(image);
  ciImage = nil;
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(ciImage);
  CGImageRelease(image);
  image = NULL;
  [super dealloc];
}

- (CGRect)extent;
{
  return CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image));
}

- (CIImage*)imageCI;
{
  if (ciImage == nil)
    ciImage = [[CIImage imageWithCGImage:image] retain];
  return ciImage;
}

- (BOOL)isLocked;
{
  return [self retainCount] > 1 || CFGetRetainCount(image) > 1 || (ciImage != nil && [ciImage retainCount] > 1);
}

@end
