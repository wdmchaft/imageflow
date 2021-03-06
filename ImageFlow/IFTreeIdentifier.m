//
//  IFTreeIdentifier.m
//  ImageFlow
//
//  Created by Michel Schinz on 28.12.05.
//  Copyright 2005 Michel Schinz. All rights reserved.
//

#import "IFTreeIdentifier.h"

@interface IFTreeIdentifier (Private)
- (void)identifyTree:(IFTree*)tree startingAt:(IFTreeNode*)root usingOnlyHints:(NSDictionary*)hints freeIndices:(NSMutableIndexSet*)freeIndices accumulator:(NSMutableDictionary*)accumulator;
- (void)identifyTree:(IFTree*)tree startingAt:(IFTreeNode*)root freeIndices:(NSMutableIndexSet*)freeIndices accumulator:(NSMutableDictionary*)accumulator;
@end


@implementation IFTreeIdentifier

+ (id)treeIdentifier;
{
  return [[[self alloc] init] autorelease];
}

- (NSDictionary*)identifyTree:(IFTree*)tree startingAt:(IFTreeNode*)root hints:(NSDictionary*)hints;
{
  NSMutableIndexSet* freeIndices = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0,10000000)];
  NSMutableDictionary* result = [NSMutableDictionary dictionary];
  [self identifyTree:tree startingAt:root usingOnlyHints:hints freeIndices:freeIndices accumulator:result];
  [self identifyTree:tree startingAt:root freeIndices:freeIndices accumulator:result];
  return result;
}

@end

@implementation IFTreeIdentifier (Private)

- (void)identifyTree:(IFTree*)tree startingAt:(IFTreeNode*)root usingOnlyHints:(NSDictionary*)hints freeIndices:(NSMutableIndexSet*)freeIndices accumulator:(NSMutableDictionary*)accumulator;
{
  NSValue* boxedRoot = [NSValue valueWithPointer:root];
  NSNumber* hint = [hints objectForKey:boxedRoot];
  if (hint != nil && [freeIndices containsIndex:[hint intValue]]) {
    [accumulator setObject:hint forKey:boxedRoot];
    [freeIndices removeIndex:[hint intValue]];
  }
  for (IFTreeNode* parent in [tree parentsOfNode:root])
    [self identifyTree:tree startingAt:parent usingOnlyHints:hints freeIndices:freeIndices accumulator:accumulator];
}

- (void)identifyTree:(IFTree*)tree startingAt:(IFTreeNode*)root freeIndices:(NSMutableIndexSet*)freeIndices accumulator:(NSMutableDictionary*)accumulator;
{
  NSValue* boxedRoot = [NSValue valueWithPointer:root];
  if ([accumulator objectForKey:boxedRoot] == nil) {
    int index = [freeIndices firstIndex];
    [accumulator setObject:[NSNumber numberWithInt:index] forKey:boxedRoot];
    [freeIndices removeIndex:index];
  }
  for (IFTreeNode* parent in [tree parentsOfNode:root])
    [self identifyTree:tree startingAt:parent freeIndices:freeIndices accumulator:accumulator];
}

@end
