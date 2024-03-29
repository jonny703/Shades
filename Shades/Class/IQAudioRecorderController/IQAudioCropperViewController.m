//
//  IQAudioCropperViewController.m
// https://github.com/hackiftekhar/IQAudioRecorderController
// Created by Iftekhar Qurashi
// Copyright (c) 2015-16 Iftekhar Qurashi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "IQAudioCropperViewController.h"
#import "NSString+IQTimeIntervalFormatter.h"
#import "IQCropSelectionBeginView.h"
#import "IQCropSelectionEndView.h"
#import "IQ_FDWaveformView.h"

#define CROP_DURATION   15

typedef NS_ENUM(NSUInteger, IQCropGestureState) {
    IQCropGestureStateNone,
    IQCropGestureStateLeft,
    IQCropGestureStateRight,
};

@interface IQAudioCropperViewController ()<IQ_FDWaveformViewDelegate,AVAudioPlayerDelegate>
{
    //BlurrView
    UIVisualEffectView *visualEffectView;
    BOOL _isFirstTime;

    UIView *middleContainerView;
    
    IQ_FDWaveformView *waveformView;
    UIActivityIndicatorView *waveLoadiingIndicatorView;
    
    //Navigation Bar
    UIBarButtonItem *_cancelButton;
    UIBarButtonItem *_doneButton;
    
    //Toolbar
    UIBarButtonItem *_flexItem;
    
    //Playing controls
    UIBarButtonItem *_playButton;
    UIBarButtonItem *_pauseButton;
    UIBarButtonItem *_stopPlayButton;
    
    UIBarButtonItem *_cropButton;
    UIBarButtonItem *_cropActivityBarButton;
    UIActivityIndicatorView *_cropActivityIndicatorView;


    IQCropSelectionView *leftCropView;
    IQCropSelectionView *rightCropView;
    
    //Playing
    AVAudioPlayer *_audioPlayer;
//    BOOL _wasPlaying;
    CADisplayLink *playProgressDisplayLink;
    
    //Private variables
    NSString *_oldSessionCategory;
    BOOL _wasIdleTimerDisabled;
}

@property(nonnull, nonatomic, strong, readwrite) NSString *originalAudioFilePath;
@property(nonnull, nonatomic, strong, readwrite) NSString *currentAudioFilePath;

@property(nonatomic, assign) BOOL blurrEnabled;

@property(nonatomic, readonly) IQCropGestureState gestureState;
@property(nonatomic, readonly) UIPanGestureRecognizer *cropPanGesture;
@property(nonatomic, readonly) UITapGestureRecognizer *cropTapGesture;

@end

@implementation IQAudioCropperViewController
@synthesize gestureState = _gestureState;
@dynamic title;

-(instancetype)initWithFilePath:(NSString*)audioFilePath
{
    self = [super init];
    
    if (self)
    {
        self.originalAudioFilePath = audioFilePath;
        self.currentAudioFilePath = audioFilePath;
        self.audioUrl = [NSURL fileURLWithPath:audioFilePath];
    }

    return self;
}

-(void)setNormalTintColor:(UIColor *)normalTintColor
{
    _normalTintColor = normalTintColor;
    
    _playButton.tintColor = [self _normalTintColor];
    _pauseButton.tintColor = [self _normalTintColor];
    _stopPlayButton.tintColor = [self _normalTintColor];
    _cropButton.tintColor = [self _normalTintColor];
    waveformView.wavesColor = [self _normalTintColor];
}

-(UIColor*)_normalTintColor
{
    if (_normalTintColor)
    {
        return _normalTintColor;
    }
    else
    {
        if (self.barStyle == UIBarStyleDefault)
        {
            return [UIColor colorWithRed:0 green:0.5 blue:1.0 alpha:1.0];
        }
        else
        {
            return [UIColor whiteColor];
        }
    }
}

-(void)setHighlightedTintColor:(UIColor *)highlightedTintColor
{
    _highlightedTintColor = highlightedTintColor;
    waveformView.progressColor = [self _highlightedTintColor];
}

-(UIColor *)_highlightedTintColor
{
    if (_highlightedTintColor)
    {
        return _highlightedTintColor;
    }
    else
    {
        if (self.barStyle == UIBarStyleDefault)
        {
            return [UIColor colorWithRed:255.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0];
        }
        else
        {
            return [UIColor colorWithRed:0 green:0.5 blue:1.0 alpha:1.0];
        }
    }
}

