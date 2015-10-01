//
//  UIViewController+ViewControllerUtil.m
//  MapItineraryManager
//
//  Created by Arun Ramakani on 23-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//

#import "UIViewController+ViewControllerUtil.h"

@implementation UIViewController (ViewControllerUtil)

// present alert for the calling VC with provided message
-(void) presentAlertWithMessage:(NSString*) message {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   
                               }];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:TRUE completion:^{
        
    }];
    
}


@end
