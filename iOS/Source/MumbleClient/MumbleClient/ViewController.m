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
}
@end

@implementation ViewController
@synthesize lb_screenName;
@synthesize lb_status;
//#define SERVER_ADDRESS      @"216.127.64.33"
//#define SERVER_PORT         3262
#define SERVER_ADDRESS      @"104.131.172.77"
#define SERVER_PORT         64738
#define USER_CAPACITY       15
#define USER_LOCATION       @"US Central"
#define USER_NAME           @"admin"
#define USER_PASSWORD       @"air%EbeaG4"
#define SERVER_PASSWORD     @"fastcast"

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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


@end
