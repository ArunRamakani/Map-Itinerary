//
//  AddEditVC.m
//  MapItineraryManager
//
//  Created by Arun Ramakani on 18-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.


#import "AddEditVC.h"
#import "PlaceDisplayCell.h"
#import "AddPlace.h"
#import "UIView+AnimationUtility.h"
#import "UIViewController+ViewControllerUtil.h"
#import "MasterViewController.h"
#import "HERERoutesDataProvider.h"

@interface AddEditVC ()

@property (nonatomic, strong) UIBarButtonItem *btnSave;

@end

@implementation AddEditVC


// Gets the name of the trip in a alert with text field when we done with Itinerary creation by clicking save button
-(void) getTripName {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:@"Enter the itinerary name"
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         // Provide a default trip name
         textField.placeholder = @"Itinerary Name";
         if(_placesForRoute.count > 1)
             textField.text = [NSString stringWithFormat:@"%@ Trip", ((Place*)_placesForRoute[_placesForRoute.count -1]).title];
         
     }];
    
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *itineraryName = alertController.textFields.firstObject;
                                   // Call save itinerary once trip name provided
                                   [self saveItinerary:itineraryName.text];
                               }];
    
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:TRUE completion:nil];
    
}


// save the Itinerary with places and trip name
-(void) saveItinerary:(NSString*) itineraryName {
    
    id presentedVC = (UISplitViewController*) self.presentingViewController;
    
    UINavigationController *masterNavigationController;
    
    if ([presentedVC isKindOfClass:[UISplitViewController class]]){
        masterNavigationController = ((UISplitViewController*)presentedVC).viewControllers[0];
    } else {
        masterNavigationController = (UINavigationController*)presentedVC;
    }
    
    
    MasterViewController *itinearryListPage = (MasterViewController *)masterNavigationController.viewControllers[0];
    
    if(_placesForRoute.count > 1 && itineraryName == nil && [itineraryName isEqualToString:@""])
        itineraryName = [NSString stringWithFormat:@"%@ Trip", ((Place*)_placesForRoute[_placesForRoute.count -1]).title];
    
    [itinearryListPage handleSaveItinerary:_placesForRoute itineraryName:itineraryName exitIndex:self.editIndex];
    
    
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

#pragma mark - Refresh view

// Reloads with updated trip data / hides and unhides text field based on result availability
-(void) reloadPage {
    
    if(_placesForRoute == nil || [_placesForRoute count] == 0){
        self.placeHoldertext.hidden = FALSE;
        self.itineraryTable.hidden = TRUE;
        
    }  else {
        self.placeHoldertext.hidden = TRUE;
        self.itineraryTable.hidden = FALSE;
        // Enable save button only when there is a item
        _btnSave.enabled = TRUE;
        [self.itineraryTable reloadData];
    }
}

#pragma mark - Call back Place update

// call back from Add palace page to update rout itinerary at end of array
-(void) handleSelectedPlace:(Place*) place {
    
    if(_placesForRoute == nil ){
        _placesForRoute = [[NSMutableArray alloc] init];
    }
    [_placesForRoute addObject:place];
    [self reloadPage];
}

#pragma mark - navigation button action

-(void) addPlace {
    // open add place mode
    AddPlace *placesVC = [[AddPlace alloc] initWithNibName:@"AddPlace" bundle:nil];
    
    [self.navigationController pushViewController:placesVC animated:YES];
}

-(void) dismiss {
    // close the current model
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Create Itinerary";
    
    // Add navigation button for save, cancel and add
    UIBarButtonItem *buttonCancel   = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    _btnSave        = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(getTripName)];
    
    _btnSave.imageInsets = UIEdgeInsetsMake(-100, 0.0, 0, -50);
    _btnSave.enabled = FALSE;
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: buttonCancel, _btnSave, nil];
    
    UIBarButtonItem* appPlaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPlace)];
    self.navigationController.topViewController.navigationItem.leftBarButtonItem = appPlaceButton;
    
    // Tap gesture to inter-change the cell for changing trips order
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(captuteTapAndDrag:)];
    [_itineraryTable addGestureRecognizer:longPress];
    
    // register table view cell
    [_itineraryTable registerNib:[UINib nibWithNibName:@"PlaceDisplayCell" bundle:nil]  forCellReuseIdentifier:@"ItineraryPlaceCell"];
    
    if (self.editIndex != nil) {
        // Pop up show user that he can drag drop to interchange itinerary places order - only shown once
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        if(![userDefault boolForKey:@"FirstTimeEditMode"]) {
            [userDefault setBool:YES forKey:@"FirstTimeEditMode"];
            [self presentAlertWithMessage:@"Tap and drag places to re-arrange the order"];
        }
        [userDefault synchronize];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Itinerary Tableview

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //Default constant cell hight
    return 80;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // total place count
    return _placesForRoute.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PlaceDisplayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItineraryPlaceCell"];
    [cell setCellcontent:[_placesForRoute objectAtIndex:indexPath.row] isAddPlace:FALSE];
    
    // set appropriate icon for start end and way points of trip
    if(indexPath.row == 0) {
        [cell.placeCategoryImag setImage:[UIImage imageNamed:@"mapStart"]];
    } else if (indexPath.row == ([_placesForRoute count] -1)){
        [cell.placeCategoryImag setImage:[UIImage imageNamed:@"mapend"]];
    } else {
        [cell.placeCategoryImag setImage:[UIImage imageNamed:@"mapconnecting"]];
    }
    
    return cell;
}

