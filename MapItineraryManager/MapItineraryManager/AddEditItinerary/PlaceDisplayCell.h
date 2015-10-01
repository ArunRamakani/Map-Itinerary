//
//  PlaceDisplayCell.h
//  MapItineraryManager
//
//  Created by Arun Ramakani on 18-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//
// Table view cell to display palcess view in App place and AddEdit Place view 
#import <UIKit/UIKit.h>
#import "Place.h"

@interface PlaceDisplayCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView    *placeCategoryImag;
@property (nonatomic, weak) IBOutlet UILabel        *placeName;
@property (nonatomic, weak) IBOutlet UILabel        *visinityDistance;

// Set cell content called for each row of cached cell to update only the data
-(void) setCellcontent:(Place*) place isAddPlace:(BOOL) isAddPlace;

@end
