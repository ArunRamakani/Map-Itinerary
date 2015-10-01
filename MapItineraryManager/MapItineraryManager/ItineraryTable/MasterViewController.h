//
//  MasterViewController.h
//  MapItineraryManager
//
//  Created by Arun Ramakani on 18-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//
// View controller to support create / store the user ininerary. Manages core data storage with the help of tech controller

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "HERERoutesDataProvider.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, HERERouteDataProviderDelegate>


//Variable to hold the details view conroller to display the route map/info
@property (strong, nonatomic) DetailViewController          *detailViewController;

// Fetch controller/ Nsmanagedobject context to manage itinerary create / save / Edit
@property (strong, nonatomic) NSFetchedResultsController    *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext        *managedObjectContext;

// Used to create / Edit itinerary places object in core date once the itineray save action is clicked from the AddEditPlace view
-(void) handleSaveItinerary :(NSArray*) itinerary itineraryName:(NSString*) itineraryName exitIndex:(NSIndexPath*) editPath;

// Method to trigger fetching route info for the given row ID for the itinerary
-(void) refreshRouteForRow:(long) row;


@end

