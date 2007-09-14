//
//  IFFileSource.m
//  ImageFlow
//
//  Created by Michel Schinz on 12.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFFileSource.h"

#import "IFEnvironment.h"
#import "IFFunType.h"
#import "IFBasicType.h"
#import "IFImageType.h"
#import "IFVariableExpression.h"

@implementation IFFileSource

- (NSArray*)potentialTypes;
{
  static NSArray* types = nil;
  if (types == nil)
    types = [[NSArray arrayWithObject:[IFImageType imageRGBAType]] retain];
  return types;
}

- (NSArray*)potentialRawExpressions;
{
  static NSArray* exprs = nil;
  if (exprs == nil) {
    exprs = [[NSArray arrayWithObject:
      [IFOperatorExpression expressionWithOperator:[IFOperator operatorForName:@"load"]
                                          operands:[NSArray arrayWithObjects:
                                            [IFVariableExpression expressionWithName:@"fileName"],
                                            [IFVariableExpression expressionWithName:@"useEmbeddedProfile"],
                                            [IFVariableExpression expressionWithName:@"defaultRGBProfileFileName"],
                                            [IFVariableExpression expressionWithName:@"defaultGrayProfileFileName"],
                                            [IFVariableExpression expressionWithName:@"defaultCMYKProfileFileName"],
                                            [IFVariableExpression expressionWithName:@"useEmbeddedResolution"],
                                            [IFVariableExpression expressionWithName:@"useDocumentResolutionAsDefault"],
                                            [IFVariableExpression expressionWithName:@"defaultResolutionX"],
                                            [IFVariableExpression expressionWithName:@"defaultResolutionY"],
                                            nil]]] retain];
  }
  return exprs;
}

- (NSString*)label;
{
  return [NSString stringWithFormat:@"load %@",[[environment valueForKey:@"fileName"] lastPathComponent]];
}

- (NSString*)toolTip;
{
  return [NSString stringWithFormat:@"load %@",[environment valueForKey:@"fileName"]];
}

@end
