//
//  IFExpressionVisitor.h
//  ImageFlow
//
//  Created by Michel Schinz on 30.10.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IFOperatorExpression.h"
#import "IFParentExpression.h"
#import "IFVariableExpression.h"
#import "IFConstantExpression.h"

@interface IFExpressionVisitor : NSObject {

}

- (void)caseOperatorExpression:(IFOperatorExpression*)expression;
- (void)caseParentExpression:(IFParentExpression*)expression;
- (void)caseVariableExpression:(IFVariableExpression*)expression;
- (void)caseConstantExpression:(IFConstantExpression*)expression;

@end
