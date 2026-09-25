#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface EliteDemoController : UIViewController
@property(nonatomic,strong) UIView *panel;
@property(nonatomic,strong) UIButton *bubble;
@property(nonatomic,strong) UILabel *statusLabel;
@property(nonatomic,strong) UILabel *fpsLabel;
@property(nonatomic,strong) UILabel *scoreLabel;
@property(nonatomic,strong) CADisplayLink *displayLink;
@property(nonatomic,assign) CFTimeInterval lastTimestamp;
@property(nonatomic,assign) NSInteger frameCounter;
@property(nonatomic,assign) BOOL minimized;
@end

@implementation EliteDemoController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithRed:0.01 green:0.015 blue:0.03 alpha:1.0];
    [self buildBackground];
    [self buildBubble];
    [self buildPanel];
    [self startFPSCounter];
}

- (void)buildBackground {
    CAGradientLayer *g = [CAGradientLayer layer];
    g.frame = self.view.bounds;
    g.colors = @[
        (id)[UIColor colorWithRed:0.01 green:0.015 blue:0.03 alpha:1.0].CGColor,
        (id)[UIColor colorWithRed:0.015 green:0.035 blue:0.08 alpha:1.0].CGColor
    ];
    g.startPoint = CGPointMake(0.0, 0.0);
    g.endPoint = CGPointMake(1.0, 1.0);
    [self.view.layer addSublayer:g];

    UILabel *watermark = [[UILabel alloc] initWithFrame:CGRectMake(18, 70, self.view.bounds.size.width - 36, 80)];
    watermark.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    watermark.text = @"SUBWAY SURFERS CITY\nLOCAL / OFFLINE UI DEMO";
    watermark.numberOfLines = 2;
    watermark.textAlignment = NSTextAlignmentCenter;
    watermark.textColor = [UIColor colorWithWhite:1.0 alpha:0.12];
    watermark.font = [UIFont boldSystemFontOfSize:24];
    [self.view addSubview:watermark];
}

- (void)buildBubble {
    self.bubble = [UIButton buttonWithType:UIButtonTypeSystem];
    self.bubble.frame = CGRectMake(18, 170, 58, 58);
    self.bubble.backgroundColor = [UIColor colorWithRed:0.02 green:0.30 blue:1.0 alpha:0.96];
    self.bubble.layer.cornerRadius = 29;
    self.bubble.layer.shadowColor = [UIColor colorWithRed:0.0 green:0.45 blue:1 alpha:1].CGColor;
    self.bubble.layer.shadowOpacity = 0.75;
    self.bubble.layer.shadowRadius = 12;
    self.bubble.layer.shadowOffset = CGSizeZero;
    [self.bubble setTitle:@"EM" forState:UIControlStateNormal];
    [self.bubble setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.bubble.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.bubble addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];

    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragBubble:)];
    [self.bubble addGestureRecognizer:pan];
    [self.view addSubview:self.bubble];
}

- (UILabel *)labelWithText:(NSString *)text frame:(CGRect)frame size:(CGFloat)size bold:(BOOL)bold {
    UILabel *l = [[UILabel alloc] initWithFrame:frame];
    l.text = text;
    l.textColor = UIColor.whiteColor;
    l.font = bold ? [UIFont boldSystemFontOfSize:size] : [UIFont systemFontOfSize:size];
    return l;
}

- (UIView *)separatorAtY:(CGFloat)y width:(CGFloat)width {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(16, y, width - 32, 1)];
    v.backgroundColor = [UIColor colorWithRed:0.10 green:0.30 blue:0.65 alpha:0.65];
    return v;
}

