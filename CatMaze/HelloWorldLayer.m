//
//  HelloWorldLayer.m
//  CatMaze
//
//  Created by Ray Wenderlich on 6/7/11.
//  Copyright Ray Wenderlich 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "CatSprite.h"
#import "SimpleAudioEngine.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (BOOL)isValidTileCoord:(CGPoint)tileCoord {
    if (tileCoord.x < 0 || tileCoord.y < 0 || 
        tileCoord.x >= _tileMap.mapSize.width ||
        tileCoord.y >= _tileMap.mapSize.height) {
        return FALSE;
    } else {
        return TRUE;
    }
}

- (CGPoint)tileCoordForPosition:(CGPoint)position {
    int x = position.x / _tileMap.tileSize.width;
    int y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - position.y) / _tileMap.tileSize.height;
    return ccp(x, y);
}

- (CGPoint)positionForTileCoord:(CGPoint)tileCoord {
    int x = (tileCoord.x * _tileMap.tileSize.width) + _tileMap.tileSize.width/2;
    int y = (_tileMap.mapSize.height * _tileMap.tileSize.height) - (tileCoord.y * _tileMap.tileSize.height) - _tileMap.tileSize.height/2;
    return ccp(x, y);
}

-(BOOL)isProp:(NSString*)prop atTileCoord:(CGPoint)tileCoord forLayer:(CCTMXLayer *)layer {
    if (![self isValidTileCoord:tileCoord]) return NO;
    int gid = [layer tileGIDAt:tileCoord];
    NSDictionary * properties = [_tileMap propertiesForGID:gid];
    if (properties == nil) return NO;    
    return [properties objectForKey:prop] != nil;
}

-(BOOL)isWallAtTileCoord:(CGPoint)tileCoord {
    return [self isProp:@"Wall" atTileCoord:tileCoord forLayer:_bgLayer];
}

-(BOOL)isBoneAtTilecoord:(CGPoint)tileCoord {
    return [self isProp:@"Bone" atTileCoord:tileCoord forLayer:_objectLayer];
}

-(BOOL)isDogAtTilecoord:(CGPoint)tileCoord {
    return [self isProp:@"Dog" atTileCoord:tileCoord forLayer:_objectLayer];
}

-(BOOL)isExitAtTilecoord:(CGPoint)tileCoord {
    return [self isProp:@"Exit" atTileCoord:tileCoord forLayer:_objectLayer];
}

-(void)removeObjectAtTileCoord:(CGPoint)tileCoord {
    [_objectLayer removeTileAt:tileCoord];
}

-(void)setViewpointCenter:(CGPoint) position {
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    int x = MAX(position.x, winSize.width / 2);
    int y = MAX(position.y, winSize.height / 2);
    x = MIN(x, (_tileMap.mapSize.width * _tileMap.tileSize.width) 
            - winSize.width / 2);
    y = MIN(y, (_tileMap.mapSize.height * _tileMap.tileSize.height) 
            - winSize.height/2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    
    _tileMap.position = viewPoint;
    
}

- (void)restartTapped:(id)sender {
    
    // Reload the current scene
    CCScene *scene = [HelloWorldLayer scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:scene]];
    
}

