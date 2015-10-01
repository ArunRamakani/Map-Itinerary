//
//  ItineraryTableCell.m
//  MapItineraryManager
//
//  Created by Arun Ramakani on 23-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//

#import "ItineraryTableCell.h"
#import "Place.h"

@implementation ItineraryTableCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// Set cell content called for each row of cached cell to update only the data
-(void) setCellcontent:(NSManagedObject*) itinerery {
    
    NSArray *places = [itinerery valueForKey:@"placesArray"];
    NSDate *created = [itinerery valueForKey:@"timeStamp"];
    
    // set itinerary date & name
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM dd, HH:mm"];
    NSString *dateString = [format stringFromDate:created];
    self.createDate.text = [NSString stringWithFormat:@"Created Date : %@", dateString];
    self.itineraryname.text = [itinerery valueForKey:@"itineraryName"];
    
    // generate path
    NSMutableString *path = [NSMutableString string];
    
    BOOL pathNeeded = FALSE;
    for(Place *place in places){
        if(pathNeeded){
            [path appendString:@" > "];
        }
        [path appendString:place.title];
        pathNeeded = TRUE;
    }

    self.itineraryPath.text = [NSString stringWithString:path];;
}

@end
