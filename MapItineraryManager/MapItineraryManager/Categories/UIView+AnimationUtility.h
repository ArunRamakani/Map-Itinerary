//
//  UIView+AnimationUtility.h
//  MapItineraryManager
//
//  Created by Arun Ramakani on 22-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//
// utility created to add any view animation
#import <UIKit/UIKit.h>

@interface UIView (AnimationUtility)

// it creates a smapshot view of the providing view - used for cell drag dro animation
-(UIView*) createViewSnapShot;

@end
