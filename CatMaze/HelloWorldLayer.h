//
//  HelloWorldLayer.h
//  CatMaze
//
//  Created by Ray Wenderlich on 6/7/11.
//  Copyright Ray Wenderlich 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

@class CatSprite;

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    CCTMXTiledMap *_tileMap;
    
    CCTMXLayer *_bgLayer;
    CCTMXLayer *_objectLayer; 
    
    CCSpriteBatchNode *_batchNode;
    
    CatSprite *_cat;
    
    BOOL _gameOver;
    BOOL _won;
    
    CCLabelBMFont *_bonesCount;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
- (BOOL)isWallAtTileCoord:(CGPoint)tileCoord;
- (BOOL)isBoneAtTilecoord:(CGPoint)tileCoord;
- (BOOL)isDogAtTilecoord:(CGPoint)tileCoord;
- (BOOL)isExitAtTilecoord:(CGPoint)tileCoord;
- (CGPoint)tileCoordForPosition:(CGPoint)position;
- (CGPoint)positionForTileCoord:(CGPoint)tileCoord;
- (NSArray *)walkableAdjacentTilesCoordForTileCoord:(CGPoint)tileCoord;
- (void)removeObjectAtTileCoord:(CGPoint)tileCoord;
- (void)winGame;
- (void)loseGame;
- (void)showNumBones:(int)numBones;

@end
