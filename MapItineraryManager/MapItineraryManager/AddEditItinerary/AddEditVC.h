//
//  AddEditVC.h
//  MapItineraryManager
//
//  Created by Arun Ramakani on 18-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//
// This view helps us to create the itinerary, support add new places , re arrange palces order etc

#import <UIKit/UIKit.h>
#import "Place.h"

@interface AddEditVC : UIViewController <UITableViewDataSource, UITableViewDelegate>

//Link all ui elements from Xib
@property (nonatomic, weak) IBOutlet UITableView    *itineraryTable;
@property (nonatomic, weak) IBOutlet UILabel        *placeHoldertext;

// Itinearry index and places array ref
@property (nonatomic, strong) NSMutableArray        *placesForRoute;
@property (nonatomic, strong) NSIndexPath           *editIndex;


// Call back from places view to add place into array
-(void) handleSelectedPlace:(Place*) place;
-(void) addPlace;
-(void) dismiss;

@end