-(void)setBarStyle:(UIBarStyle)barStyle
{
    _barStyle = barStyle;
    
    if (self.barStyle == UIBarStyleDefault)
    {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        self.navigationController.toolbar.barStyle = UIBarStyleDefault;
        self.navigationController.navigationBar.tintColor = [self _normalTintColor];
        self.navigationController.toolbar.tintColor = [self _normalTintColor];
        _cropActivityIndicatorView.color = [UIColor lightGrayColor];
        waveLoadiingIndicatorView.color = [UIColor lightGrayColor];
    }
    else
    {
        self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationController.toolbar.barStyle = UIBarStyleBlack;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.toolbar.tintColor = [UIColor whiteColor];
        _cropActivityIndicatorView.color = [UIColor whiteColor];
        waveLoadiingIndicatorView.color = [UIColor whiteColor];
    }
    
    self.navigationController.navigationBarHidden = YES;
    
    visualEffectView.tintColor = [self _normalTintColor];
    self.highlightedTintColor = self.highlightedTintColor;
    self.normalTintColor = self.normalTintColor;
}

-(void)loadView
{
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:nil];
//    visualEffectView.frame = [UIScreen mainScreen].bounds;
    
    visualEffectView.frame = self.frameView;
    
    self.view = visualEffectView;
}

-(nonnull instancetype)initWithFileUrl:(nonnull NSURL*)audioUrl
{
    self = [super init];
    
    if (self)
    {
        self.originalAudioFilePath = audioUrl.absoluteString;
        self.currentAudioFilePath = audioUrl.absoluteString;
        self.audioUrl = audioUrl;
    }
    
    return self;
}
    
- (void)viewDidLoad
{
    [super viewDidLoad];

    _isFirstTime = YES;

    {
        if (self.title.length == 0)
        {
            self.navigationItem.title = NSLocalizedString(@"Edit",nil);
        }
    }
    
    NSURL *audioURL = self.audioUrl;//[NSURL fileURLWithPath:self.currentAudioFilePath];
    
    middleContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, visualEffectView.frame.size.width, 200)];
    middleContainerView.alpha = 1.0;
    middleContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    middleContainerView.center = visualEffectView.center;
    [visualEffectView.contentView addSubview:middleContainerView];
    
    middleContainerView.backgroundColor = [UIColor clearColor];
    
    UIEdgeInsets waveformInset = UIEdgeInsetsMake(25, 22, 25, 22);

    {
        CGRect waveformFrame = UIEdgeInsetsInsetRect(middleContainerView.bounds, waveformInset);
        waveformView = [[IQ_FDWaveformView alloc] initWithFrame:waveformFrame];
        waveformView.userInteractionEnabled = NO;
        waveformView.delegate = self;
        waveformView.audioURL = audioURL;
        waveformView.wavesColor = [self _normalTintColor];
        waveformView.progressColor = [self _highlightedTintColor];
        waveformView.cropColor = [UIColor yellowColor];
        waveformView.backgroundColor = [UIColor clearColor];
        
        waveformView.doesAllowScroll = NO;
        waveformView.doesAllowScrubbing = NO;
        waveformView.doesAllowStretch = NO;
        
        waveformView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [middleContainerView addSubview:waveformView];
        
        waveLoadiingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        waveLoadiingIndicatorView.center = middleContainerView.center;
        waveLoadiingIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [visualEffectView.contentView addSubview:waveLoadiingIndicatorView];
    }
    
    {
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
        _audioPlayer.delegate = self;
        _audioPlayer.meteringEnabled = YES;
        
        if (_audioPlayer.duration < CROP_DURATION)
        {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];

            UIAlertController * alert=[UIAlertController alertControllerWithTitle:nil
                                                                          message:@"The song duration must be at least 15 seconds!"
                                                                   preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action)
            {
                [self.parentVC.navigationController popViewControllerAnimated:YES];
            }];
            
            [alert addAction:yesButton];
            
            [self.parentVC presentViewController:alert animated:YES completion:nil];

            return;
        }
    }

    {
        _cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
        self.navigationItem.leftBarButtonItem = _cancelButton;
        _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
        _doneButton.enabled = NO;
        self.navigationItem.rightBarButtonItem = _doneButton;
    }
    
    {
        NSBundle* bundle = [NSBundle bundleForClass:self.class];
        if (bundle == nil)  bundle = [NSBundle mainBundle];
        NSBundle *resourcesBundle = [NSBundle bundleWithPath:[bundle pathForResource:@"IQAudioRecorderController" ofType:@"bundle"]];
        if (resourcesBundle == nil) resourcesBundle = bundle;
        
        self.navigationController.toolbarHidden = NO;
        
        _flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

        _stopPlayButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"stop_playing" inBundle:resourcesBundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(stopPlayingButtonAction:)];
        _stopPlayButton.enabled = NO;
        _stopPlayButton.tintColor = [self _normalTintColor];
        _playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playAction:)];
        _playButton.tintColor = [self _normalTintColor];
        
        _pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(pauseAction:)];
        _pauseButton.tintColor = [self _normalTintColor];

        _cropButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"scissor" inBundle:resourcesBundle compatibleWithTraitCollection:nil] style:UIBarButtonItemStylePlain target:self action:@selector(cropAction:)];
        _cropButton.tintColor = [self _normalTintColor];
        _cropButton.enabled = NO;
        
        _cropActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _cropActivityBarButton = [[UIBarButtonItem alloc] initWithCustomView:_cropActivityIndicatorView];
        
        [self.parentVC setToolbarItems:@[_stopPlayButton,_flexItem, _playButton,_flexItem,_cropButton] animated:NO];
    }
    
    self.navigationController.toolbarHidden = YES;
    
    {
        CGFloat margin = 30;
        
        leftCropView = [[IQCropSelectionBeginView alloc] initWithFrame:CGRectMake(0, 0, 10, CGRectGetHeight(waveformView.frame)+margin*2)];
        leftCropView.center = CGPointMake(CGRectGetMinX(waveformView.frame), CGRectGetMidY(waveformView.frame));
        leftCropView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        leftCropView.hidden = YES;
        
        rightCropView = [[IQCropSelectionEndView alloc] initWithFrame:CGRectMake(0, 0, 10, CGRectGetHeight(waveformView.frame)+margin*2)];
        float duration = _audioPlayer.duration;
        float x = waveformView.frame.origin.x + (int)(waveformView.frame.size.width * CROP_DURATION/duration);
        rightCropView.center = CGPointMake(x, CGRectGetMidY(waveformView.frame));//CGRectGetMaxX(waveformView.frame)
        rightCropView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        leftCropView.cropTime = 0;
        rightCropView.hidden = YES;
        rightCropView.cropTime = CROP_DURATION;//_audioPlayer.duration;
        waveformView.cropStartSamples = waveformView.totalSamples*(leftCropView.cropTime/_audioPlayer.duration);
        waveformView.cropEndSamples = waveformView.totalSamples*(rightCropView.cropTime/_audioPlayer.duration);

        [middleContainerView addSubview:leftCropView];
        [middleContainerView addSubview:rightCropView];
        
        _cropPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cropPanRecognizer:)];
        [middleContainerView addGestureRecognizer:self.cropPanGesture];

