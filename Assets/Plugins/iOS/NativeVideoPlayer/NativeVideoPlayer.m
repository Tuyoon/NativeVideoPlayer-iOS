//
//  NativeVideoPlayer.m
//
//
//  Created on 1/28/16.
//  Copyright © 2016. All rights reserved.
//

#import "NativeVideoPlayer.h"

const CGFloat kAnimationDuration = 0.3;

@interface NativeVideoPlayer ()

@property (nonatomic, strong) MPMoviePlayerController* moviePlayer;
@property (nonatomic, strong) NSURL* mediaURL;
@property (nonatomic) CGRect videoFrame;

- (void)moviePlayerLoadStateChanged:(NSNotification*)notification;
- (void)moviePlayerPlaybackDidFinish:(NSNotification*)notification;
- (void)moviePlayerDidExitFullscreen:(NSNotification*)notification;
- (void)moviePlayerExit;

- (void)parseParameters:(NSString*)parameters;
- (void)prepareMoviePlayer;
- (void)unloadMoviePlayer;

- (void)stopObserveMoviePlayer;
- (void)startObserveMoviePlayer;
- (void)showAnimated;
- (void)hideAnimated;

@end

@implementation NativeVideoPlayer

- (BOOL)load:(NSString*)filename {
    BOOL ret = NO;
    
    if (NSNotFound == [filename rangeOfString:@"://"].location) {
        self.mediaURL = [[NSURL alloc] initFileURLWithPath:filename];
    }
    else {
        self.mediaURL = [[NSURL alloc] initWithString:filename];
        
        ret = YES;
    }
    
    return ret;
}

- (BOOL)play:(NSString*)parameters {
    [self parseParameters:parameters];
    [self prepareMoviePlayer];
    [self startObserveMoviePlayer];
    UnityPause(1);
    
    return YES;
}

#pragma mark - Private

- (void)parseParameters:(NSString*)parameters {
    NSArray *arr = [parameters componentsSeparatedByString:@","];
    CGFloat screenScale = [UIScreen mainScreen].scale;
    self.videoFrame = CGRectMake([arr[0] floatValue]/screenScale, [arr[1] floatValue]/screenScale, [arr[2] floatValue]/screenScale, [arr[3] floatValue]/screenScale);
}

- (void)prepareMoviePlayer {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    self.moviePlayer.view.alpha = 0;
    self.moviePlayer.view.frame = self.videoFrame;
    [window.rootViewController.view addSubview:self.moviePlayer.view];
    [self.moviePlayer.view.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.moviePlayer.view removeConstraint:obj];
    }];
    self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.moviePlayer.repeatMode = MPMovieRepeatModeOne;
    [self.moviePlayer setShouldAutoplay:NO];
    [self.moviePlayer setContentURL:self.mediaURL];
    [self.moviePlayer prepareToPlay];
}

- (void)unloadMoviePlayer {
    [self.moviePlayer stop];
    [self.moviePlayer setFullscreen:NO];
    [self.moviePlayer.view removeFromSuperview];
    self.moviePlayer = nil;
}

- (void)startObserveMoviePlayer {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerPlaybackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerLoadStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerDidExitFullscreen:)
                                                 name:MPMoviePlayerDidExitFullscreenNotification
                                               object:self.moviePlayer];
}

- (void)stopObserveMoviePlayer {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:self.moviePlayer];
}

- (void)showAnimated {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.moviePlayer.view.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.moviePlayer.view.frame = [UIScreen mainScreen].bounds;
        } completion:^(BOOL finished) {
            [self.moviePlayer setFullscreen:YES];
            [self.moviePlayer play];
        }];
    }];
}

- (void)hideAnimated {
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.moviePlayer.view.frame = self.videoFrame;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.moviePlayer.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self moviePlayerExit];
        }];
    }];
}

#pragma mark MPMoviePlayerController observation

- (void)moviePlayerLoadStateChanged:(NSNotification*)notification {
    MPMovieLoadState loadState = self.moviePlayer.loadState;
    if (MPMovieLoadStatePlayable & loadState) {
        [self showAnimated];
    }
    
    if (loadState == MPMovieLoadStateUnknown) {
        [self.moviePlayer setContentURL:self.mediaURL];
        [self.moviePlayer prepareToPlay];
    }
}

- (void)moviePlayerPlaybackDidFinish:(NSNotification*)notification {
    NSDictionary* dict = [notification userInfo];
    NSNumber* reason = (NSNumber*)[dict objectForKey:@"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey"];
    
    switch ([reason intValue]) {
        case MPMovieFinishReasonPlaybackEnded:
            return; //!!
        default:
            break;
    }
    
    [self moviePlayerExit];
}

- (void)moviePlayerDidExitFullscreen:(NSNotification*)notification {
    [self hideAnimated];
}

- (void)moviePlayerExit {
    [self stopObserveMoviePlayer];
    [self unloadMoviePlayer];
    UnityPause(0);
}

@end
