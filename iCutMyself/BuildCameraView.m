//
//  BuildCameraView.m
//  BuildCam
//
//  Created by Adrian Kemp on 2015-08-29.
//  Copyright (c) 2015 Adrian Kemp. All rights reserved.
//

#import "BuildCameraView.h"
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>

static time_t const timeIntervalBetweenWriteOperations = 2;
static time_t const timeIntervalPerFrame = 20;

@interface BuildCameraView () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *avCaptureSession;
@property (nonatomic, strong) AVCaptureDevice *videoCaptureDevice;
@property (nonatomic, strong) NSOperationQueue *imageProcessingQueue;
@property (nonatomic, assign) CVPixelBufferPoolRef pixelBufferPool;
@property (nonatomic, assign) CFMutableArrayRef framesToBeWritten;

@property (nonatomic, assign) NSInteger framesToSkip;
@property (nonatomic, assign) NSInteger framesSkipped;
@property (nonatomic, assign) NSInteger totalFramesWritten;
@property (nonatomic, assign) NSInteger initialCaptureTimeInSecondsSinceEpoch;
@property (nonatomic, strong) NSTimer *writeOperationTimer;

@property (nonatomic, strong) CIImage *latestImage;

@property (nonatomic, strong) AVAssetWriter *videoWriter;
@property (nonatomic, strong) AVAssetWriterInput *videoWriterInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *videoWriterInputAdaptor;

@end

@implementation BuildCameraView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.framesToSkip = 10;
    self.framesToBeWritten = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    
    self.imageProcessingQueue = [NSOperationQueue new];
    self.imageProcessingQueue.maxConcurrentOperationCount = 1;
    
    self.avCaptureSession = [AVCaptureSession new];
    self.avCaptureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    NSArray *videoCaptureDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    self.videoCaptureDevice = videoCaptureDevices[0];
    
    NSDictionary *attributes = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                 (__bridge NSString *)kCVPixelBufferWidthKey : @(1280),
                                 (__bridge NSString *)kCVPixelBufferHeightKey : @(720)};
    
    CVPixelBufferPoolRef pixelBufferPool = NULL;
    CVReturn cvReturn = CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (__bridge CFDictionaryRef) attributes, &pixelBufferPool);
    if (cvReturn != kCVReturnSuccess) {
        return;
    }
    
    CVPixelBufferPoolRetain(pixelBufferPool);
    self.pixelBufferPool = pixelBufferPool;
    
    [self.avCaptureSession addInput:[AVCaptureDeviceInput deviceInputWithDevice:self.videoCaptureDevice error:nil]];
    
    AVCaptureVideoDataOutput *videoOutput = [AVCaptureVideoDataOutput new];
    [videoOutput setSampleBufferDelegate:self queue:dispatch_queue_create("camera buffer delegate", DISPATCH_QUEUE_SERIAL)];
    videoOutput.videoSettings = [NSDictionary dictionaryWithObject:
                                 [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                            forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    [self.avCaptureSession addOutput:videoOutput];
    
    [self.avCaptureSession startRunning];
    self.initialCaptureTimeInSecondsSinceEpoch = [NSDate timeIntervalSinceReferenceDate];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *originalImage = [[CIImage alloc] initWithCVImageBuffer:pixelBuffer];
    originalImage = [originalImage imageByApplyingOrientation:0];
    
    self.latestImage = originalImage;
    [self setNeedsDisplay:YES];
    
    if (self.videoWriter && self.framesSkipped >= self.framesToSkip) {
        CFArrayAppendValue(self.framesToBeWritten, pixelBuffer);
        self.framesSkipped = 0;
        [self writeBufferedFrames];
    } else {
        self.framesSkipped++;
    }
    
    originalImage = nil;
}

- (void)drawRect:(NSRect)dirtyRect {
    [[[NSGraphicsContext currentContext] CIContext] drawImage:self.latestImage inRect:dirtyRect fromRect:self.latestImage.extent];
}

- (void)beginRecordingToFileAtPath:(NSURL *)filePath {
    NSError *error = nil;
    self.videoWriter = [[AVAssetWriter alloc] initWithURL:filePath fileType:AVFileTypeQuickTimeMovie error:&error];
    if (error) {
        NSLog(@"ERROR: could not create AVAssetWriter: %@", error);
    } else {
        NSLog(@"INFO: recording: %@", self.videoWriter);
    }
    
    NSDictionary *videoSettings = @{AVVideoCodecKey : AVVideoCodecH264,
                                    AVVideoWidthKey : @(1280),
                                    AVVideoHeightKey : @(720)};
    
    self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    if (!self.videoWriterInput) {
        NSLog(@"Could not create AVAssetWriterInput");
    }
    
    self.videoWriterInputAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.videoWriterInput sourcePixelBufferAttributes:nil];
    
    if (!self.videoWriterInputAdaptor) {
        NSLog(@"Could not create AVAssetWriterInputPixelBufferAdaptor");
        return;
    }
    
    if ([self.videoWriter canAddInput:self.videoWriterInput]) {
        [self.videoWriter addInput:self.videoWriterInput];
    } else {
        NSLog(@"Could not add AVAssetWriterInput");
    }
    
    [self.videoWriter startWriting];
    [self.videoWriter startSessionAtSourceTime:kCMTimeZero];
    self.writeOperationTimer = [NSTimer scheduledTimerWithTimeInterval:timeIntervalBetweenWriteOperations target:self selector:@selector(writeBufferedFrames) userInfo:nil repeats:YES];
}

- (BOOL)writeBufferedFrames {
    BOOL didWriteFrames = NO;
    while(CFArrayGetCount(self.framesToBeWritten) > 0 && self.videoWriterInput.readyForMoreMediaData) {
        CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CFArrayGetValueAtIndex(self.framesToBeWritten, 0);
        if (pixelBuffer != NULL) {
            didWriteFrames = YES;
            [self.videoWriterInputAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:CMTimeMake(self.totalFramesWritten, timeIntervalPerFrame)];
            self.totalFramesWritten++;
        }
        CFArrayRemoveValueAtIndex(self.framesToBeWritten, 0);
    }
    return didWriteFrames;
}

- (void)finishRecording {
    __weak typeof (self) weakSelf = self;
    [self.videoWriterInput requestMediaDataWhenReadyOnQueue:dispatch_get_global_queue(0, 0) usingBlock:^{
        while ([weakSelf writeBufferedFrames]) {
            
        }
        [weakSelf.videoWriterInput markAsFinished];
    }];
    [self.videoWriter finishWritingWithCompletionHandler:^{
        switch (weakSelf.videoWriter.status) {
            case AVAssetWriterStatusFailed:
                NSLog(@"ERROR: AVAssetWriter failed to finish: %@", weakSelf.videoWriter.error);
                break;
            case AVAssetWriterStatusCompleted:
                break;
            default:
                break;
        }
        weakSelf.videoWriterInputAdaptor = nil;
        weakSelf.videoWriterInput = nil;
        weakSelf.videoWriter = nil;
        CFArrayRemoveAllValues(weakSelf.framesToBeWritten);
        [weakSelf.writeOperationTimer invalidate];
    }];
}


@end
