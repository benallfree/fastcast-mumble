//
//  ViewController.m
//  MumbleClient
//
//  Created by Altair on 12/14/15.
//  Copyright © 2015 altair. All rights reserved.
//
#import "ViewController.h"
#import "Dialogs.h"

@interface ViewController ()
{
    UIAlertView *loading_alert;
    
    //Recording...
    AVAudioRecorder *_audioRecorder;
    NSString *_recordingFilePath;
    BOOL _isRecording;
    CADisplayLink *meterUpdateDisplayLink;
    
    //Playing
    AVAudioPlayer *_audioPlayer;
    BOOL _isPlaying;
    UIView *_viewPlayerDuration;
    UISlider *_playerSlider;
    CADisplayLink *playProgressDisplayLink;
    
    //Private variables
    NSString *_oldSessionCategory;

}
@end

@implementation ViewController
@synthesize lb_screenName;
@synthesize lb_status;
@synthesize lb_recording_status;
@synthesize recordButton, playButton, trashButton;
//#define SERVER_ADDRESS      @"216.127.64.33"
//#define SERVER_PORT         3262
#define SERVER_ADDRESS      @"mumble.fast-cast.net"
#define SERVER_PORT         64738
#define USER_CAPACITY       15
#define USER_LOCATION       @"US Central"
#define USER_NAME           @"admin"
#define USER_PASSWORD       @"air%EbeaG4"
#define SERVER_PASSWORD     @"fastcast"

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //Unique recording URL
    NSString *fileName = [[NSProcessInfo processInfo] globallyUniqueString];
    _recordingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a",fileName]];
    {
        playButton.enabled = NO;
        trashButton.enabled = NO;
    }
    
    // Define the recorder setting
    {
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        
        // Initiate and prepare the recorder
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:_recordingFilePath] settings:recordSetting error:nil];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
    }

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _audioPlayer.delegate = nil;
    [_audioPlayer stop];
    _audioPlayer = nil;
    
    _audioRecorder.delegate = nil;
    [_audioRecorder stop];
    _audioRecorder = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onConnectAction:(id)sender {
    _conn = [[MKConnection alloc] init];
    [_conn setDelegate:self];
    
    _model = [[MKServerModel alloc] initWithConnection:_conn];
    [_model addDelegate:self];
    
    loading_alert = [Dialogs showProgressAlertDialog:-1 message:@"Syncing with Server ..." delegate:self];

    [_conn connectToHost:SERVER_ADDRESS port:SERVER_PORT];

}

- (void) connectionOpened:(MKConnection *)conn {
    [loading_alert dismissWithClickedButtonIndex:0 animated:YES];
    lb_status.text = @"Connecting is successed!";
    [conn authenticateWithUsername:USER_NAME password:USER_PASSWORD accessTokens:nil];
}

- (void) connectionClosed:(MKConnection *)conn {

}

- (void)connection:(MKConnection *)conn closedWithError:(NSError *)err {
    [loading_alert dismissWithClickedButtonIndex:0 animated:YES];
    NSLog(@"connection error : %@", err);
    lb_status.text = @"Connecting is failed!";
}

- (void)connection:(MKConnection *)conn unableToConnectWithError:(NSError *)err {
    [loading_alert dismissWithClickedButtonIndex:0 animated:YES];
    NSLog(@"connection error : %@", err);
    lb_status.text = @"Connecting is failed!";

}

// Trust failure
- (void) connection:(MKConnection *)conn trustFailureInCertificateChain:(NSArray *)chain {
    // Ignore trust failures, for now...
    [conn setIgnoreSSLVerification:YES];
    [conn reconnect];
}

// Rejected
- (void) connection:(MKConnection *)conn rejectedWithReason:(MKRejectReason)reason explanation:(NSString *)explanation {
    
}

- (IBAction)onRecordAction:(id)sender {
    if (_isRecording == NO)
    {
        _isRecording = YES;
        [recordButton setTitle:@"Stop Record" forState:UIControlStateNormal];
        lb_recording_status.text = @"Recording";
        //UI Update
        {
            playButton.enabled = NO;
            trashButton.enabled = NO;
        }
        
        /*
         Create the recorder
         */
        if ([[NSFileManager defaultManager] fileExistsAtPath:_recordingFilePath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:_recordingFilePath error:nil];
        }
        
        _oldSessionCategory = [[AVAudioSession sharedInstance] category];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
        [_audioRecorder prepareToRecord];
        [_audioRecorder record];
    }
    else
    {
        _isRecording = NO;
        [recordButton setTitle:@"Record/Stop" forState:UIControlStateNormal];
        //UI Update
        {
            playButton.enabled = YES;
            trashButton.enabled = YES;
        }
        
        [_audioRecorder stop];
        [[AVAudioSession sharedInstance] setCategory:_oldSessionCategory error:nil];
    }

}

- (IBAction)onPlayAction:(id)sender {
    if(_isPlaying == NO) {
        _isPlaying = YES;
        lb_recording_status.text = @"Playing.";
        [playButton setTitle:@"Stop WAV" forState:UIControlStateNormal];
        _oldSessionCategory = [[AVAudioSession sharedInstance] category];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:_recordingFilePath] error:nil];
        _audioPlayer.delegate = self;
        _audioPlayer.meteringEnabled = YES;
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
        
        //UI Update
        {
            recordButton.enabled = NO;
            trashButton.enabled = NO;
        }
        
        //Start regular update
        {
            [playProgressDisplayLink invalidate];
            playProgressDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updatePlayProgress)];
            [playProgressDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        }
    }else{
        _isPlaying = NO;
        [playButton setTitle:@"Play WAV" forState:UIControlStateNormal];
        //UI Update
        {
            recordButton.enabled = YES;
            trashButton.enabled = YES;
        }
        
        {
            [playProgressDisplayLink invalidate];
            playProgressDisplayLink = nil;
            self.navigationItem.titleView = nil;
        }
        
        _audioPlayer.delegate = nil;
        [_audioPlayer stop];
        _audioPlayer = nil;
        
        [[AVAudioSession sharedInstance] setCategory:_oldSessionCategory error:nil];
    }
}

-(void)updatePlayProgress
{
}

- (IBAction)onDeleteAction:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Delete Recording"
                                                      style:UIAlertActionStyleDestructive
                                                    handler:^(UIAlertAction *action){
                                                        
                                                        [[NSFileManager defaultManager] removeItemAtPath:_recordingFilePath error:nil];
                                                        
                                                        playButton.enabled = NO;
                                                        trashButton.enabled = NO;
                                                        
                                                    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Cancel"
                                                      style:UIAlertActionStyleCancel
                                                    handler:nil];
    
    [alert addAction:action1];
    [alert addAction:action2];
    [self presentViewController:alert animated:YES completion:nil];

}

#pragma mark - AVAudioPlayerDelegate
/*
 Occurs when the audio player instance completes playback
 */
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    //To update UI on stop playing
    lb_recording_status.text = @"Playing is stopped.";
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    lb_recording_status.text = @"Recording is stopped.";
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    //    NSLog(@"%@: %@",NSStringFromSelector(_cmd),error);
}

@end
