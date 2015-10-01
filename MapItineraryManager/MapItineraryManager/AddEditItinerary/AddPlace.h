//
//  AddPlace.h
//  MapItineraryManager
//
//  Created by Arun Ramakani on 18-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//
// View to display places search reult and supports search operation
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "HEREPlacesDataProvider.h"

@interface AddPlace : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, HEREPlacesDataProviderDelegate>

//Link all ui elements from Xib

@property (nonatomic, weak) IBOutlet UITableView *placeTable;
@property (nonatomic, weak) IBOutlet UISearchBar *placesSearchBar;
@property (nonatomic, weak) IBOutlet UILabel *placeHoldertext;


@end