//        _cropTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cropTapRecognizer:)];
//        [_cropTapGesture requireGestureRecognizerToFail:self.cropPanGesture];
//        [middleContainerView addGestureRecognizer:self.cropTapGesture];
        
        if (leftCropView.cropTime == 0 && rightCropView.cropTime == _audioPlayer.duration)
        {
            _cropButton.enabled = NO;
            if ([self.delegate respondsToSelector:@selector(audioCropperControllerDidCrop:)])
            {
                [self.delegate audioCropperControllerDidCrop:self];
            }
        }
        else
        {
            _cropButton.enabled = YES;
        }
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopPlayingButtonAction:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (_isFirstTime)
    {
        _isFirstTime = NO;
        
        if (self.blurrEnabled)
        {
            [UIView animateWithDuration:0.3 animations:^{
                
                if (self.barStyle == UIBarStyleDefault)
                {
                    visualEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
                }
                else
                {
                    visualEffectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                }
            }];
        }
        else
        {
            if (self.barStyle == UIBarStyleDefault)
            {
                visualEffectView.backgroundColor = [UIColor whiteColor];
            }
            else
            {
                visualEffectView.backgroundColor = [UIColor darkGrayColor];
            }
        }
    }
    
    visualEffectView.backgroundColor = [UIColor clearColor];
}

