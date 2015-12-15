//
//  ViewController.h
//  MumbleClient
//
//  Created by Altair on 12/14/15.
//  Copyright © 2015 altair. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MumbleKit/MKAudio.h>
#import <MumbleKit/MKConnection.h>
#import <MumbleKit/MKServerModel.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController<MKAudioDelegate, MKConnectionDelegate, MKServerModelDelegate, AVAudioRecorderDelegate,AVAudioPlayerDelegate>
{
    MKServerModel           *_model;
    MKConnection            *_conn;
}

@property (retain) IBOutlet UILabel *lb_screenName;
@property (retain) IBOutlet UILabel *lb_status;
@property (retain) IBOutlet UILabel *lb_recording_status;
@property (retain) IBOutlet UIButton *recordButton;
@property (retain) IBOutlet UIButton *playButton;
@property (retain) IBOutlet UIButton *trashButton;
@end

