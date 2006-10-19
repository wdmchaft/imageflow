//
//  IFMaskThresholdCIFilter.h
//  ImageFlow
//
//  Created by Michel Schinz on 19.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFMaskThresholdCIFilter : CIFilter {
  CIImage* inputImage;
  NSNumber* inputThreshold;
}

@end