-(void)cropTapRecognizer:(UITapGestureRecognizer*)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded)
    {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_stopPlayButton.target methodSignatureForSelector:_stopPlayButton.action]];
        invocation.target = _stopPlayButton.target;
        invocation.selector = _stopPlayButton.action;
        [invocation invoke];
        
        CGPoint tappedLocation = [tapRecognizer locationInView:middleContainerView];
        
        CGFloat leftDistance = ABS(leftCropView.center.x-tappedLocation.x);
        CGFloat rightDistance = ABS(rightCropView.center.x-tappedLocation.x);
        
        IQCropGestureState state = leftDistance > rightDistance ? IQCropGestureStateRight : IQCropGestureStateLeft;
        
        switch (state)
        {
            case IQCropGestureStateLeft:
            {
                //Left Margin
                CGFloat pointX = MAX(CGRectGetMinX(waveformView.frame), tappedLocation.x);
                
                //Right Margin from right cropper
                pointX = MIN(CGRectGetMinX(rightCropView.frame), pointX);
                
                CGPoint leftCropViewCenter = CGPointMake(pointX, leftCropView.center.y);
                
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
                    leftCropView.center = leftCropViewCenter;
                } completion:NULL];

                {
                    CGPoint centerInWaveform = [leftCropView.superview convertPoint:leftCropViewCenter toView:waveformView];
                    
                    leftCropView.cropTime = (centerInWaveform.x/waveformView.frame.size.width)*_audioPlayer.duration;
                    _audioPlayer.currentTime = leftCropView.cropTime;
                    waveformView.progressSamples = waveformView.totalSamples*(_audioPlayer.currentTime/_audioPlayer.duration);
                    waveformView.cropStartSamples = waveformView.totalSamples*(leftCropView.cropTime/_audioPlayer.duration);
                }
            }
                break;
            case IQCropGestureStateRight:
            {
                //Right Margin
                CGFloat pointX = MIN(CGRectGetMaxX(waveformView.frame), tappedLocation.x);
                
                //Left Margin from left cropper
                pointX = MAX(CGRectGetMaxX(leftCropView.frame), pointX);
                
                CGPoint rightCropViewCenter = CGPointMake(pointX, rightCropView.center.y);
                
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
                    rightCropView.center = rightCropViewCenter;
                } completion:NULL];
                
                {
                    CGPoint centerInWaveform = [rightCropView.superview convertPoint:rightCropViewCenter toView:waveformView];
                    
                    rightCropView.cropTime = (centerInWaveform.x/waveformView.frame.size.width)*_audioPlayer.duration;
                    waveformView.cropEndSamples = waveformView.totalSamples*(rightCropView.cropTime/_audioPlayer.duration);
                }
            }
                break;
                
            default:
                break;
        }

        
        if (leftCropView.cropTime == 0 && rightCropView.cropTime == _audioPlayer.duration)
        {
            _cropButton.enabled = NO;
        }
        else
        {
            _cropButton.enabled = YES;
        }
    }
}


