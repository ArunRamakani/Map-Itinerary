//
//  HERERoutesDataProvider.h
//  MapItineraryManager
//
//  Created by Arun Ramakani on 24-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//
// Clase to support route search API call

#import "AFHTTPSessionManager.h"
#import "ApplicationConstants.h"
#import "Settings.h"
#import "RouteInfo.h"

// delegate to send back the success or failure route sesarch
@protocol HERERouteDataProviderDelegate <NSObject>

@required

-(void) successWithRoute:(RouteInfo*) routeInfo forIndex:(NSIndexPath*) forIndex;

@optional

-(void) didSearchFailWithError:(NSString *)errorString forIndex:(NSIndexPath*) forIndex;

@end


@interface HERERoutesDataProvider : AFHTTPSessionManager

// hold settings opject reference for constructing route request
@property (nonatomic, strong) Settings *routeSearchSettings;
@property (nonatomic, weak) id<HERERouteDataProviderDelegate> delegate;

// creat share instance
+(HERERoutesDataProvider*) sharedInstance;
// do route search operation
-(void) getRouteFromPlaces:(NSArray*) places forIndex:(NSIndexPath*) routeEditIndex;

@end
