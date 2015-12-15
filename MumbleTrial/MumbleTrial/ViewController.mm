//
//  ViewController.m
//  MumbleTrial
//
//  Created by common on 12/15/15.
//  Copyright © 2015 common. All rights reserved.
//

#import "ViewController.h"

#import "SVProgressHUD.h"
#import <MKConnection.h>
#import <MKServerModel.h>
#import <MKCertificate.h>
#import <AudioToolbox/AudioToolbox.h>

#define SERVER_ADDRESS @"104.131.172.77"
#define SERVER_PORT 64738
#define USER_CAPACITY 15
#define USER_LOCATION @"US Central"
#define USER_NAME @"admin1"
#define USER_PASSWORD @"air%EbeaG4"
#define SERVER_PASSWORD @"fastcast"

@interface ViewController ()<MKConnectionDelegate, MKServerModelDelegate>
{
    __weak IBOutlet UILabel *connectStatus;
    __weak IBOutlet UILabel *recordStatus;
    __weak IBOutlet UIButton *recordButton;
    __weak IBOutlet UIButton *playButton;
    __weak IBOutlet UIButton *deleteButton;
    MKConnection *_connection;
    MKServerModel *_serverModel;
    
    // for Record;
    bool isInited;
    NSTimer *timer;
    u_int64_t secs;
    bool newRecord;
}

@end

@implementation ViewController


char *OSTypeToStr(char *buf, OSType t)
{
    char *p = buf;
    char str[4], *q = str;
    *(UInt32 *)str = CFSwapInt32(t);
    for (int i = 0; i < 4; ++i) {
        if (isprint(*q) && *q != '\\')
            *p++ = *q++;
        else {
            sprintf(p, "\\x%02x", *q++);
            p += 4;
        }
    }
    *p = '\0';
    return buf;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // server infor fastcast.mumble.com
    // 3262
    // user capacity: 15
    // location: US Central
    // Admin Username: admin
    // Admin Password: air%EbeaG4
    // Server password: fastcast
    
    connectStatus.text = @"Disconnected!";
    recordStatus.text = @"Stopped";
    if(!isInited)
    {
        isInited = YES;
        secs = 0;
    }
    timer = nil;
    recordFilePath = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents/recordedFile.caf"];
    secs = 0;
    newRecord = true;
    playButton.enabled = false;
    deleteButton.enabled = false;
}

- (void) stopRecord {
    // Disconnect our level meter from the audio queue
    recorder->StopRecord();
    // dispose the previous playback queue
    player->DisposeQueue(true);
    
    // now create a new queue for the recorded file
    CFStringRef str = CFStringCreateWithFileSystemRepresentation(kCFAllocatorDefault, [recordFilePath fileSystemRepresentation]);
    player->CreateQueueForFile(str);
    playButton.enabled = YES;
}

- (void) pausePlayQueue {
    player->PauseQueue();
    playbackWasPaused = YES;
}

- (void) stopPlayQueue {
    player->StopQueue();
    recordButton.enabled = true;
}

- (void)showError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    });
}

#pragma mark Initialization routines
- (void)awakeFromNib
{
    // Allocate our singleton instance for the recorder & player object
    
    recorder = new AQRecorder();
    player = new AQPlayer();
    
    OSStatus error = AudioSessionInitialize(nil, nil, interruptionListener, (__bridge void*)self);
    if (error) printf("ERROR INITIALIZING AUDIO SESSION! %d\n", (int)error);
    else
    {
        UInt32 category = kAudioSessionCategory_PlayAndRecord;
        error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
        if (error) printf("couldn't set audio category!");
        
        error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, (__bridge void*)self);
        if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);
        UInt32 inputAvailable = 0;
        UInt32 size = sizeof(inputAvailable);
        
        // we do not want to allow recording if input is not available
        error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
        if (error) printf("ERROR GETTING INPUT AVAILABILITY! %d\n", (int)error);
        recordButton.enabled = (inputAvailable) ? YES : NO;
        
        // we also need to listen to see if input availability changes
        error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, propListener, (__bridge void*)self);
        if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);
        
        error = AudioSessionSetActive(true);
        if (error) printf("AudioSessionSetActive (true) failed");
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueResumed:) name:@"playbackQueueResumed" object:nil];
    
    // disable the play button since we have no recording to play yet
    playButton.enabled = NO;
    playbackWasInterrupted = NO;
    playbackWasPaused = NO;
}

