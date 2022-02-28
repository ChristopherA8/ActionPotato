@interface LevelScoreElem : NSObject
@property (nonatomic, readwrite, assign) int score;
@property (nonatomic, readwrite, strong) NSDate *date;
@end

@interface ScoreToolViewController : UIViewController
-(void)setScoreButtonPressed;
@end

@interface MyAppCore
-(BOOL)webSubmitScore:(id)arg1 levelId:(int)arg2 highScore:(id)arg3 useHs:(BOOL)arg4;
-(void)startGameView;
@end

int customScore = 0;
BOOL alertShown = NO;