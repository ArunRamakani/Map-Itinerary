//
//  AddPlace.m
//  MapItineraryManager
//
//  Created by Arun Ramakani on 18-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//

#import "AddPlace.h"
#import "PlaceDisplayCell.h"
#import "AddEditVC.h"
#import "UIViewController+ViewControllerUtil.h"
#import "MRProgress.h"
#import "AppDelegate.h"



@interface AddPlace ()

// Array of search result places
@property (nonatomic, strong) NSMutableArray *myPlaces;

@end

@implementation AddPlace

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"Add Place";
    // register the table view cell for the given table
    [_placeTable registerNib:[UINib nibWithNibName:@"PlaceDisplayCell" bundle:nil]  forCellReuseIdentifier:@"ItineraryPlaceCell"];
    
    // Set programatic auto layout for search bar  navigation bar, also for place holder
    [self.navigationController.topViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:_placesSearchBar
                                                                                                 attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                                                                    toItem:self.navigationController.topViewController.topLayoutGuide attribute:NSLayoutAttributeBottom
                                                                                                multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.placeHoldertext
                                                                                                 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                                                                    toItem:self.view attribute:NSLayoutAttributeBottom
                                                                                                multiplier:1.0 constant:0]];
    
    
    
    [_placesSearchBar setImage:[UIImage imageNamed:@"currentLocation"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Reloads with updated search result data / hides and unhides text field based on result availability
-(void) reloadPage {

    _placesSearchBar.text = @"";
    
    if(_myPlaces == nil || [_myPlaces count] == 0){
        self.placeHoldertext.hidden = FALSE;
        self.placeTable.hidden = TRUE;
       
    }  else {
        self.placeHoldertext.hidden = TRUE;
        self.placeTable.hidden = FALSE;
        [self.placeTable reloadData];
    }
}


#pragma mark - Tableview Places search result

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //Default height constant for cell
    return 80;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //Search result places count
    return _myPlaces.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // cached tableview cell with content setter for all the rows
    PlaceDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItineraryPlaceCell"];
    
    [cell setCellcontent:[_myPlaces objectAtIndex:indexPath.row] isAddPlace:TRUE];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // on cell selection  access the top navigation from itineray creation stack and passback the data to save and finally pop out
    AddEditVC *addEditVC = (AddEditVC*)[[self.navigationController viewControllers] objectAtIndex:0];
    
    if([addEditVC isKindOfClass:[AddEditVC class]]) {
        [addEditVC handleSelectedPlace:[_myPlaces objectAtIndex:indexPath.row]];
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        NSLog(@"Error : Issue with navigation stack");
        
    }
    
    
}

#pragma mark - searchbar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // Add activity indicator and dismiss keybord
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [MRProgressOverlayView showOverlayAddedTo:appDelegate.window animated:YES];
    [searchBar resignFirstResponder];
    
    //request for search with string in search bar
    [[HEREPlacesDataProvider sharedInstance] searchForPlaceWithString:searchBar.text];
    [HEREPlacesDataProvider sharedInstance].delegate = self;
    
}

// handle current location search
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    
    [self searchBarSearchButtonClicked:searchBar];
}

#pragma mark - Here places search API delegate

// handle success search
-(void) successWithPlaces:(NSMutableArray*) placesList {
    
    _myPlaces = placesList;
    [self reloadPage];
    // Remove activity indicator
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [MRProgressOverlayView dismissOverlayForView:appDelegate.window animated:YES];
    
    if(_myPlaces.count < 1)
        [self presentAlertWithMessage:@"No places found"];
  
}

// handle failure search
-(void) didSearchFailWithError:(NSString *) errorMessage{

    [_myPlaces removeAllObjects];
    [self reloadPage];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [MRProgressOverlayView dismissOverlayForView:appDelegate.window animated:YES];
    
    [self presentAlertWithMessage:errorMessage];
    
}



@end