void interruptionListener(	void *	inClientData,
                          UInt32	inInterruptionState)
{
    ViewController *THIS = (__bridge ViewController*)inClientData;
    if (inInterruptionState == kAudioSessionBeginInterruption)
    {
        if (THIS->recorder->IsRunning()) {
            [THIS stopRecord];
        }
        else if (THIS->player->IsRunning()) {
            //the queue will stop itself on an interruption, we just need to update the UI
            [[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:THIS];
            THIS->playbackWasInterrupted = YES;
        }
    }
    else if ((inInterruptionState == kAudioSessionEndInterruption) && THIS->playbackWasInterrupted)
    {
        // we were playing back when we were interrupted, so reset and resume now
        THIS->player->StartQueue(true);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:THIS];
        THIS->playbackWasInterrupted = NO;
    }
}

void propListener(	void *                  inClientData,
                  AudioSessionPropertyID	inID,
                  UInt32                  inDataSize,
                  const void *            inData)
{
    ViewController *THIS = (__bridge ViewController*)inClientData;
    if (inID == kAudioSessionProperty_AudioRouteChange)
    {
        CFDictionaryRef routeDictionary = (CFDictionaryRef)inData;
        //CFShow(routeDictionary);
        CFNumberRef reason = (CFNumberRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
        SInt32 reasonVal;
        CFNumberGetValue(reason, kCFNumberSInt32Type, &reasonVal);
        if (reasonVal != kAudioSessionRouteChangeReason_CategoryChange)
        {
            
            if (reasonVal == kAudioSessionRouteChangeReason_OldDeviceUnavailable)
            {
                if (THIS->player->IsRunning()) {
                    [THIS pausePlayQueue];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:THIS];
                }
            }
            
            // stop the queue if we had a non-policy route change
            if (THIS->recorder->IsRunning()) {
                [THIS stopRecord];
            }
        }
    }
    else if (inID == kAudioSessionProperty_AudioInputAvailable)
    {
        if (inDataSize == sizeof(UInt32)) {
            UInt32 isAvailable = *(UInt32*)inData;
            // disable recording if input is not available
            THIS->recordButton.enabled = (isAvailable > 0) ? YES : NO;
        }
    }
}

# pragma mark Notification routines
- (void)playbackQueueStopped:(NSNotification *)note
{
    recordButton.enabled = YES;
    playButton.enabled = YES;
    deleteButton.enabled = YES;
    [timer invalidate];
    timer = nil;
    //secs = 0;
}

- (void)playbackQueueResumed:(NSNotification *)note
{
    playButton.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onConnect:(id)sender {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    if (_connection) {
        connectStatus.text = @"Disconnecting";
        [_connection disconnect];
        _connection = nil;
        return;
    }else{
        connectStatus.text = @"Connecting";
        _connection = [[MKConnection alloc] init];
        [_connection setDelegate:self];
        
        _serverModel = [[MKServerModel alloc] initWithConnection:_connection];
        [_serverModel addDelegate:self];
        
        //    // Set the connection's client cert if one is set in the app's preferences...
        //    NSData *certPersistentId = [[NSUserDefaults standardUserDefaults] objectForKey:@"DefaultCertificate"];
        //    if (certPersistentId != nil) {
        //        NSArray *certChain = [MUCertificateChainBuilder buildChainFromPersistentRef:certPersistentId];
        //        [_connection setCertificateChain:certChain];
        //    }
        
        [_connection connectToHost:SERVER_ADDRESS port:SERVER_PORT];
    }
}

- (void) updateTime {
    
}

- (IBAction)onRecord:(id)sender {
    if(timer) {
        if (recorder->IsRunning()) {
            [timer invalidate];
            //secs = 0;
            timer = nil;
            
            if (recorder->IsRunning()) // If we are currently recording, stop and save the file.
            {
                recorder->pause();
                newRecord = false;
            }
            else if(player->IsRunning())
            {
                OSStatus result = player->StopQueue();
                if (result == noErr)
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:self];
                playbackWasInterrupted = YES;
            }
            playButton.enabled = YES;
            deleteButton.enabled = YES;
            recordStatus.text = @"Stopped";
        }
        return;
    }
    recordStatus.text = @"Recording";
    playButton.enabled = NO;
//    btnStart.enabled = NO;
    deleteButton.enabled = NO;
    if (!newRecord) {//contnue recording
        timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
        recorder->continueRecord();
        return;
    }
    secs = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    // Start the recorder
    CFStringRef str = CFStringCreateWithFileSystemRepresentation(kCFAllocatorDefault, [recordFilePath fileSystemRepresentation]);
    recorder->StartRecord(str);
    newRecord = false;
}

