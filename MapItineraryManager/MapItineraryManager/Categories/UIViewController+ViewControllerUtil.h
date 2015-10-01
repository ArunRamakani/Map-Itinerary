//
//  UIViewController+ViewControllerUtil.h
//  MapItineraryManager
//
//  Created by Arun Ramakani on 23-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//
// untiliy to add any view controller utilities
#import <UIKit/UIKit.h>

@interface UIViewController (ViewControllerUtil)

// present alert for the calling VC
-(void) presentAlertWithMessage:(NSString*) message;

@end
