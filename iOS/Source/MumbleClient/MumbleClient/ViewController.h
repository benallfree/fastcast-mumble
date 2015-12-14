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

@interface ViewController : UIViewController<MKAudioDelegate, MKConnectionDelegate, MKServerModelDelegate>
{
    MKServerModel           *_model;
    MKConnection            *_conn;
}

@property (retain) IBOutlet UILabel *lb_screenName;
@property (retain) IBOutlet UILabel *lb_status;
@end