- (IBAction)playWav:(id)sender {
    recordButton.enabled = NO;
    deleteButton.enabled = NO;
    if (!newRecord) {
        [self stopRecord];
        newRecord = true;
    }
    if (player->IsRunning())
    {
        if (playbackWasPaused) {
            OSStatus result = player->StartQueue(true);
            if (result == noErr)
                [[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:self];
        }
        else
            [self stopPlayQueue];
    }
    else
    {
        OSStatus result = player->StartQueue(false);
        if (result == noErr)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:self];
    }
}
- (IBAction)deleteWav:(id)sender {
    secs = 0;
    if(timer)
    {
        [timer invalidate];
        timer = nil;
    }
    
    if (!newRecord) {
        [self stopRecord];
        newRecord = true;
    }
    if (player->IsRunning())
        player->StopQueue();
    newRecord = true;
    recordButton.enabled = YES;
    playButton.enabled = NO;
    deleteButton.enabled = NO;
}

- (void) teardownConnection {
    [_serverModel removeDelegate:self];
    _serverModel = nil;
    [_connection setDelegate:nil];
    [_connection disconnect];
    _connection = nil;
//    [_timer invalidate];// todo
}

- (void) hideConnectingView {
    [SVProgressHUD dismiss];
}


// MKConnection delegate
#pragma mark - MKConnectionDelegate

- (void) connectionOpened:(MKConnection *)conn {
    [conn authenticateWithUsername:USER_NAME password:USER_PASSWORD accessTokens:nil];
}

- (void) connection:(MKConnection *)conn closedWithError:(NSError *)err {
    [self hideConnectingView];
    connectStatus.text = @"Disconnected!";
    if (err) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Connection closed" message:err.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:controller animated:true completion:nil];
        [self teardownConnection];
    }
}

- (void) connection:(MKConnection*)conn unableToConnectWithError:(NSError *)err {
//    [self hideConnectingView]; //todo
    
    NSString *msg = [err localizedDescription];
    
    // errSSLClosedAbort: "connection closed via error".
    //
    // This is the error we get when users hit a global ban on the server.
    // Ideally, we'd provide better descriptions for more of these errors,
    // but when using NSStream's TLS support, the NSErrors we get are simply
    // OSStatus codes in an NSError wrapper without a useful description.
    //
    // In the future, MumbleKit should probably wrap the SecureTransport range of
    // OSStatus codes to improve this situation, but this will do for now.
    if ([[err domain] isEqualToString:NSOSStatusErrorDomain] && [err code] == -9806) {
        msg = NSLocalizedString(@"The TLS connection was closed due to an error.\n\n"
                                @"The server might be temporarily rejecting your connection because you have "
                                @"attempted to connect too many times in a row.", nil);
    }
    
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Unable to connect" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:true completion:nil];

    
    [self teardownConnection];
}

// The connection encountered an invalid SSL certificate chain.
- (void) connection:(MKConnection *)conn trustFailureInCertificateChain:(NSArray *)chain {
    // Check the database whether the user trusts the leaf certificate of this server.
//    NSString *storedDigest = [MUDatabase digestForServerWithHostname:[conn hostname] port:[conn port]];
    MKCertificate *cert = [[conn peerCertificates] objectAtIndex:0];
    NSString *serverDigest = [cert hexDigest];
    if (serverDigest) {
        if ([serverDigest isEqualToString:serverDigest]) {
            // Match
            [conn setIgnoreSSLVerification:YES];
            [conn reconnect];
            return;
        } else {
            // Mismatch.  The server is using a new certificate, different from the one it previously
            // presented to us.
            [self hideConnectingView];
            NSString *title = NSLocalizedString(@"Certificate Mismatch", nil);
            NSString *msg = NSLocalizedString(@"The server presented a different certificate than the one stored for this server", nil);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                  otherButtonTitles:nil];
            [alert addButtonWithTitle:NSLocalizedString(@"Ignore", nil)];
            [alert addButtonWithTitle:NSLocalizedString(@"Trust New Certificate", nil)];
            [alert addButtonWithTitle:NSLocalizedString(@"Show Certificates", nil)];
            [alert show];
        }
    } else {
        // No certhash of this certificate in the database for this hostname-port combo.  Let the user decide
        // what to do.
        [self hideConnectingView];
        NSString *title = NSLocalizedString(@"Unable to validate server certificate", nil);
        NSString *msg = NSLocalizedString(@"Mumble was unable to validate the certificate chain of the server.", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                              otherButtonTitles:nil];
        [alert addButtonWithTitle:NSLocalizedString(@"Ignore", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"Trust Certificate", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"Show Certificates", nil)];
        [alert show];
    }
}

