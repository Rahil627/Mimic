//
//  Library.h
//  Mime
//
//  Created by Rahil Patel on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Library : NSObject

+ (BOOL)isOffScreenWithPoint:(CGPoint)p;
+ (BOOL)isOffScreenWithCCSprite:(CCSprite*)sprite;

@end