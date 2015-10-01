//
//  CurrentLocationProvider.m
//  MapItineraryManager
//
//  Created by Arun Ramakani on 20-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//

#import "CurrentLocationProvider.h"


@interface CurrentLocationProvider ()
{
    // Variable to tarck the status of locarion service running
    BOOL isLocationMoniterRunning;
}
@end

@implementation CurrentLocationProvider

#pragma mark - initialize singulton

+(CurrentLocationProvider*) sharedInstance{
    static CurrentLocationProvider *sharedLocatioManager;
    static dispatch_once_t singleton;
    dispatch_once(&singleton,^{
        sharedLocatioManager = [[self alloc] init];
    });
    return sharedLocatioManager;
}

-(instancetype) init {
    
    self = [super init];
    if(self){
        
        // default if we are not able to get actual lat/long for search process
        
        CLLocationDegrees latitude = 52.5310;
        CLLocationDegrees longitude = 13.3848;
        
        _currentLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        
        // Configure location manager
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [_locationManager requestWhenInUseAuthorization];
        }
        
        
        isLocationMoniterRunning = FALSE;
    }
    return self;
}

#pragma mark Start / Stop location services

// stop / start monitering location update from app delegate during application enter background and foreground
- (void) startLocationMoniter{
    if(!isLocationMoniterRunning){
        [_locationManager startUpdatingLocation];
        isLocationMoniterRunning = TRUE;
    }
    
}
- (void) stopLocationMoniter{
    if(isLocationMoniterRunning){
        [_locationManager stopUpdatingLocation];
        isLocationMoniterRunning = FALSE;
    }
}


#pragma mark CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    _currentLocation = [locations lastObject];
}

// Print location services change
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"current Location failed with error :  %@",error.localizedDescription);
}

// When thre is a change in state of settings authoritized for location services , app has to ask for another solutionsettings 
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [_locationManager requestWhenInUseAuthorization];
    }
}

#pragma mark Curret location exposed to build serach context

// provided commo seperated lat long to input search context for places search
- (NSString*) getCommaSeperatedLatLong{
    return [NSString stringWithFormat:@"%f,%f", _currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude];
}



@end