- (void)showRestartMenu {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSString *message;
    if (_won) {
        message = [NSString stringWithFormat:@"You win!", _cat.numBones];
    } else {
        message = @"You lose!";
    }
    
    CCLabelBMFont *label;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        label = [CCLabelBMFont labelWithString:message fntFile:@"Arial-hd.fnt"];
    } else {
        label = [CCLabelBMFont labelWithString:message fntFile:@"Arial.fnt"];
    }
    label.scale = 0.1;
    label.position = ccp(winSize.width/2, winSize.height * 0.6);
    [self addChild:label];
    
    CCLabelBMFont *restartLabel;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"Arial-hd.fnt"];    
    } else {
        restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"Arial.fnt"];    
    }
    
    CCMenuItemLabel *restartItem = [CCMenuItemLabel itemWithLabel:restartLabel target:self selector:@selector(restartTapped:)];
    restartItem.scale = 0.1;
    restartItem.position = ccp(winSize.width/2, winSize.height * 0.4);
    
    CCMenu *menu = [CCMenu menuWithItems:restartItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu z:10];
    
    [restartItem runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    [label runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    
}

- (void)endScene {
    [_cat runAction:[CCSequence actions:
                     [CCScaleBy actionWithDuration:0.5 scale:3.0],
                     [CCDelayTime actionWithDuration:1.0],
                     [CCScaleTo actionWithDuration:0.5 scale:0],
                     [CCCallFunc actionWithTarget:self selector:@selector(showRestartMenu)],
                     nil]];
    [_cat runAction:[CCRepeatForever actionWithAction:
                     [CCRotateBy actionWithDuration:0.5 angle:360]]]; 
}

- (void)winGame {
    _gameOver = TRUE;
    _won = TRUE;
    [[SimpleAudioEngine sharedEngine] playEffect:@"win.wav"];
    [self endScene];
}

- (void)loseGame {
    _gameOver = TRUE;
    _won = FALSE;
    [[SimpleAudioEngine sharedEngine] playEffect:@"lose.wav"];
    [self endScene];
}

- (void)showNumBones:(int)numBones {
    
    [_bonesCount setString:[NSString stringWithFormat:@"Bones: %d", numBones]];
    
}

- (NSArray *)walkableAdjacentTilesCoordForTileCoord:(CGPoint)tileCoord
{
	NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:8];
    
    BOOL t = NO;
    BOOL l = NO;
    BOOL b = NO;
    BOOL r = NO;
	
	// Top
	CGPoint p = CGPointMake(tileCoord.x, tileCoord.y - 1);
	if ([self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
        t = YES;
	}
	
	// Left
	p = CGPointMake(tileCoord.x - 1, tileCoord.y);
	if ([self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
        l = YES;
	}
	
	// Bottom
	p = CGPointMake(tileCoord.x, tileCoord.y + 1);
	if ([self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
        b = YES;
	}
	
	// Right
	p = CGPointMake(tileCoord.x + 1, tileCoord.y);
	if ([self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
        r = YES;
	}
    
    
	// Top Left
	p = CGPointMake(tileCoord.x - 1, tileCoord.y - 1);
	if (t && l && [self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
	
	// Bottom Left
	p = CGPointMake(tileCoord.x - 1, tileCoord.y + 1);
	if (b && l && [self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
	
	// Top Right
	p = CGPointMake(tileCoord.x + 1, tileCoord.y - 1);
	if (t && r && [self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
	
	// Bottom Right
	p = CGPointMake(tileCoord.x + 1, tileCoord.y + 1);
	if (b && r && [self isValidTileCoord:p] && ![self isWallAtTileCoord:p]) {
		[tmp addObject:[NSValue valueWithCGPoint:p]];
	}
    
    
	return [NSArray arrayWithArray:tmp];
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
        _tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"CatMaze.tmx"];        
		[self addChild:_tileMap];
        
        CGPoint spawnTileCoord = ccp(24,0);
        CGPoint spawnPos = [self positionForTileCoord:spawnTileCoord];
        [self setViewpointCenter:spawnPos];
        
        //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"SuddenDefeat.mp3" loop:YES];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"pickup.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"catAttack.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"hitWall.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"lose.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"step.wav"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"win.wav"];  
        
        _bgLayer = [_tileMap layerNamed:@"Background"];
        _objectLayer = [_tileMap layerNamed:@"Objects"];

        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"CatMaze.plist"];
        _batchNode = [CCSpriteBatchNode batchNodeWithFile:@"CatMaze.png"];
        [_tileMap addChild:_batchNode];        
        _cat = [[[CatSprite alloc] initWithLayer:self] autorelease];
        _cat.position = spawnPos;
        [_batchNode addChild:_cat];
        
        _bonesCount = [CCLabelBMFont labelWithString:@"Bones: 0" fntFile:@"Arial.fnt"];
        _bonesCount.position = ccp(400, 30);
        [self addChild:_bonesCount];
        
        self.isTouchEnabled = YES;
        [self scheduleUpdate];
        
	}
	return self;
}

- (void)registerWithTouchDispatcher {
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (_gameOver) return NO;
    
    CGPoint touchLocation = [_tileMap convertTouchToNodeSpace:touch];
    [_cat moveToward:touchLocation];
    return YES;
}

- (void)update:(ccTime)dt {
    
    [self setViewpointCenter:_cat.position];
    
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
