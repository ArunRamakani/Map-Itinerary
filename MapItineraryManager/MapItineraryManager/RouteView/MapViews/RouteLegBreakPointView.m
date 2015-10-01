//
//  RouteLegBreakPointView.m
//  MapItineraryManager
//
//  Created by Arun Ramakani on 27-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//

#import "RouteLegBreakPointView.h"


@implementation RouteLegBreakPointView


// configure  MKannotation view
-(void) configurePinView {
    
    // Enable Callout
    self.canShowCallout = YES;
    self.calloutOffset = CGPointMake(-5, 5);
    self.enabled = YES;
    
    //Adding annotations callout accessoryViews
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"EditRoute"] forState:UIControlStateNormal];
    rightButton.tag = 1000;
    self.rightCalloutAccessoryView = rightButton;
    
    UIButton *leftInfo = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"EditRoute"] forState:UIControlStateNormal];
    leftInfo.tag = 1001;
    self.leftCalloutAccessoryView = leftInfo;
    
    //set anotation image
    self.image = [UIImage imageNamed:@"MapPin"];
}




@end
