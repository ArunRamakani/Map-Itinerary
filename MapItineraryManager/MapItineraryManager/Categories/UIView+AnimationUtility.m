//
//  UIView+AnimationUtility.m
//  MapItineraryManager
//
//  Created by Arun Ramakani on 22-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//

#import "UIView+AnimationUtility.h"

@implementation UIView (AnimationUtility)

// it creates a smapshot view of the providing view - used for cell drag dro animation in add edit page to rearrance the itinerary
-(UIView*) createViewSnapShot {
    
    // Start and use a graphic context to render the given view as image and close the context
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Create UIImage view with created image snap
    UIImageView *snapView = [[UIImageView alloc] initWithImage:snapImage];
    return snapView;
}


@end