-(void)cropPanRecognizer:(UIPanGestureRecognizer*)panRecognizer
{
    static CGPoint beginCenter;
    CGPoint currentLocation = [panRecognizer locationInView:middleContainerView];
    
    if (panRecognizer.state == UIGestureRecognizerStateBegan)
    {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_stopPlayButton.target methodSignatureForSelector:_stopPlayButton.action]];
        invocation.target = _stopPlayButton.target;
        invocation.selector = _stopPlayButton.action;
        [invocation invoke];
        
        CGFloat leftDistance = ABS(leftCropView.center.x-currentLocation.x);
        CGFloat rightDistance = ABS(rightCropView.center.x-currentLocation.x);
        
        _gestureState = leftDistance > rightDistance ? IQCropGestureStateRight : IQCropGestureStateLeft;

        switch (_gestureState)
        {
            case IQCropGestureStateLeft:
            {
                beginCenter = leftCropView.center;
            }
                break;
            case IQCropGestureStateRight:
            {
                beginCenter = rightCropView.center;
            }
                break;
                
            default:
                break;
        }

        if ( _audioPlayer.duration >= 400 )
        {
            beginCenter = rightCropView.center;
        }
    }
    
    int diff = (int)(waveformView.frame.size.width*CROP_DURATION/_audioPlayer.duration);
    
    if (panRecognizer.state == UIGestureRecognizerStateBegan ||
        panRecognizer.state == UIGestureRecognizerStateChanged)
    {
        switch (_gestureState)
        {
            case IQCropGestureStateLeft:
            {
                //Left Margin
                CGFloat pointX = MAX(CGRectGetMinX(waveformView.frame), currentLocation.x);
                
                //Right Margin from right cropper
                pointX = MIN(CGRectGetMinX(rightCropView.frame), pointX);
                if ( pointX > CGRectGetMaxX(waveformView.frame)-diff )
                {
                    pointX = CGRectGetMaxX(waveformView.frame)-diff;
                }
                
                CGPoint leftCropViewCenter = CGPointMake(pointX, beginCenter.y);

                [UIView animateWithDuration:(panRecognizer.state == UIGestureRecognizerStateBegan ? 0.2:0) delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
                    leftCropView.center = leftCropViewCenter;
                } completion:NULL];

                {
                    CGPoint centerInWaveform = [leftCropView.superview convertPoint:leftCropViewCenter toView:waveformView];
                    
                    leftCropView.cropTime = (centerInWaveform.x/waveformView.frame.size.width)*_audioPlayer.duration;
                    if (leftCropView.cropTime < 0)
                        leftCropView.cropTime = 0;
                    else if (leftCropView.cropTime > _audioPlayer.duration-CROP_DURATION)
                        leftCropView.cropTime = _audioPlayer.duration-CROP_DURATION;

                    _audioPlayer.currentTime = leftCropView.cropTime;
                    waveformView.progressSamples = waveformView.totalSamples*(_audioPlayer.currentTime/_audioPlayer.duration);
                    waveformView.cropStartSamples = waveformView.totalSamples*(leftCropView.cropTime/_audioPlayer.duration);
                    
                    rightCropView.center = CGPointMake(leftCropView.center.x + diff, rightCropView.center.y);
                    rightCropView.cropTime = leftCropView.cropTime + CROP_DURATION;
                    waveformView.cropEndSamples = waveformView.totalSamples*(rightCropView.cropTime/_audioPlayer.duration);
                }
            }
                break;
            case IQCropGestureStateRight:
            {
                //Right Margin
                CGFloat pointX = MIN(CGRectGetMaxX(waveformView.frame), currentLocation.x);
                
                //Left Margin from left cropper
                pointX = MAX(CGRectGetMaxX(leftCropView.frame), pointX);
                int m = CGRectGetMinX(waveformView.frame);
                if ( pointX <= m+diff )
                {
                    pointX = CGRectGetMinX(waveformView.frame)+diff;
                }

                CGPoint rightCropViewCenter = CGPointMake(pointX, beginCenter.y);
                
                [UIView animateWithDuration:(panRecognizer.state == UIGestureRecognizerStateBegan ? 0.2:0) delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
                    rightCropView.center = rightCropViewCenter;
                } completion:NULL];
                
                {
                    CGPoint centerInWaveform = [rightCropView.superview convertPoint:rightCropViewCenter toView:waveformView];
                    
                    rightCropView.cropTime = (centerInWaveform.x/waveformView.frame.size.width)*_audioPlayer.duration;
                    if (rightCropView.cropTime < CROP_DURATION)
                        rightCropView.cropTime = CROP_DURATION;
                    else if (rightCropView.cropTime > _audioPlayer.duration)
                        rightCropView.cropTime = _audioPlayer.duration;
                    
                    waveformView.cropEndSamples = waveformView.totalSamples*(rightCropView.cropTime/_audioPlayer.duration);
                    
                    leftCropView.center = CGPointMake(rightCropView.center.x - diff, leftCropView.center.y);
                    leftCropView.cropTime = rightCropView.cropTime - CROP_DURATION;
                    _audioPlayer.currentTime = leftCropView.cropTime;
                    waveformView.progressSamples = waveformView.totalSamples*(_audioPlayer.currentTime/_audioPlayer.duration);
                    waveformView.cropStartSamples = waveformView.totalSamples*(leftCropView.cropTime/_audioPlayer.duration);
                }
            }
                break;
                
            default:
                break;
        }
    }
    else if (panRecognizer.state == UIGestureRecognizerStateEnded|| panRecognizer.state == UIGestureRecognizerStateFailed)
    {
        beginCenter = CGPointZero;

        if (leftCropView.cropTime == 0 && rightCropView.cropTime == _audioPlayer.duration)
        {
            _cropButton.enabled = NO;
        }
        else
        {
            _cropButton.enabled = YES;
        }
        
        _gestureState = IQCropGestureStateNone;
    }
}

#pragma mark - Audio Play

-(void)updatePlayProgress
{
    waveformView.progressSamples = waveformView.totalSamples*(_audioPlayer.currentTime/_audioPlayer.duration);
    
    if (_audioPlayer.currentTime >= rightCropView.cropTime)
    {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_stopPlayButton.target methodSignatureForSelector:_stopPlayButton.action]];
        invocation.target = _stopPlayButton.target;
        invocation.selector = _stopPlayButton.action;
        [invocation invoke];
    }
}

