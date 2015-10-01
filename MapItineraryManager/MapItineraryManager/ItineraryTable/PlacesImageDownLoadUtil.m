//
//  PlacesImageDownLoadUtil.m
//  MapItineraryManager
//
//  Created by Arun Ramakani on 9/30/15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//

#import "PlacesImageDownLoadUtil.h"

@implementation PlacesImageDownLoadUtil

+(void) downloadPlacesImage {
    
    NSMutableArray *urlStrings = [[NSMutableArray alloc] init];
    
    int i = 0;
    // Total number of images is identified as 43 on random analysis
    // Create URL string array
    while (i<43){
        i = i +1;
        NSString *string = [NSString stringWithFormat:@"%d", i];
        if(string.length == 1)
            string = [NSString stringWithFormat:@"0%@", string];
        
        
        string = [NSString stringWithFormat:@"https://download.st.vcdn.nokia.com/p/d/places2_stg/icons/categories/%@.icon", string];
        
        [urlStrings addObject:string];
    }
    
    // Download all url image and store in document directory. Then this image can be copied to form assert catalog
    for (NSString *urlString in urlStrings)
    {
        NSURL *url = [NSURL URLWithString:urlString];
        NSString *fileName = [[[url lastPathComponent] componentsSeparatedByString:@"."] objectAtIndex:0];
        
        
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if ( urlData )
        {
            NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString  *documentsDirectory = [paths objectAtIndex:0];
            
            NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,[NSString stringWithFormat:@"%@.png",fileName]];
            [urlData writeToFile:filePath atomically:YES];
        }
    }
    
}
@end
