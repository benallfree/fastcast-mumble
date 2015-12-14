//
//  ViewController.h
//  MumbleTrial
//
//  Created by common on 12/15/15.
//  Copyright © 2015 common. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "MKServerModel.h"

#import "AQPlayer.h"
#import "AQRecorder.h"

@interface ViewController : UIViewController
{
//    MKServerModel *model;
    AQPlayer*					player;
    AQRecorder*					recorder;
    BOOL						playbackWasInterrupted;
    BOOL						playbackWasPaused;
    
    NSString					*recordFilePath;
}


@end

