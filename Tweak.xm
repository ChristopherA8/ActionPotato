@interface LevelScoreElem : NSObject
@property (nonatomic, readwrite, assign) int score;
@property (nonatomic, readwrite, strong) NSDate *date;
@end

int customScore = 0;
BOOL alertShown = NO;

@interface ScoreToolViewController : UIViewController
// %new
-(void)setScoreButtonPressed;
@end

@interface MyAppCore
-(BOOL)webSubmitScore:(id)arg1 levelId:(int)arg2 highScore:(id)arg3 useHs:(BOOL)arg4;
-(void)startGameView;
@end

%hook ScoreToolViewController
-(void)viewDidAppear:(BOOL)animated {

    if (!alertShown) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Custom Score" message:@"Press the Set Score button to submit a fake leaderboard score" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:ok];
        [self presentViewController:alertController animated:YES completion:nil];
        alertShown = YES;
    }

    return %orig;
}

-(void)viewDidLoad {

    UIButton *setScoreButton = [[UIButton alloc] init];
    [setScoreButton addTarget:self action:@selector(setScoreButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [setScoreButton setTitle:@"Set Score" forState:UIControlStateNormal];
    setScoreButton.backgroundColor = [UIColor colorWithRed: 0.44 green: 0.50 blue: 0.56 alpha: 1.00];
    [setScoreButton setTitleColor:[UIColor colorWithRed: 0.25 green: 0.41 blue: 0.88 alpha: 1.00] forState:UIControlStateHighlighted];
    setScoreButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    setScoreButton.layer.cornerRadius = 10;
    setScoreButton.layer.cornerCurve = kCACornerCurveContinuous;
    setScoreButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:setScoreButton];

	[NSLayoutConstraint activateConstraints:@[
		[setScoreButton.widthAnchor constraintEqualToConstant:80],
		[setScoreButton.heightAnchor constraintEqualToConstant:40],
		[setScoreButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:15],
		[setScoreButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:30]
	]];

    %orig;
}

%new
-(void)setScoreButtonPressed {
    NSLog(@"Score Button Pressed");

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Custom Score" message:@"Enter a fake leaderboard score" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Custom Leaderboard Score";
        textField.secureTextEntry = NO;
    }];
    // UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Submit to Leaderboard" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *customScoreField = alertController.textFields.firstObject;
        if (![customScoreField.text isEqualToString:@""] && ([customScoreField.text intValue] > 0)) {
            customScore = [customScoreField.text intValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"setCustomScore" object:self];
        } else {
                UIAlertController *errorController = [UIAlertController alertControllerWithTitle:@"Invalid Score" message:@"Must be integer greater than 1" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil];
                [errorController addAction:ok];
                [self presentViewController:errorController animated:YES completion:nil];
        }
    }];

    // [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];

}

%end

%hook MyAppCore

-(void)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webSubmitScore: levelId: highScore: useHs:) name:@"setCustomScore" object:nil];
    %orig;
}

-(BOOL)webSubmitScore:(id)arg1 levelId:(int)arg2 highScore:(id)arg3 useHs:(BOOL)arg4 {
    if (customScore == 0) {
        return %orig;
    } 

    LevelScoreElem *myScore = [[%c(LevelScoreElem) alloc] init];
    myScore.score = customScore;
    // Largest int is 0x7FFFFFFF
    myScore.date = [NSDate date];

    return %orig(myScore, 1, nil, 0);
}

-(void)dealloc {
	%orig;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

%end