- (void)playAction:(UIBarButtonItem *)item
{
    _oldSessionCategory = [AVAudioSession sharedInstance].category;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
    
    //UI Update
    {
        [self.parentVC setToolbarItems:@[_stopPlayButton,_flexItem, _pauseButton,_flexItem,_cropButton] animated:YES];
        _stopPlayButton.enabled = YES;
        _cropButton.enabled = NO;
        _cancelButton.enabled = NO;
        _doneButton.enabled = NO;
    }
    
    {
        [playProgressDisplayLink invalidate];
        playProgressDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updatePlayProgress)];
        [playProgressDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

-(void)pauseAction:(UIBarButtonItem*)item
{
    [[AVAudioSession sharedInstance] setCategory:_oldSessionCategory error:nil];
    [UIApplication sharedApplication].idleTimerDisabled = _wasIdleTimerDisabled;
    
    [_audioPlayer pause];

    //    //UI Update
    {
        [self.parentVC setToolbarItems:@[_stopPlayButton,_flexItem, _playButton,_flexItem,_cropButton] animated:YES];
    }
}

-(void)stopPlayingButtonAction:(UIBarButtonItem*_Nullable)item
{
    //UI Update
    {
        [self.parentVC setToolbarItems:@[_stopPlayButton,_flexItem, _playButton,_flexItem,_cropButton] animated:YES];
        _stopPlayButton.enabled = NO;
        _cancelButton.enabled = YES;

        if ([self.originalAudioFilePath isEqualToString:self.currentAudioFilePath])
        {
            _doneButton.enabled = NO;
        }
        else
        {
            _doneButton.enabled = YES;
        }
        
        if (leftCropView.cropTime == 0 && rightCropView.cropTime == _audioPlayer.duration)
        {
            _cropButton.enabled = NO;
        }
        else
        {
            _cropButton.enabled = YES;
        }
    }
    
    {
        [playProgressDisplayLink invalidate];
        playProgressDisplayLink = nil;
    }

    [_audioPlayer stop];
    
    {
        _audioPlayer.currentTime = leftCropView.cropTime;
        waveformView.progressSamples = waveformView.totalSamples*(_audioPlayer.currentTime/_audioPlayer.duration);
    }

    [[AVAudioSession sharedInstance] setCategory:_oldSessionCategory error:nil];
    [UIApplication sharedApplication].idleTimerDisabled = _wasIdleTimerDisabled;
}

#pragma mark - Crop

-(void)cropAction:(UIBarButtonItem*)item
{
    {
        [_cropActivityIndicatorView startAnimating];
        [self.parentVC setToolbarItems:@[_stopPlayButton,_flexItem, _playButton,_flexItem,_cropActivityBarButton] animated:YES];
        _stopPlayButton.enabled = NO;
        _playButton.enabled = NO;
        _cancelButton.enabled = NO;
        _doneButton.enabled = NO;
        visualEffectView.userInteractionEnabled = NO;
    }

        {
            NSURL *audioURL = self.audioUrl;//[NSURL fileURLWithPath:self.currentAudioFilePath];

            AVAsset *asset = [AVAsset assetWithURL:audioURL];
            
            // get the first audio track
            NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
            
            AVAssetTrack *track = [tracks firstObject];
            
            // create the export session
            // no need for a retain here, the session will be retained by the
            // completion handler since it is referenced there
            AVAssetExportSession *exportSession = [AVAssetExportSession
                                                   exportSessionWithAsset:asset
                                                   presetName:AVAssetExportPresetAppleM4A];
            
            CMTimeScale scale = [track naturalTimeScale];

            CMTime startTime = CMTimeMake(leftCropView.cropTime*scale, scale);
            CMTime stopTime = CMTimeMake(rightCropView.cropTime*scale, scale);
            CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
            
            // setup audio mix
            AVMutableAudioMix *exportAudioMix = [AVMutableAudioMix audioMix];
            AVMutableAudioMixInputParameters *exportAudioMixInputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
            
            exportAudioMix.inputParameters = [NSArray arrayWithObject:exportAudioMixInputParameters];
            
            NSString *globallyUniqueString = [NSProcessInfo processInfo].globallyUniqueString;//
            
            NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a",globallyUniqueString]];

            // configure export session  output with all our parameters
            exportSession.outputURL = [NSURL fileURLWithPath:filePath]; // output path
            exportSession.outputFileType = AVFileTypeAppleM4A; // output file type
            exportSession.timeRange = exportTimeRange; // trim time range
            exportSession.audioMix = exportAudioMix; // fade in audio mix
            
            // perform the export
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                
                switch (exportSession.status)
                {
                    case AVAssetExportSessionStatusCancelled:
                    case AVAssetExportSessionStatusCompleted:
                    case AVAssetExportSessionStatusFailed:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            if (exportSession.status == AVAssetExportSessionStatusCompleted)
                            {
                                NSString *globallyUniqueString = [NSProcessInfo processInfo].globallyUniqueString;//
                                NSString *newFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a",globallyUniqueString]];
                                NSURL *audioURL = [NSURL fileURLWithPath:newFilePath];
                                
                                NSError *err = nil;
                                [[NSFileManager defaultManager] removeItemAtPath:newFilePath error:&err];

                                [[NSFileManager defaultManager] moveItemAtURL:exportSession.outputURL toURL:audioURL error:nil];
                                self.currentAudioFilePath = newFilePath;
                                
                                waveformView.audioURL = audioURL;
                                [_audioPlayer stop];
                                _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
                                _audioPlayer.delegate = self;
                                _audioPlayer.meteringEnabled = YES;

                                [UIView animateWithDuration:0.2 animations:^{

                                    leftCropView.center = CGPointMake(CGRectGetMinX(waveformView.frame), CGRectGetMidY(waveformView.frame));
                                    rightCropView.center = CGPointMake(CGRectGetMaxX(waveformView.frame), CGRectGetMidY(waveformView.frame));
                                    leftCropView.cropTime = 0;
                                    rightCropView.cropTime = _audioPlayer.duration;
                                }];
                            }
                            
                            [_cropActivityIndicatorView stopAnimating];
                            [self.parentVC setToolbarItems:@[_stopPlayButton,_flexItem, _playButton,_flexItem,_cropButton] animated:YES];
                            if ([self.delegate respondsToSelector:@selector(audioCropperControllerDidCrop:)])
                            {
                                [self.delegate audioCropperControllerDidCrop:self];
                            }
                            _stopPlayButton.enabled = YES;
                            _playButton.enabled = YES;
                            _cancelButton.enabled = YES;
                            _doneButton.enabled = YES;
                            _cropButton.enabled = NO;
                            visualEffectView.userInteractionEnabled = YES;
                        }];
                    }
                        break;
                        
                    default:
                        break;
                }
            }];
        }
}


