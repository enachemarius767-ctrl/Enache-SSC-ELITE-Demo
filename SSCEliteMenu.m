#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SSCOverlayWindow : UIWindow
@property(nonatomic, weak) UIView *panel;
@property(nonatomic, weak) UIView *bubble;
@end

@implementation SSCOverlayWindow
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    if (!hit) return nil;
    if (self.panel && !self.panel.hidden && [hit isDescendantOfView:self.panel]) return hit;
    if (self.bubble && !self.bubble.hidden && [hit isDescendantOfView:self.bubble]) return hit;
    return nil;
}
@end

@interface SSCOverlayController : UIViewController
@property(nonatomic,strong) UIView *panel;
@property(nonatomic,strong) UIButton *bubble;
@property(nonatomic,strong) UILabel *statusLabel;
@property(nonatomic,strong) UILabel *fpsLabel;
@property(nonatomic,strong) UILabel *scoreLabel;
@property(nonatomic,strong) UILabel *debugLabel;
@property(nonatomic,strong) CADisplayLink *displayLink;
@property(nonatomic,assign) CFTimeInterval lastTimestamp;
@property(nonatomic,assign) NSInteger frameCounter;
@property(nonatomic,assign) BOOL minimized;
@end

@implementation SSCOverlayController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.clearColor;
    self.view.userInteractionEnabled = YES;
    [self buildBubble];
    [self buildPanel];
    [self startFPSCounter];
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

- (void)buildBubble {
    self.bubble = [UIButton buttonWithType:UIButtonTypeSystem];
    self.bubble.frame = CGRectMake(16, 95, 58, 58);
    self.bubble.backgroundColor = [UIColor colorWithRed:0.02 green:0.30 blue:1.0 alpha:0.96];
    self.bubble.layer.cornerRadius = 29;
    self.bubble.layer.shadowColor = [UIColor colorWithRed:0.0 green:0.45 blue:1 alpha:1].CGColor;
    self.bubble.layer.shadowOpacity = 0.80;
    self.bubble.layer.shadowRadius = 12;
    self.bubble.layer.shadowOffset = CGSizeZero;
    [self.bubble setTitle:@"EM" forState:UIControlStateNormal];
    [self.bubble setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.bubble.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.bubble addTarget:self action:@selector(togglePanel) forControlEvents:UIControlEventTouchUpInside];
    [self.bubble addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragBubble:)]];
    [self.view addSubview:self.bubble];
}

