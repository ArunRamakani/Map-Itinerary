//
//  MasterViewController.m
//  MapItineraryManager
//
//  Created by Arun Ramakani on 18-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//

#import "MasterViewController.h"
#import "UIViewController+ViewControllerUtil.h"
#import "DetailViewController.h"
#import "AddEditVC.h"
#import "ItineraryTableCell.h"
#import "MRProgress.h"
#import "AppDelegate.h"


@interface MasterViewController ()

@property (nonatomic, strong) UILabel *noTripInfoInfo;

@end

@implementation MasterViewController


#pragma mark - View life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Set Navigation bar button item to add new itinerary
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEditItinerary:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    // If there is at least one Itinerary , directly go to Itinerary details page to display route
    
    NSFetchedResultsController *fetchObjects = [self fetchedResultsController];
    id <NSFetchedResultsSectionInfo> sectionInfo = [fetchObjects sections][0];
    
    if([sectionInfo numberOfObjects] > 0) {
        
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionBottom];
        [self refreshDetailsViewForIndex:indexPath withObject:[fetchObjects objectAtIndexPath:indexPath]];
        
    } else {
        
        // First time when there is no itineray show popup to info user on how to add itinerary
        _noTripInfoInfo = [[UILabel alloc] initWithFrame:self.view.bounds];
        _noTripInfoInfo.text = @"Use add icon in navigation bar to create itinerary";
        _noTripInfoInfo.textColor = [UIColor grayColor];
        _noTripInfoInfo.numberOfLines = 2;
        _noTripInfoInfo.textAlignment =  NSTextAlignmentCenter;
        _noTripInfoInfo.lineBreakMode = NSLineBreakByWordWrapping;
        [self.view addSubview:_noTripInfoInfo];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    // persist table view selection for split view mode in based on the colopsed state, used in iPad and iPhone 6+
    //Shouls be be done before "[super viewWillAppear:animated]" because , Tableviewcontroller will finalize the details during "[super viewWillAppear:animated]"
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Manage Add and edit Itinerary

// Add / Edit itinerary tap
- (void)addEditItinerary:(id)sender {
    
    // Present addedit itinerary view
    AddEditVC *itineraryAddEditModel = [[AddEditVC alloc] init];
    
    // the current method is called with a index then its for edit itinerary. Set the appropriate places array for edit
    if([sender isMemberOfClass:[NSIndexPath class]]) {
        
        NSIndexPath* path = (NSIndexPath*)sender;
        NSManagedObject *tapRowItem = [self.fetchedResultsController objectAtIndexPath:path];
        itineraryAddEditModel.placesForRoute = [NSMutableArray arrayWithArray:[tapRowItem valueForKey:@"placesArray"]];
        itineraryAddEditModel.editIndex = path;
        
    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:itineraryAddEditModel];
    
    [self presentViewController:navigationController animated:TRUE completion:nil];
    
}


// Save itinerary places and initiate route request
-(void) handleSaveItinerary :(NSArray*) itinerary itineraryName:(NSString*) itineraryName exitIndex:(NSIndexPath*) editPath{
    
    // Create in core data row or update esisting itinerary based on the calling context
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSManagedObject *objectToUpdate ;
    if(editPath != nil) {
        objectToUpdate = [self.fetchedResultsController objectAtIndexPath:editPath];
    } else {
        NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
        objectToUpdate = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        [objectToUpdate setValue:[NSDate date] forKey:@"timeStamp"];
            
    }
    
    [objectToUpdate setValue:itinerary forKey:@"placesArray"];
    [objectToUpdate setValue:itineraryName forKey:@"itineraryName"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Not able to save the itinerary because of :  %@, %@", error, [error userInfo]);
    }

    [_noTripInfoInfo removeFromSuperview];
    // Fetch route for the created/Updated itinerary
    [self refreshRouteForRow:editPath.row];
    
}

// Refresh route info for the given row
- (void) refreshRouteForRow:(long) row {
    
    // Add progress indicator blocking all the window
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [MRProgressOverlayView showOverlayAddedTo:appDelegate.window animated:YES];
    
    // construct places array for th given row and pass it on to routes data provider to generate route request
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    // fetch route from data provider
    [HERERoutesDataProvider sharedInstance].delegate = self;
    [[HERERoutesDataProvider sharedInstance] getRouteFromPlaces:[object valueForKey:@"placesArray"] forIndex:indexPath];
    
}

// Edit itinerary based on the button index
-(void) editItineraryForRow:(id) sender {
    
    UIButton *tapButton = (UIButton*) sender;
    [self addEditItinerary:[NSIndexPath indexPathForRow:tapButton.tag inSection:0]];
}


//  Refresh the details view with updated route information
-(void) refreshDetailsViewForIndex:(NSIndexPath *) forIndex withObject:(NSManagedObject*) objectToUpdate{
    
    self.detailViewController.delegateMaster = self;
    self.detailViewController.row = forIndex.row;
    [self.detailViewController setDetailItem:objectToUpdate];
    self.detailViewController.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.detailViewController.navigationItem.leftItemsSupplementBackButton = YES;
    
}

#pragma mark - Segues
//  handle itineray table row tap to show details route view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showRoute"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        self.detailViewController = (DetailViewController *)[[segue destinationViewController] topViewController];
        [self refreshDetailsViewForIndex:indexPath withObject:object];
    }
}

