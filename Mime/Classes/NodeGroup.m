//
//  NodeGroup.m
//  Mime
//
//  Created by Rahil Patel on 6/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "NodeGroup.h"
#import "Node.h"
#import "GameManager.h"
#import "Library.h"

@implementation NodeGroup

#pragma mark - overridden functions
+ (id)nodeGroup {
    return [[[self alloc] nodeGroup] autorelease];
}

- (id)nodeGroup {
	if (!(self = [super init]))
		return nil;
    
    lineColor = ccc4f(CCRANDOM_0_1(), CCRANDOM_0_1(), CCRANDOM_0_1(), 1);
    
    return self;
}

- (void)draw {
    if ([[self children] count] < 1)
        return;
    
//    // draw single node
//    if ([[self children] count] == 1) {
//        // draw a point
//        CGPoint p = ((CCNode*)[[self children] objectAtIndex:0]).position;
//        ccDrawColor4F(0, 1, 0, 1);
//        ccDrawSolidCircle(p, NODE_SIZE/2, 90, 50, NO);
//        return;
//    }
    
    // draw circle for each point
    CGPoint p;
    for (int i = 0; i < [[self children] count]; i++) {
        p = ((CCNode*)[[self children] objectAtIndex:i]).position;
        if (IS_DEBUGGING) {
            ccDrawColor4F(lineColor.r, lineColor.g, lineColor.b, lineColor.a);
            ccDrawCircle(p, NODE_SIZE/2, 90, 10, NO);
        }
        else {
            ccDrawColor4F(lineColor.r, lineColor.g, lineColor.b, lineColor.a);
            ccDrawSolidCircle(p, NODE_SIZE/2, 90, 10, NO);
        }
    }
    
    //GLfloat v;
    //glGetFloatv(GL_ALIASED_LINE_WIDTH_RANGE, &v); // todo: limitation: max line width is 1
    //CCLOG(@"v: %f", v);
    //glDisable(GL_LINE_SMOOTH); // does not exist in OpenGL 2.0?
    // may just need to draw a rectangle, which will be used for detecting touches anyway
    
    if ([[self children] count] == 1)
        return;
    
    // draw a rectangle between each point
    CGPoint p1, p2, vertices[4];
    for (int i = 0; i < [[self children] count] - 1; i++) {
        p1 = ((CCNode*)[[self children] objectAtIndex:i]).position;
        p2 = ((CCNode*)[[self children] objectAtIndex:i + 1]).position;
        
        if (IS_DEBUGGING) {
            ccDrawColor4F(lineColor.r, lineColor.g, lineColor.b, lineColor.a);
            [self getRectangleVerticesWithPoint1:p1 point2:p2 arrayToStoreIn:vertices];
            ccDrawPoly(vertices, 4, YES);
        }
        else {
            // draw line
//            ccDrawColor4F(lineColor.r, lineColor.g, lineColor.b, lineColor.a);
//            glLineWidth(NODE_SIZE);
//            ccDrawLine(p1, p2);
            
            // draw solid poly
            [self getRectangleVerticesWithPoint1:p1 point2:p2 arrayToStoreIn:vertices];
            ccDrawPoly(vertices, 4, YES);
            ccDrawSolidPoly(vertices, 4, lineColor);
        }
    }
    
    [super draw];
}

