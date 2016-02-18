//
//  NativeVideoPlayer.h
//  
//
//  Created on 1/28/16.
//  Copyright © 2016. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface NativeVideoPlayer : NSObject

- (BOOL)load:(NSString*)filename;
- (BOOL)play:(NSString*)parameters;

@end
