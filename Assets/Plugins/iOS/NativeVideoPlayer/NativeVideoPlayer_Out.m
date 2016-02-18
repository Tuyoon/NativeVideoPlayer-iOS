//
//  NativeVideoPlayer_Out.m
//
//
//  Created on 1/28/16.
//  Copyright © 2016. All rights reserved.
//

#import "NativeVideoPlayer.h"

void* videoPlayerInitIOS() {
    NativeVideoPlayer* videoPlayerHelper = [[NativeVideoPlayer alloc] init];
    return (__bridge_retained void *)(videoPlayerHelper);
}

bool videoPlayerLoadIOS(void* dataSetPtr, const char* filename) {
    if (dataSetPtr == NULL) {
        return false;
    }
    
    return [((__bridge NativeVideoPlayer *) dataSetPtr) load:[NSString stringWithUTF8String:filename]];
}
       
bool videoPlayerPlayIOS(void* dataSetPtr, const char* parameters) {
    if (dataSetPtr == NULL) {
        return false;
    }
    return [((__bridge NativeVideoPlayer *) dataSetPtr) play:[NSString stringWithUTF8String:parameters]];
}
            
