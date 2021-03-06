//
//  IFTreeTemplate.m
//  ImageFlow
//
//  Created by Michel Schinz on 26.10.07.
//  Copyright 2007 Michel Schinz. All rights reserved.
//

#import "IFTreeTemplate.h"


@implementation IFTreeTemplate

+ (id)templateWithName:(NSString*)theName description:(NSString*)theDescription tree:(IFTree*)theTree;
{
  return [[[self alloc] initWithName:theName description:theDescription tree:theTree] autorelease];
}

- (id)initWithName:(NSString*)theName description:(NSString*)theDescription tree:(IFTree*)theTree;
{
  if (![super init])
    return nil;
  name = [theName copy];
  description = [theDescription copy];
  tree = [theTree retain];
  dirName = nil;
  tag = nil;
  return self;
}

- (void)dealloc;
{
  OBJC_RELEASE(tag);
  OBJC_RELEASE(dirName);

  OBJC_RELEASE(tree);
  OBJC_RELEASE(description);
  OBJC_RELEASE(name);
  [super dealloc];
}

@synthesize name;
@synthesize description;
@synthesize tree;
@synthesize dirName;
@synthesize tag;

- (void)setTag:(NSString*)theTag;
{
  NSAssert(tag == nil, @"tag can only be set once");
  tag = [theTag retain];
}

@end