#pragma mark - AVAudioPlayerDelegate
/*
 Occurs when the audio player instance completes playback
 */
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //To update UI on stop playing
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[_stopPlayButton.target methodSignatureForSelector:_stopPlayButton.action]];
    invocation.target = _stopPlayButton.target;
    invocation.selector = _stopPlayButton.action;
    [invocation invoke];
}

#pragma mark - IQ_FDWaveformView delegate

- (void)waveformViewWillRender:(IQ_FDWaveformView *)waveformView
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [UIView animateWithDuration:0.1 animations:^{
            middleContainerView.alpha = 0.0;
            [waveLoadiingIndicatorView startAnimating];
        }];
    }];
}

- (void)waveformViewDidRender:(IQ_FDWaveformView *)waveformView
{
    [UIView animateWithDuration:0.1 animations:^{
        middleContainerView.alpha = 1.0;
        [waveLoadiingIndicatorView stopAnimating];
        if ([self.delegate respondsToSelector:@selector(audioCropperControllerDidLoad:)])
        {
            [self.delegate audioCropperControllerDidLoad:self];
        }
        [self performSelectorOnMainThread:@selector(showintervalViews) withObject:nil waitUntilDone:NO];
    }];
}

- (void)showintervalViews
{
    leftCropView.hidden = NO;
    rightCropView.hidden = NO;
}

- (void)waveformViewWillLoad:(IQ_FDWaveformView *)waveformView
{
//    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)waveformViewDidLoad:(IQ_FDWaveformView *)waveformView
{
    //    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)waveformDidBeginPanning:(IQ_FDWaveformView *)waveformView
{
//    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)waveformDidEndPanning:(IQ_FDWaveformView *)waveformView
{
//    NSLog(@"%@",NSStringFromSelector(_cmd));
}



#pragma mark - Cancel or Done

-(void)cancelAction:(UIBarButtonItem*)item
{
    if ([self.originalAudioFilePath isEqualToString:self.currentAudioFilePath] == NO)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Discard changes?",nil) message:NSLocalizedString(@"You have some unsaved changes. Audio will not be saved. Are you sure you want to discard?",nil) preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil) style:UIAlertActionStyleDefault handler:nil]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Discard",nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            [self notifyCancelDelegate];
        }]];
        
        alertController.popoverPresentationController.barButtonItem = item;
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        [self notifyCancelDelegate];
    }
}

-(void)doneAction:(UIBarButtonItem*)item
{
    [self notifySuccessDelegate];
    
    NSLog(@"Done Pressed");
    
    
    
}