- (void)buildPanel {
    CGFloat width = MIN(UIScreen.mainScreen.bounds.size.width - 30.0, 360.0);
    self.panel = [[UIView alloc] initWithFrame:CGRectMake(15, 170, width, 410)];
    self.panel.backgroundColor = [UIColor colorWithRed:0.018 green:0.024 blue:0.05 alpha:0.96];
    self.panel.layer.cornerRadius = 20;
    self.panel.layer.borderWidth = 1.2;
    self.panel.layer.borderColor = [UIColor colorWithRed:0.05 green:0.45 blue:1 alpha:0.95].CGColor;
    self.panel.layer.shadowColor = [UIColor colorWithRed:0.0 green:0.35 blue:1 alpha:1].CGColor;
    self.panel.layer.shadowOpacity = 0.50;
    self.panel.layer.shadowRadius = 16;
    self.panel.layer.shadowOffset = CGSizeZero;
    [self.panel addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragPanel:)]];

    UILabel *title = [self labelWithText:@"👑 ENACHE MARIUS OFFICIAL" frame:CGRectMake(14, 12, width - 28, 28) size:17 bold:YES];
    title.textAlignment = NSTextAlignmentCenter;
    [self.panel addSubview:title];

    UILabel *subtitle = [self labelWithText:@"SUBWAY SURFERS CITY ELITE" frame:CGRectMake(14, 42, width - 28, 22) size:12 bold:YES];
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

    UILabel *playerHeader = [self labelWithText:@"PLAYER / DEBUG" frame:CGRectMake(18, 118, width - 36, 22) size:12 bold:YES];
    playerHeader.textColor = [UIColor colorWithRed:0.25 green:0.67 blue:1 alpha:1];
    [self.panel addSubview:playerHeader];

    UILabel *scoreText = [self labelWithText:@"ScoreSystem.AddScore ×16" frame:CGRectMake(20, 150, width - 110, 30) size:15 bold:YES];
    [self.panel addSubview:scoreText];

    self.scoreLabel = [self labelWithText:@"UI ONLY" frame:CGRectMake(width - 92, 150, 72, 30) size:12 bold:YES];
    self.scoreLabel.textAlignment = NSTextAlignmentCenter;
    self.scoreLabel.textColor = UIColor.systemYellowColor;
    self.scoreLabel.backgroundColor = [UIColor colorWithRed:0.35 green:0.28 blue:0.02 alpha:0.35];
    self.scoreLabel.layer.cornerRadius = 8;
    self.scoreLabel.layer.masksToBounds = YES;
    [self.panel addSubview:self.scoreLabel];

    UILabel *fpsText = [self labelWithText:@"FPS Display" frame:CGRectMake(20, 196, width - 105, 32) size:15 bold:NO];
    [self.panel addSubview:fpsText];

    UISwitch *fpsSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(width - 72, 194, 52, 32)];
    fpsSwitch.on = YES;
    fpsSwitch.onTintColor = UIColor.systemGreenColor;
    fpsSwitch.tag = 101;
    [fpsSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.panel addSubview:fpsSwitch];

    self.fpsLabel = [self labelWithText:@"FPS: --" frame:CGRectMake(20, 238, width - 40, 30) size:15 bold:YES];
    self.fpsLabel.textColor = [UIColor colorWithRed:0.45 green:0.78 blue:1 alpha:1];
    [self.panel addSubview:self.fpsLabel];

    UILabel *debugText = [self labelWithText:@"Debug Information" frame:CGRectMake(20, 282, width - 105, 32) size:15 bold:NO];
    [self.panel addSubview:debugText];

    UISwitch *debugSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(width - 72, 280, 52, 32)];
    debugSwitch.on = NO;
    debugSwitch.onTintColor = UIColor.systemGreenColor;
    debugSwitch.tag = 102;
    [debugSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.panel addSubview:debugSwitch];

    self.debugLabel = [self labelWithText:@"" frame:CGRectMake(20, 318, width - 40, 44) size:10 bold:NO];
    self.debugLabel.numberOfLines = 2;
    self.debugLabel.textColor = [UIColor colorWithWhite:1 alpha:0.58];
    self.debugLabel.hidden = YES;
    [self.panel addSubview:self.debugLabel];

    self.statusLabel = [self labelWithText:@"🟢 MENU ON" frame:CGRectMake(20, 360, width - 40, 28) size:14 bold:YES];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.textColor = UIColor.systemGreenColor;
    [self.panel addSubview:self.statusLabel];

    UILabel *foot = [self labelWithText:@"LOCAL / OFFLINE OVERLAY — NO GAMEPLAY HOOKS" frame:CGRectMake(12, 390, width - 24, 16) size:9 bold:YES];
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
    } else if (sender.tag == 102) {
        self.debugLabel.hidden = !sender.isOn;
        if (sender.isOn) {
            NSString *bundle = NSBundle.mainBundle.bundleIdentifier ?: @"unknown";
            self.debugLabel.text = [NSString stringWithFormat:@"Bundle: %@\nOverlay: SSCEliteMenu.dylib", bundle];
        }
    }
}

- (void)togglePanel {
    self.panel.hidden = !self.panel.hidden;
}

- (void)toggleMinimize {
    self.minimized = !self.minimized;
    CGRect f = self.panel.frame;
    f.size.height = self.minimized ? 108 : 410;
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

static SSCOverlayWindow *gSSCWindow = nil;
static SSCOverlayController *gSSCController = nil;
static id gSSCObserver = nil;

static UIWindowScene *SSCActiveWindowScene(void) {
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if ([scene isKindOfClass:UIWindowScene.class] && scene.activationState == UISceneActivationStateForegroundActive) {
                return (UIWindowScene *)scene;
            }
        }
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if ([scene isKindOfClass:UIWindowScene.class]) return (UIWindowScene *)scene;
        }
    }
    return nil;
}

static void SSCInstallOverlay(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (gSSCWindow) {
            gSSCWindow.hidden = NO;
            return;
        }

        UIWindowScene *scene = SSCActiveWindowScene();
        if (!scene) return;

        gSSCController = [SSCOverlayController new];
        gSSCWindow = [[SSCOverlayWindow alloc] initWithWindowScene:scene];
        gSSCWindow.frame = scene.coordinateSpace.bounds;
        gSSCWindow.backgroundColor = UIColor.clearColor;
        gSSCWindow.windowLevel = UIWindowLevelAlert + 1000.0;
        gSSCWindow.rootViewController = gSSCController;
        gSSCWindow.hidden = NO;

        // Force the controller view to load before wiring pass-through hit testing.
        (void)gSSCController.view;
        gSSCWindow.panel = gSSCController.panel;
        gSSCWindow.bubble = gSSCController.bubble;
    });
}

__attribute__((constructor)) static void SSCEliteMenuEntry(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!gSSCObserver) {
            gSSCObserver = [[NSNotificationCenter defaultCenter]
                addObserverForName:UIApplicationDidBecomeActiveNotification
                            object:nil
                             queue:NSOperationQueue.mainQueue
                        usingBlock:^(__unused NSNotification *note) {
                            SSCInstallOverlay();
                        }];
        }

        SSCInstallOverlay();
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ SSCInstallOverlay(); });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ SSCInstallOverlay(); });
    });
}
