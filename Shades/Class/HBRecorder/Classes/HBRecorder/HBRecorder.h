//
//  HBRecorder.h
//  HBRecorder
//
//  Created by HilalB on 11/07/2016.
//  Copyright (c) 2016 HilalB. All rights reserved.
//

#import "SCRecorder.h"

@class HBRecorder;

@protocol HBRecorderProtocol <NSObject>

@optional
- (void)recorder:( HBRecorder *  )recorder  didFinishPickingMediaWithUrl:(NSURL * )videoUrl watermarkUrl:(NSURL *)watermarkUrl;
- (void)recorderDidCancel:( HBRecorder *  )recorder;
- (void)recorderUpdateProgress:( HBRecorder *  )recorder;
- (BOOL)recorderBegin:( HBRecorder *  )recorder;
    
@end


@interface HBRecorder : UIViewController<SCRecorderDelegate, UIImagePickerControllerDelegate>

/**
 The delegate
 */
@property (weak, nonatomic) id<HBRecorderProtocol> delegate;

@property (strong, nonatomic) NSString *topTitle;
@property (strong, nonatomic) NSString *bottomTitle;
@property (assign, nonatomic) int64_t maxRecordDuration;
@property (assign, nonatomic) int64_t maxSegmentDuration;
@property (strong, nonatomic) NSString *movieName;
@property (assign, nonatomic) int currentRecord;
@property (strong, nonatomic) NSMutableArray *maxSegmentDurations;
@property (retain, nonatomic) SCRecorder *recorder;


- (void)setMaxSegmentDurations:(NSMutableArray *)maxSegmentDurations;

- (void)stopRecordingVideo;
    
+ (void)saveVideo:(NSURL*)fromVideo withToUrl:(NSURL*)saveUrl;

- (void)initSession;

- (void)retakeShot;

- (void) switchFlashProc;

- (bool) isFlashButtonOn;
    
//Record button

@property (nonatomic, strong) UIImage *recStartImage;
@property (nonatomic, strong) UIImage *recStopImage;
@property (nonatomic, strong) UIImage *outerImage1;
@property (nonatomic, strong) UIImage *outerImage2;
@property (nonatomic, weak) IBOutlet UIButton *recBtn;
@property (nonatomic, weak) IBOutlet UIImageView *outerImageView;
@property (nonatomic, weak) IBOutlet UILabel *lbRecDuration;


@property (weak, nonatomic) IBOutlet UIView *recordView;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *retakeButton;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *timeRecordedLabel;
@property (weak, nonatomic) IBOutlet UIView *downBar;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraModeButton;
@property (weak, nonatomic) IBOutlet UIButton *reverseCamera;
@property (weak, nonatomic) IBOutlet UIButton *flashModeButton;
@property (weak, nonatomic) IBOutlet UIButton *capturePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *ghostModeButton;
@property (weak, nonatomic) IBOutlet UIView *toolsContainerView;
@property (weak, nonatomic) IBOutlet UIButton *openToolsButton;

- (IBAction)switchCameraMode:(id)sender;
- (IBAction)switchFlash:(id)sender;
- (IBAction)capturePhoto:(id)sender;
- (IBAction)switchGhostMode:(id)sender;
- (IBAction)shutterButtonTapped:(UIButton *)sender;

@end
