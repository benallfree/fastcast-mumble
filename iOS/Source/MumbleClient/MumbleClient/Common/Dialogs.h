//
//  Dialogs.h
//  FormViewer
//
//  Created by ISO Developers on 01.05.15.
//  Copyright (c) 2015 ExtremeLabs-FZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Dialogs : NSObject

+ (void) showAlertDialog:(NSInteger) tag
                 message:(NSString*) message
                delegate:(id) delegate;

+ (void) showSimpleAlertDialog:(NSInteger) tag
                       message:(NSString*) message
                      delegate:(id) delegate;

+ (UIAlertView*) showProgressAlertDialog:(NSInteger) tag
                                 message:(NSString*) message
                                delegate:(id) delegate;
+ (NSInteger) cancel;

+ (NSInteger) ok;
@end
