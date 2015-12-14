//
//  Dialogs.m
//  FormViewer
//
//  Created by ISO Developers on 01.05.15.
//  Copyright (c) 2015 ExtremeLabs-FZ. All rights reserved.
//

#import "Dialogs.h"
#import "Util.h"

static const NSInteger OK_BUTTON = 1;

static const NSInteger CANCEL_BUTTON = 0;

@implementation Dialogs

+ (void) showAlertDialog:(NSInteger) tag
                 message:(NSString*) message
                delegate:(id) delegate {
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Alert"
                                                   message:message
                                                  delegate:delegate
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Ok", nil
                          ];
    [alert setTag:tag];
    [alert show];
}

+ (void) showSimpleAlertDialog:(NSInteger) tag
                 message:(NSString*) message
                delegate:(id) delegate {
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Alert"
                                                   message:message
                                                  delegate:delegate
                                         cancelButtonTitle:@"Ok"
                                         otherButtonTitles:nil
                          ];
    [alert setTag:tag];
    [alert show];
}

+ (UIAlertView*) showProgressAlertDialog:(NSInteger) tag
                       message:(NSString*) message
                      delegate:(id) delegate {
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Please wait ..."
                                                   message:message
                                                  delegate:delegate
                                         cancelButtonTitle:nil
                                         otherButtonTitles:nil
                          ];
    [alert setTag:tag];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
    [indicator startAnimating];
    
    [alert addSubview:indicator];
                                          
    [alert show];
    return alert;
}

+ (NSInteger) cancel {
    return CANCEL_BUTTON;
}

+ (NSInteger) ok {
    return OK_BUTTON;
}
@end