- (void)buildPanel {
    CGFloat width = MIN(self.view.bounds.size.width - 30, 360.0);
    self.panel = [[UIView alloc] initWithFrame:CGRectMake(15, 250, width, 400)];
    self.panel.backgroundColor = [UIColor colorWithRed:0.018 green:0.024 blue:0.05 alpha:0.97];
    self.panel.layer.cornerRadius = 20;
    self.panel.layer.borderWidth = 1.2;
    self.panel.layer.borderColor = [UIColor colorWithRed:0.05 green:0.45 blue:1 alpha:0.95].CGColor;
    self.panel.layer.shadowColor = [UIColor colorWithRed:0.0 green:0.35 blue:1 alpha:1].CGColor;
    self.panel.layer.shadowOpacity = 0.45;
    self.panel.layer.shadowRadius = 16;
    self.panel.layer.shadowOffset = CGSizeZero;

    UIPanGestureRecognizer *panelPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragPanel:)];
    [self.panel addGestureRecognizer:panelPan];

    UILabel *title = [self labelWithText:@"👑 ENACHE MARIUS OFFICIAL"
                                   frame:CGRectMake(14, 12, width - 28, 28)
                                    size:17
                                    bold:YES];
    title.textAlignment = NSTextAlignmentCenter;
    [self.panel addSubview:title];

    UILabel *subtitle = [self labelWithText:@"SUBWAY SURFERS CITY ELITE"
                                      frame:CGRectMake(14, 42, width - 28, 22)
                                       size:12
                                       bold:YES];
    subtitle.textAlignment = NSTextAlignmentCenter;
    subtitle.textColor = [UIColor colorWithRed:0.25 green:0.67 blue:1 alpha:1];
    [self.panel addSubview:subtitle];

    UIButton *minBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    minBtn.frame = CGRectMake(width - 48, 70, 34, 28);
    [minBtn setTitle:@"—" forState:UIControlStateNormal];
    [minBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    minBtn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.08];
    minBtn.layer.cornerRadius = 8;
    [minBtn addTarget:self action:@selector(toggleMinimize) forControlEvents:UIControlEventTouchUpInside];
    [self.panel addSubview:minBtn];

    [self.panel addSubview:[self separatorAtY:108 width:width]];

    UILabel *playerHeader = [self labelWithText:@"PLAYER / DEBUG"
                                          frame:CGRectMake(18, 118, width - 36, 22)
                                           size:12
                                           bold:YES];
    playerHeader.textColor = [UIColor colorWithRed:0.25 green:0.67 blue:1 alpha:1];
    [self.panel addSubview:playerHeader];

    UILabel *scoreText = [self labelWithText:@"ScoreSystem.AddScore ×16"
                                       frame:CGRectMake(20, 150, width - 110, 30)
                                        size:15
                                        bold:YES];
    [self.panel addSubview:scoreText];

    self.scoreLabel = [self labelWithText:@"ACTIVE"
                                    frame:CGRectMake(width - 92, 150, 72, 30)
                                     size:13
                                     bold:YES];
    self.scoreLabel.textAlignment = NSTextAlignmentCenter;
    self.scoreLabel.textColor = UIColor.systemGreenColor;
    self.scoreLabel.backgroundColor = [UIColor colorWithRed:0.05 green:0.32 blue:0.12 alpha:0.30];
    self.scoreLabel.layer.cornerRadius = 8;
    self.scoreLabel.layer.masksToBounds = YES;
    [self.panel addSubview:self.scoreLabel];

    UILabel *fpsText = [self labelWithText:@"FPS Display"
                                     frame:CGRectMake(20, 196, width - 105, 32)
                                      size:15
                                      bold:NO];
    [self.panel addSubview:fpsText];

    UISwitch *fpsSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(width - 72, 194, 52, 32)];
    fpsSwitch.on = YES;
    fpsSwitch.onTintColor = UIColor.systemGreenColor;
    fpsSwitch.tag = 101;
    [fpsSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.panel addSubview:fpsSwitch];

    self.fpsLabel = [self labelWithText:@"FPS: --"
                                  frame:CGRectMake(20, 238, width - 40, 30)
                                   size:15
                                   bold:YES];
    self.fpsLabel.textColor = [UIColor colorWithRed:0.45 green:0.78 blue:1 alpha:1];
    [self.panel addSubview:self.fpsLabel];

    UILabel *debugText = [self labelWithText:@"Debug Information"
                                       frame:CGRectMake(20, 282, width - 105, 32)
                                        size:15
                                        bold:NO];
    [self.panel addSubview:debugText];

    UISwitch *debugSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(width - 72, 280, 52, 32)];
    debugSwitch.on = NO;
    debugSwitch.onTintColor = UIColor.systemGreenColor;
    debugSwitch.tag = 102;
    [debugSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.panel addSubview:debugSwitch];

    self.statusLabel = [self labelWithText:@"🟢 ON"
                                     frame:CGRectMake(20, 332, width - 40, 34)
                                      size:16
                                      bold:YES];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.textColor = UIColor.systemGreenColor;
    [self.panel addSubview:self.statusLabel];

    UILabel *foot = [self labelWithText:@"LOCAL / OFFLINE UI DEMO"
                                  frame:CGRectMake(20, 368, width - 40, 20)
                                   size:10
                                   bold:YES];
    foot.textAlignment = NSTextAlignmentCenter;
    foot.textColor = [UIColor colorWithWhite:1 alpha:0.38];
    [self.panel addSubview:foot];

    [self.view addSubview:self.panel];
}

