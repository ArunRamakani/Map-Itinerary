//
//  DetailViewController.h
//  MapItineraryManager
//
//  Created by Arun Ramakani on 18-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//
// View controller to display route in map view . Also displays roure instruction in a tab bar parallel to Map tab bar section.
//This VC also act as a base for opening route summary view, Edit Itinerary/Route view. This act as details view for the base split view controller

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import "MasterViewController.h"


@interface DetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, MKMapViewDelegate>

// reference of route data and it row with respect to master view controller
@property (strong, nonatomic) id detailItem;
@property (assign, nonatomic) long row;

// weak delegate reference of splitview controllers master view.
@property (weak, nonatomic) MasterViewController *delegateMaster;


// reference IB view elements to display route in map & route instraction
@property (weak, nonatomic) IBOutlet MKMapView    *mapView;
@property (weak, nonatomic) IBOutlet UITableView  *routeInstructions;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;


// Navigation bar button action link for rout referesh and route settings
-(IBAction)refreshButtonClicked:(id)sender;
-(IBAction)settingButtonClicked:(id)sender;

@end