// The server rejected our connection.
- (void) connection:(MKConnection *)conn rejectedWithReason:(MKRejectReason)reason explanation:(NSString *)explanation {
    NSString *title = NSLocalizedString(@"Connection Rejected", nil);
    NSString *msg = nil;
    UIAlertView *alert = nil;
    
    [self hideConnectingView];
    [self teardownConnection];
    
    switch (reason) {
        case MKRejectReasonNone:
            msg = NSLocalizedString(@"No reason", nil);
            alert = [[UIAlertView alloc] initWithTitle:title
                                               message:msg
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                     otherButtonTitles:nil];
            break;
        case MKRejectReasonWrongVersion:
            msg = @"Client/server version mismatch";
            alert = [[UIAlertView alloc] initWithTitle:title
                                               message:msg
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                     otherButtonTitles:nil];
            
            break;
        case MKRejectReasonInvalidUsername:
            msg = NSLocalizedString(@"Invalid username", nil);
            alert = [[UIAlertView alloc] initWithTitle:title
                                               message:msg
                                              delegate:self
                                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                     otherButtonTitles:NSLocalizedString(@"Reconnect", nil), nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[alert textFieldAtIndex:0] setText:@"admin"];
            break;
        case MKRejectReasonWrongUserPassword:
            msg = NSLocalizedString(@"Wrong certificate or password for existing user", nil);
            alert = [[UIAlertView alloc] initWithTitle:title
                                               message:msg
                                              delegate:self
                                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                     otherButtonTitles:NSLocalizedString(@"Reconnect", nil), nil];
            [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
            [[alert textFieldAtIndex:0] setText:@"air%EbeaG4"];
            break;
        case MKRejectReasonWrongServerPassword:
            msg = NSLocalizedString(@"Wrong server password", nil);
            alert = [[UIAlertView alloc] initWithTitle:title
                                               message:msg
                                              delegate:self
                                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                     otherButtonTitles:NSLocalizedString(@"Reconnect", nil), nil];
            [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
            [[alert textFieldAtIndex:0] setText:@"air%EbeaG4"];
            break;
        case MKRejectReasonUsernameInUse:
            msg = NSLocalizedString(@"Username already in use", nil);
            alert = [[UIAlertView alloc] initWithTitle:title
                                               message:msg
                                              delegate:self
                                     cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                     otherButtonTitles:NSLocalizedString(@"Reconnect", nil), nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [[alert textFieldAtIndex:0] setText:@"admin"];
            break;
        case MKRejectReasonServerIsFull:
            msg = NSLocalizedString(@"Server is full", nil);
            alert = [[UIAlertView alloc] initWithTitle:title
                                               message:msg
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                     otherButtonTitles:nil];
            break;
        case MKRejectReasonNoCertificate:
            msg = NSLocalizedString(@"A certificate is needed to connect to this server", nil);
            alert = [[UIAlertView alloc] initWithTitle:title
                                               message:msg
                                              delegate:nil
                                     cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                     otherButtonTitles:nil];
            break;
    }
    
//    _rejectAlertView = alert;
//    _rejectReason = reason;
    
    [alert show];
}


#pragma mark - MKServerModelDelegate

- (void) serverModel:(MKServerModel *)model joinedServerAsUser:(MKUser *)user {
//    [MUDatabase storeUsername:[user userName] forServerWithHostname:[model hostname] port:[model port]];
    connectStatus.text = @"Connected!";
    [self hideConnectingView];
    
//    [_serverRoot takeOwnershipOfConnectionDelegate];
    
//    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
//        if (MUGetOperatingSystemVersion() >= MUMBLE_OS_IOS_7) {
//            [_serverRoot setTransitioningDelegate:_transitioningDelegate];
//        } else {
//            [_serverRoot setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
//        }
//    }
//    
//    [_parentViewController presentModalViewController:_serverRoot animated:YES];
//    [_parentViewController release];
//    _parentViewController = nil;
}

@end