- (void)startFPSCounter {
    self.lastTimestamp = 0;
    self.frameCounter = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [self.displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
}

- (void)tick:(CADisplayLink *)link {
    if (self.lastTimestamp == 0) {
        self.lastTimestamp = link.timestamp;
        return;
    }

    self.frameCounter++;
    CFTimeInterval delta = link.timestamp - self.lastTimestamp;

    if (delta >= 0.5) {
        double fps = (double)self.frameCounter / delta;
        self.fpsLabel.text = [NSString stringWithFormat:@"FPS: %.0f", fps];
        self.frameCounter = 0;
        self.lastTimestamp = link.timestamp;
    }
}

- (void)switchChanged:(UISwitch *)sender {
    if (sender.tag == 101) {
        self.fpsLabel.hidden = !sender.isOn;
    }

    BOOL anyOn = NO;
    for (NSInteger tag = 101; tag <= 102; tag++) {
        UISwitch *sw = [self.panel viewWithTag:tag];
        if (sw.isOn) { anyOn = YES; break; }
    }

    self.statusLabel.text = anyOn ? @"🟢 ON" : @"🔴 OFF";
    self.statusLabel.textColor = anyOn ? UIColor.systemGreenColor : UIColor.systemRedColor;
}

- (void)togglePanel {
    self.panel.hidden = !self.panel.hidden;
}

- (void)toggleMinimize {
    self.minimized = !self.minimized;
    CGRect f = self.panel.frame;
    f.size.height = self.minimized ? 108 : 400;

    [UIView animateWithDuration:0.20 animations:^{
        self.panel.frame = f;
        for (UIView *v in self.panel.subviews) {
            if (v.frame.origin.y >= 108) v.alpha = self.minimized ? 0.0 : 1.0;
        }
    }];
}

- (void)dragBubble:(UIPanGestureRecognizer *)pan {
    CGPoint delta = [pan translationInView:self.view];
    UIView *v = pan.view;
    v.center = CGPointMake(v.center.x + delta.x, v.center.y + delta.y);
    [pan setTranslation:CGPointZero inView:self.view];
}

- (void)dragPanel:(UIPanGestureRecognizer *)pan {
    CGPoint delta = [pan translationInView:self.view];
    UIView *v = pan.view;
    v.center = CGPointMake(v.center.x + delta.x, v.center.y + delta.y);
    [pan setTranslation:CGPointZero inView:self.view];
}

@end

@interface EliteAppDelegate : UIResponder <UIApplicationDelegate>
@property(nonatomic,strong) UIWindow *window;
@end

@implementation EliteAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [EliteDemoController new];
    [self.window makeKeyAndVisible];
    return YES;
}

@end

int main(int argc, char *argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([EliteAppDelegate class]));
    }
}
