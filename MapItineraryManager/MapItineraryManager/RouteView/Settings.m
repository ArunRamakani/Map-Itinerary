//
//  Settings.m
//  MapItineraryManager
//
//  Created by Arun Ramakani on 24-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//

#import "Settings.h"


@implementation Settings

// initialize all properties with default or NSUserdefault value 
- (id) init {
    
    self = [super init];
    
    if(self){
        
        if([[NSUserDefaults standardUserDefaults] valueForKey:TrafficModeSetting] == nil){
            [[NSUserDefaults standardUserDefaults] setObject:TrafficModeDefault forKey:TrafficModeSetting];
            self.trafficMode = TrafficModeDefault;
        } else {
            self.trafficMode = [[NSUserDefaults standardUserDefaults] valueForKey:TrafficModeSetting];
        }
        
        if([[NSUserDefaults standardUserDefaults] valueForKey:TransportModeSetting] == nil){
            [[NSUserDefaults standardUserDefaults] setObject:TransportModeDefault forKey:TransportModeSetting];
            self.transportMode = TransportModeDefault;
        } else {
            self.transportMode = [[NSUserDefaults standardUserDefaults] valueForKey:TransportModeSetting];
        }
        
        if([[NSUserDefaults standardUserDefaults] valueForKey:RouteModeSetting] == nil){
            [[NSUserDefaults standardUserDefaults] setObject:RouteModeDefault forKey:RouteModeSetting];
            self.routeMode = RouteModeDefault;
        } else {
            self.routeMode = [[NSUserDefaults standardUserDefaults] valueForKey:RouteModeSetting];
        }
        
        if([[NSUserDefaults standardUserDefaults] valueForKey:WaypointSetting] == nil){
            [[NSUserDefaults standardUserDefaults] setObject:WaypointDefault forKey:WaypointSetting];
            self.waypointType = WaypointDefault;
        } else {
            self.waypointType = [[NSUserDefaults standardUserDefaults] valueForKey:WaypointSetting];
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return self;
}

// update property values with latest user selected values from user default. Called by save action from setting VC
-(void) updateSettigs {
    
    self.trafficMode = [[NSUserDefaults standardUserDefaults] valueForKey:TrafficModeSetting];
    self.transportMode = [[NSUserDefaults standardUserDefaults] valueForKey:TransportModeSetting];
    self.routeMode = [[NSUserDefaults standardUserDefaults] valueForKey:RouteModeSetting];
    self.waypointType = [[NSUserDefaults standardUserDefaults] valueForKey:WaypointSetting];
    
    
}

@end
