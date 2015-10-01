//
//  ItineraryTableCell.h
//  MapItineraryManager
//
//  Created by Arun Ramakani on 23-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//
// Custom table cell to display user itinerary

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ItineraryTableCell : UITableViewCell

//Link all itinerary lables from Xib
@property (nonatomic, weak) IBOutlet UILabel        *createDate;
@property (nonatomic, weak) IBOutlet UILabel        *itineraryPath;
@property (nonatomic, weak) IBOutlet UILabel        *itineraryname;
@property (nonatomic, weak) IBOutlet UIButton       *editItinerary;

// Set cell content called for each row of cached cell to update only the data
-(void) setCellcontent:(NSManagedObject*) itinerery;

@end
