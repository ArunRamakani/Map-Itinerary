//
//  Settings.h
//  MapItineraryManager
//
//  Created by Arun Ramakani on 24-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//

// setting model to hold the reference of user prefered reference setting
#import <Foundation/Foundation.h>



// Constance that is used to store and read the user preference from NSUserDefault

#define TrafficModeSetting @"Traffic Mode"
#define TrafficModeDefault @"disabled"

#define TransportModeSetting @"Transport Mode"
#define TransportModeDefault @"car"

#define RouteModeSetting @"Route Mode"
#define RouteModeDefault @"fastest"

#define WaypointSetting @"Waypoint Type"
#define WaypointDefault @"stopOver"


@interface Settings : NSObject

// Data representation basic four configuration of Traffic mode, Transport Mode, Route mode and way point type
@property (nonatomic, strong) NSString *trafficMode;
@property (nonatomic, strong) NSString *transportMode;
@property (nonatomic, strong) NSString *routeMode;
@property (nonatomic, strong) NSString *waypointType;


// initialize all properties with default or NSUserdefault value 
- (id) init;

// update property values with latest user selected values
-(void) updateSettigs;

@end
