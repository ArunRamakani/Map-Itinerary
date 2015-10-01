//
//  PlaceDisplayCell.m
//  MapItineraryManager
//
//  Created by Arun Ramakani on 18-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//

#import "PlaceDisplayCell.h"

@implementation PlaceDisplayCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    _placeName.lineBreakMode = NSLineBreakByClipping;
    _visinityDistance.lineBreakMode = NSLineBreakByClipping;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


// Set cell content called for each row of cached cell to update only the data

-(void) setCellcontent:(Place*) place isAddPlace:(BOOL) isAddPlace {
    
    _placeName.text = place.title;
    _visinityDistance.text = [NSString stringWithFormat:@"%@, %@" , place.categoryTite, place.vacinity];
    
    if(isAddPlace) {
        [_placeCategoryImag setImage:[UIImage imageNamed:place.icon]];
    }
    
    
}

@end
