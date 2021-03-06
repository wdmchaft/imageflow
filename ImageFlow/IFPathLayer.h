//
//  IFPathLayer.h
//  ImageFlow
//
//  Created by Michel Schinz on 21.06.09.
//  Copyright 2009 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IFPathLayer : CALayer {
  CGPathRef path;
  float lineWidth;
  CGColorRef strokeColor;
  CGColorRef fillColor;
}

@property(nonatomic) CGPathRef path;
@property float lineWidth;
@property(nonatomic) CGColorRef strokeColor;
@property(nonatomic) CGColorRef fillColor;

@end