// delete place row from table and array data sourse
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_placesForRoute removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self reloadPage];
}


#pragma mark - Animation helper

// drag drop action capture method

-(void) captuteTapAndDrag:(id) sender {
    
    // the position and index of tap
    UITapGestureRecognizer *tapGesture = (UITapGestureRecognizer*) sender;
    UIGestureRecognizerState tapState =  tapGesture.state;
    CGPoint tapPoint = [tapGesture locationInView:_itineraryTable];
    NSIndexPath *tapIndex = [_itineraryTable indexPathForRowAtPoint:tapPoint];
    
    static UIView *snapView;
    static NSIndexPath *tempPath;
    
    // identify tap state and animate accordingly
    switch (tapState) {
        case UIGestureRecognizerStateBegan: {
            // on tap begin add a snap view for drag and hide the actual cell
            // animate the snap cell to the center of tap
            tempPath = tapIndex;
            
            UITableViewCell *tapCell = [_itineraryTable cellForRowAtIndexPath:tapIndex];
            
            snapView = [tapCell createViewSnapShot];
            
            snapView.center = tapCell.center;
            
            [_itineraryTable addSubview:snapView];
            
            [UIView animateWithDuration:0.25 animations:^{
                
                CGPoint center = snapView.center;
                center.y = tapPoint.y;
                snapView.center = center;
                snapView.transform = CGAffineTransformMakeScale(1.04, 1.04);
                
            } completion:^(BOOL finished) {
                tapCell.hidden = TRUE;
            }];
            break;
        }
        case UIGestureRecognizerStateChanged:{
            // when draged move the position of snam cell and hidden cell
            CGPoint center = snapView.center;
            center.y = tapPoint.y;
            snapView.center = center;
            
            if(tapIndex && !([tapIndex isEqual:tempPath])){
                
                [_placesForRoute exchangeObjectAtIndex:tempPath.row withObjectAtIndex:tapIndex.row];
                
                [_itineraryTable moveRowAtIndexPath:tempPath toIndexPath:tapIndex];
                
                tempPath = tapIndex;
                
            }
            
            break;
        }
        default:{
            // end of drag remove snap view and make the cell visible with a animation
            
            UITableViewCell *cell = [_itineraryTable cellForRowAtIndexPath:tempPath];
            
            [UIView animateWithDuration:0.25 animations:^{
                snapView.center = cell.center;
                snapView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                cell.hidden = NO;
                [snapView removeFromSuperview];
                [_itineraryTable reloadData];
                _btnSave.enabled = TRUE;
            }];;
            break;
        }
            
    }
}

@end
