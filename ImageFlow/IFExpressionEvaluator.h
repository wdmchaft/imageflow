//
//  IFExpressionEvaluator.h
//  ImageFlow
//
//  Created by Michel Schinz on 02.10.06.
//  Copyright 2006 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFConstantExpression.h"
#import "IFImageConstantExpression.h"

@interface IFExpressionEvaluator : NSObject {
  CGColorSpaceRef workingColorSpace;
  float resolutionX, resolutionY;
  value cache;
}

- (CGColorSpaceRef)workingColorSpace;
- (void)setWorkingColorSpace:(CGColorSpaceRef)newWorkingColorSpace;

- (float)resolutionX;
- (void)setResolutionX:(float)newResolution;
- (float)resolutionY;
- (void)setResolutionY:(float)newResolution;

- (IFConstantExpression*)evaluateExpression:(IFExpression*)expression;
- (IFConstantExpression*)evaluateExpressionAsImage:(IFExpression*)expression;
- (IFConstantExpression*)evaluateExpressionAsMaskedImage:(IFExpression*)expression cutout:(NSRect)cutoutRect;
- (NSRect)deltaFromOld:(IFExpression*)oldExpression toNew:(IFExpression*)newExpression;

@end