#pragma mark - touch handlers
- (void)onEnter {
	CCDirector *director =  [CCDirector sharedDirector];
    
	[[director touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit {
	CCDirector *director = [CCDirector sharedDirector];
    
	[[director touchDispatcher] removeDelegate:self];
	[super onExit];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    //CGPoint touchPoint = [touch locationInView:[touch view]];
    //touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    //CCLOG(@"touchPoint (%f, %f)", touchPoint.x, touchPoint.y);
    //CCLOG(@"hitbox: (%f, %f)", hitbox.origin.x, hitbox.origin.y);
    //CCLOG(@"nodespace (%f, %f), nodespaceAR (%f, %f)", [self convertTouchToNodeSpace:touch].x, [self convertTouchToNodeSpace:touch].y,[self convertTouchToNodeSpaceAR:touch].x, [self convertTouchToNodeSpaceAR:touch].y);
    
    // if single
    
    // if line
    
    // if touch began on first node
    CGPoint touchPoint = [self convertTouchToNodeSpaceAR:touch];
    
    for (int i = 0; i < [[self children] count]; i++) {
        Node* n = (Node*)[[self children] objectAtIndex:i];
        
        if (n.type == kFirst) { // todo: optimize: just access the first child
            CGRect hitbox = CGRectMake(n.position.x - NODE_SIZE/2, n.position.y - NODE_SIZE/2, NODE_SIZE, NODE_SIZE);
            
            if ((CGRectContainsPoint(hitbox, touchPoint))) {
                CCLOG(@"first point touched!");
                //[self removeFromParentAndCleanup:YES]; // if missed beginning point, change color
                return YES;
            }
        }
    }
    
    return NO; // claim touch?
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event { // hmmmm, may be better to have a single touch and check multiple sprite groups
    
    if ([[self children] count] < 1)
        return;
    
    CGPoint touchPoint = [self convertTouchToNodeSpaceAR:touch];
    
    // todo: sloppy implementation, checks entire nodegroup
    // todo: if touch is within the current node's hitbox or the current space between two nodes
    CGPoint p;
    for (int i = 0; i < [[self children] count]; i++) {
        p = ((CCNode*)[[self children] objectAtIndex:i]).position;
        
        // if touching node
        CGRect nodeHitbox = CGRectMake(p.x - NODE_SIZE/2, p.y - NODE_SIZE/2, NODE_SIZE, NODE_SIZE);
        
        if ((CGRectContainsPoint(nodeHitbox, touchPoint))) {
            //CCLOG(@"touching a node");
            return;
        }
        
    }
    
    if ([[self children] count] == 1)
        return;
    
    // if touching between two nodes
    CGPoint p1, p2, v[4];
    for (int i = 0; i < [[self children] count] - 1; i++) {
        p1 = ((CCNode*)[[self children] objectAtIndex:i]).position;
        p2 = ((CCNode*)[[self children] objectAtIndex:i + 1]).position;
        
        [self getRectangleVerticesWithPoint1:p1 point2:p2 arrayToStoreIn:v];
        if ([self isPointInRectangleWithVertices:v point:touchPoint]) {
            //CCLOG(@"touching space between two nodes");
            return;
        }
    }
    
    CCLOG(@"you lose, good day sir!");
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    // if touch ended on last node
    for (int i = 0; i < [[self children] count]; i++) {
        Node* n = (Node*)[[self children] objectAtIndex:i];
        
        if (n.type == kLast) { // todo: optimize: just access the last child
            CGRect hitbox = CGRectMake(n.position.x - NODE_SIZE/2, n.position.y - NODE_SIZE/2, NODE_SIZE, NODE_SIZE);
            
            if ((CGRectContainsPoint(hitbox, [self convertTouchToNodeSpaceAR:touch]))) {
                CCLOG(@"successfully ended touch on last node");
            }
        }
    }
    
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    
}

#pragma mark - private functions
// pass in a C-array
- (void)getRectangleVerticesWithPoint1:(CGPoint)p1 point2:(CGPoint)p2 arrayToStoreIn:(CGPoint *) a {
    // create angled rectangle between two points // todo: could create a single polygon
    // http://www.cocos2d-iphone.org/forum/topic/17387
    // also see CGAffineTransform
    
    CGPoint bottomLeftPoint, topLeftPoint, topRightPoint, bottomRightPoint;
    CGFloat hWidth, hHeight, _xpos, _ypos, tX, tY, rad;
    
    // hWidth, hHeight = half the rectangle's width & height
    hWidth = (ccpDistance(p1, p2)/2 > NODE_SIZE/2) ? ccpDistance(p1, p2)/2 : NODE_SIZE/2; // minimum width = node size
    hHeight = NODE_SIZE/2;
    
    // _xpos, _ypos = center position of the rectangle
    //Midpoint AB = (x1 + x2) /2 , (y1 + y2)/2
    _xpos = (p1.x + p2.x)/2;
    _ypos = (p1.y + p2.y)/2;
    
    rad = -ccpAngle(p1, p2);
    if (p1.x > p2.x) // drawing from right to left
        rad = -rad;
    
    tX = -(hWidth * cosf(rad) - hHeight * sinf(rad) ) + _xpos;
    tY = -(hWidth * sinf(rad) + hHeight * cosf(rad) ) + _ypos;
    bottomLeftPoint = ccp(tX, tY);
    
    tX = -(hWidth * cosf(rad) + hHeight * sinf(rad) ) + _xpos;
    tY = -(hWidth * sinf(rad) - hHeight * cosf(rad) ) + _ypos;
    topLeftPoint = ccp(tX, tY);
    
    tX = (hWidth * cosf(rad) - hHeight * sinf(rad) ) + _xpos;
    tY = (hWidth * sinf(rad) + hHeight * cosf(rad) ) + _ypos;
    topRightPoint = ccp(tX, tY);
    
    tX = (hWidth * cosf(rad) + hHeight * sinf(rad) ) + _xpos;
    tY = (hWidth * sinf(rad) - hHeight * cosf(rad) ) + _ypos;
    bottomRightPoint = ccp(tX, tY);
    
    //ccDrawSolidRect(rp2, rp4, lineColor); // only use to draw non-angled rectangles
    // CGRect is also useless
    
    a[0] = topLeftPoint;
    a[1] = topRightPoint;
    a[2] = bottomRightPoint;
    a[3] = bottomLeftPoint;
}

- (BOOL)isPointInRectangleWithVertices:(CGPoint *)v point:(CGPoint)p {
    float x[4], y[4];
    
    x[0] = v[0].x;
    x[1] = v[1].x;
    x[2] = v[2].x;
    x[3] = v[3].x;
    
    y[0] = v[0].y;
    y[1] = v[1].y;
    y[2] = v[2].y;
    y[3] = v[3].y;
    
    return [Library isPointInPolygonWithNumberOfVerticies:4 xVerticies:x yVerticies:y testPointX:p.x testPointY:p.y]; // BOOL == int?
}

@end