#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Default height based on the designed cell view
    return 100;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of availabele itinerary
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Custom cell with itinery edit button configured
    ItineraryTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItineraryCell" forIndexPath:indexPath];
    [cell.editItinerary addTarget:self action:@selector(editItineraryForRow:) forControlEvents:UIControlEventTouchUpInside];
    cell.editItinerary.tag = indexPath.row;
    [cell setCellcontent:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    return cell;
}


// Provide delete action for itinerary
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // when selected index is deleted fall back to first index if first itinerary is available.
        if(indexPath.row  == self.detailViewController.row){
            
            NSFetchedResultsController *fetchObjects = [self fetchedResultsController];
            id <NSFetchedResultsSectionInfo> sectionInfo = [fetchObjects sections][0];
            
            if([sectionInfo numberOfObjects] > 1) {
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionBottom];
                [self refreshDetailsViewForIndex:indexPath withObject:[fetchObjects objectAtIndexPath:indexPath]];
            }
        } 
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             NSLog(@"Not able to save the itinerary because of :  %@, %@", error, [error userInfo]);
        }
        
        
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Create entity for MyTravelitinerary table.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MyTravelitinerary" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // order the itinerary based on the created time stamp.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"RouteItinerary"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Not able to fetch the itinerary because of :  %@, %@", error, [error userInfo]);
    }
    
    return _fetchedResultsController;
}

// When threre is a edit/delete/Add update the table view
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

//handle Table view Edit/  delete/ Add with animation
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

//handle Table view Edit/  delete/ Add with animation
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:{
            ItineraryTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell setCellcontent:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            break;
        }
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

//once edit of table view is doen end it and reload table to update tags in edit button of all cells
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    
    [self.tableView reloadData];
}


#pragma mark - HERERouteDataProviderDelegate


// delegate method called by route data provider to update core data and refresh details view
-(void) successWithRoute:(RouteInfo*) routeInfo forIndex:(NSIndexPath *) forIndex {
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSManagedObject *objectToUpdate = [self.fetchedResultsController objectAtIndexPath:forIndex];
    
    // support persistance of old route when new route is not available
    if(routeInfo) {
        [objectToUpdate setValue:routeInfo forKey:@"routeInfo"];
    }
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
         NSLog(@"Not able to save route :  %@, %@", error, [error userInfo]);
    }
    
    [self.tableView selectRowAtIndexPath:forIndex animated:YES  scrollPosition:UITableViewScrollPositionBottom];
    
    // remove activity indicator
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [MRProgressOverlayView dismissOverlayForView:appDelegate.window animated:YES];


    // refresh details view with updated index
    [self refreshDetailsViewForIndex:forIndex withObject:objectToUpdate];
    
}

// present rout fetch failure message and refresh details page with just place annotations
-(void) didSearchFailWithError:(NSString *) errorString forIndex:(NSIndexPath*) forIndex{
    
    [self presentAlertWithMessage:errorString];
    [self successWithRoute:nil forIndex:forIndex];
    
}





@end