-(void)notifyCancelDelegate
{
    void (^notifyDelegateBlock)(void) = ^{
        if ([self.delegate respondsToSelector:@selector(audioCropperControllerDidCancel:)])
        {
            [self.delegate audioCropperControllerDidCancel:self];
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    };
    
    if (self.blurrEnabled)
    {
        [self.navigationController setToolbarHidden:YES animated:YES];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [UIView animateWithDuration:0.3 animations:^{
            visualEffectView.effect = nil;
            middleContainerView.alpha = 0;
        } completion:^(BOOL finished) {
            notifyDelegateBlock();
        }];
    }
    else
    {
        notifyDelegateBlock();
    }
}

-(void)notifySuccessDelegate
{
    void (^notifyDelegateBlock)(void) = ^{
        if ([self.delegate respondsToSelector:@selector(audioCropperController:didFinishWithAudioAtPath:)])
        {
            [self.delegate audioCropperController:self didFinishWithAudioAtPath:_currentAudioFilePath];
        }
        
//        [self.parentVC.navigationController popViewControllerAnimated:YES];
        
//        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    if (self.blurrEnabled)
    {
        [self.navigationController setToolbarHidden:YES animated:YES];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [UIView animateWithDuration:0.3 animations:^{
            visualEffectView.effect = nil;
            middleContainerView.alpha = 0;
        } completion:^(BOOL finished) {
            notifyDelegateBlock();
        }];
    }
    else
    {
        notifyDelegateBlock();
    }
}

#pragma mark - Orientation

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {

        CGPoint leftCropViewCenter = CGPointMake(CGRectGetMinX(waveformView.frame)+((leftCropView.cropTime/_audioPlayer.duration)*CGRectGetWidth(waveformView.frame)),leftCropView.center.y);
        CGPoint rightCropViewCenter = CGPointMake(CGRectGetMinX(waveformView.frame)+((rightCropView.cropTime/_audioPlayer.duration)*CGRectGetWidth(waveformView.frame)),rightCropView.center.y);

        leftCropView.center = leftCropViewCenter;
        rightCropView.center = rightCropViewCenter;
        
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {

         {
             CGPoint centerInWaveform = [leftCropView.superview convertPoint:leftCropView.center toView:waveformView];
             
             leftCropView.cropTime = (centerInWaveform.x/waveformView.frame.size.width)*_audioPlayer.duration;
             _audioPlayer.currentTime = leftCropView.cropTime;
             waveformView.progressSamples = waveformView.totalSamples*(_audioPlayer.currentTime/_audioPlayer.duration);
             waveformView.cropStartSamples = waveformView.totalSamples*(leftCropView.cropTime/_audioPlayer.duration);
         }
         
         {
             CGPoint centerInWaveform = [rightCropView.superview convertPoint:rightCropView.center toView:waveformView];
             
             rightCropView.cropTime = (centerInWaveform.x/waveformView.frame.size.width)*_audioPlayer.duration;
             waveformView.cropEndSamples = waveformView.totalSamples*(rightCropView.cropTime/_audioPlayer.duration);
         }
     }];
}

@end


@implementation UIViewController (IQAudioCropperViewController)

- (void)presentAudioCropperViewControllerAnimated:(nonnull IQAudioCropperViewController *)audioCropperViewController
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:audioCropperViewController];
    
    navigationController.toolbarHidden = NO;
    navigationController.toolbar.translucent = YES;
    
    navigationController.navigationBar.translucent = YES;
    
    audioCropperViewController.barStyle = audioCropperViewController.barStyle;        //This line is used to refresh UI of Audio Recorder View Controller
    [self presentViewController:navigationController animated:YES completion:^{
    }];
}

- (void)presentBlurredAudioCropperViewControllerAnimated:(nonnull IQAudioCropperViewController *)audioCropperViewController
{
    audioCropperViewController.blurrEnabled = YES;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:audioCropperViewController];
    
    navigationController.toolbarHidden = NO;
    navigationController.toolbar.translucent = YES;
    [navigationController.toolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [navigationController.toolbar setShadowImage:[UIImage new] forToolbarPosition:UIBarPositionAny];
    
    navigationController.navigationBar.translucent = YES;
    [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [navigationController.navigationBar setShadowImage:[UIImage new]];
    
    navigationController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    audioCropperViewController.barStyle = audioCropperViewController.barStyle;        //This line is used to refresh UI of Audio Recorder View Controller
    [self presentViewController:navigationController animated:NO completion:nil];
}

@end

