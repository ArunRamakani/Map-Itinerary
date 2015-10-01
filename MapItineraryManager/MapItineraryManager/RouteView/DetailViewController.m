//
//  DetailViewController.m
//  MapItineraryManager
//
//  Created by Arun Ramakani on 18-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//

#import "DetailViewController.h"
#import "RouteSettingVC.h"
#import "HERERoutesDataProvider.h"
#import "RouteInfo.h"
#import "Place.h"
#import "RouteMapUtil.h"
#import "RouteLegLine.h"
#import "RouteLegBreakPointView.h"
#import "AddEditVC.h"
#import "RouteInformationView.h"


@interface DetailViewController ()

// Instance variable that holds  data to render map with appropriate leg and way points. Also helping summary and instruction view render
@property (nonatomic, strong) NSArray                               *places;
@property (nonatomic, strong) RouteInfo                             *routeInfo;
@property (nonatomic, assign) MKCoordinateRegion                    mapRegion;
@property (nonatomic, strong) NSMutableArray<MKPointAnnotation*>    *annotations;
@property (nonatomic, strong) NSMutableArray<RouteLegLine*>         *polyLine;

// Helper variable to conform refreshing of map in view did appeare only after view did load is called
@property (nonatomic, assign) BOOL                                  viewAppeareMapViewRefresh;

@end

@implementation DetailViewController

#pragma mark - Set Itinerary Data


// Method used to pass details of the selected itinerary into details view. This method receives the data as a core data object and populate instance variable with the data necessary for displaying the detaiils view
- (void)setDetailItem:(id)newDetailItem {
        _detailItem = newDetailItem;
    
    if(_detailItem) {
        
        //populate route and placess details into instance variable
        NSManagedObject *objectDb = (NSManagedObject*)_detailItem;
        self.places = [objectDb valueForKey:@"placesArray"];
        self.routeInfo = [objectDb valueForKey:@"routeInfo"];
        
        //sets trip name as details page title
        self.title = [objectDb valueForKey:@"itineraryName"];
        [self configureMap];
    }
    
}


#pragma mark - Prepare and draw Map

// construct map specific details before we refresh the map view for user. Following details are constructed withe the help of RouteMapUtil utility class
// 1. Map Bounds - Visible area as a region based on the route details we have
// 2. Create Map annotations for all waypoints
// 3. Create leg lines in the form of polyline overlays
- (void)configureMap {
    
    self.mapRegion   = [RouteMapUtil getBoundingBoxRegionForPlace:self.places route:self.routeInfo];
    self.annotations = [RouteMapUtil getAnnotationsForPlace:self.places wayPoints:self.routeInfo.wayPoints];
    self.polyLine    = [RouteMapUtil getPolylineFromRoute:self.routeInfo];
    
    // Refresh map once details are calculated
    [self refreshMap];
}

// Refresh the map once me get the updated tatails on manual route refresh  or details page load first time
-(void) refreshMap {
   
    // Remove old Overlays/Annotations and add the updated once
    [self.mapView removeAnnotations:[self.mapView annotations]];
    [self.mapView removeOverlays:[self.mapView overlays]];
    
    [self.mapView addAnnotations:self.annotations];
    [self.mapView addOverlays:self.polyLine];
    
    // Set Map visible area
    [self.mapView setRegion:self.mapRegion animated:TRUE];
    
    // Reload instruction table view as we have got a new set of data for given itinerary
    [self.routeInstructions reloadData];
}

// reste the map with current location visible are when ther is no itinerary available to display
-(void) resetMap {
    
    // Reset all data to nill for no itinary  state
    self.title = @"No Itinerary";
    self.detailItem = nil;
    self.annotations = nil;
    self.row = -1;
    self.places = nil;
    self.routeInfo = nil;
    
    // get current location view bounds
    self.mapRegion = [RouteMapUtil getBoundingBoxRegionForPlace:self.places route:self.routeInfo];
    
    //refresh map
    [self refreshMap];
    
}


#pragma mark - View life cycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // set map view as the default tab bay selected display
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:0]];
    self.viewAppeareMapViewRefresh = TRUE;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshButtonClicked:)
                                                 name:@"SettingClosed"
                                               object:nil];
    
}

-(void) viewDidAppear:(BOOL)animated {
   
    if(self.viewAppeareMapViewRefresh) {
        self.viewAppeareMapViewRefresh = FALSE;
        // refresh the map to make sure the view is rendered with right details and bounds when the view did appeare
        if(self.annotations == nil) {
            [self resetMap];
        } else  {
            [self refreshMap];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    // reset the map with empty dtata in case of memory warning
    [self resetMap];
}
-(void) dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

#pragma mark -  Navigation bar button click events

-(IBAction)refreshButtonClicked:(id)sender {
    
    NSInteger rowCount = [self.delegateMaster.tableView numberOfRowsInSection:0];
    
    if(_detailItem != nil && rowCount != 0) {
        // Refresh route for the current itinerary
        [self.delegateMaster refreshRouteForRow:self.row];
    } else {
        // Reset the map with current location if thre are no itinerary
        [self resetMap];
    }
    
}


-(IBAction)settingButtonClicked:(id)sender {
    
    // create and present settings view as model. Presented to modify route search configurations
    UIBarButtonItem *ancorPoint = (UIBarButtonItem*)sender;
    RouteSettingVC *settingVC   = [[RouteSettingVC alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingVC];
    
    navigationController.modalInPopover             = TRUE;
    navigationController.preferredContentSize       = CGSizeMake(375.0,640.0);
    navigationController.modalPresentationStyle     = UIModalPresentationPopover;
    UIPopoverPresentationController *popover        = navigationController.popoverPresentationController;
    
    popover.barButtonItem                           = ancorPoint;
    
    [self presentViewController:navigationController animated:TRUE completion:^{
        
    }];
    
}

#pragma mark - Map view delegates 

// view for overLay - set color from the polyline
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    MKPolylineRenderer *lineView = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    
    RouteLegLine *routeOverlay = (RouteLegLine*)overlay;
    
    lineView.strokeColor = routeOverlay.legColor;
    return lineView;
}

// Handle annotation Callout taps
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    UINavigationController *navigationController;
    
    // Edit itinerary tap
    if(control.tag == 1000) {
        
        AddEditVC *itineraryAddEditModel = [[AddEditVC alloc] init];
        
        NSIndexPath* path = [NSIndexPath indexPathForRow:self.row inSection:0];
        itineraryAddEditModel.placesForRoute = [NSMutableArray arrayWithArray:self.places];
        itineraryAddEditModel.editIndex = path;
        
        navigationController = [[UINavigationController alloc] initWithRootViewController:itineraryAddEditModel];
        
    }
    // Info button tap to show Route Summary View
    else if(control.tag == 1001) {
        RouteInformationView *infoVC = [[RouteInformationView alloc] init];
        infoVC.summary = self.routeInfo.summary;
        navigationController = [[UINavigationController alloc] initWithRootViewController:infoVC];
    }
    
    [self presentViewController:navigationController animated:TRUE completion:^{
        
    }];
    
}

//provide view of annotation
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    // create a annotation for all way points in the route && configure callout view
    RouteLegBreakPointView *legBreakPoint = (RouteLegBreakPointView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"LegBreakPoint"];
    // Use cache annotations with tag "LegBreakPoint"
    if (!legBreakPoint){
        legBreakPoint = [[RouteLegBreakPointView alloc] initWithAnnotation:annotation reuseIdentifier:@"LegBreakPoint"];
        [legBreakPoint configurePinView];
    }
    legBreakPoint.annotation = annotation;
    
    return legBreakPoint;

}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item

{
    long selectedTag=tabBar.selectedItem.tag;
    
    //  controll visibility of map view and route instruction view based on tab bar button tap
    if (selectedTag==1)
    {
        self.routeInstructions.hidden = TRUE;
        self.mapView.hidden = FALSE;
    }
    else if(selectedTag==2)
    {
        self.routeInstructions.hidden = FALSE;
        self.mapView.hidden = TRUE;
    }
    
}

#pragma mark - UITableViewDataSource - instruction table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Instruction count in each step
    return self.routeInfo.legArray[section].stepsArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Each leg is a Table section
    return self.routeInfo.legArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InstructionCell"];
    
    // Use cache annotations with tag "InstructionCell"
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InstructionCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.textColor = [UIColor lightGrayColor];
        
    }
    // extract Leg information based on the table section
    RouteLeg *leg = self.routeInfo.legArray[indexPath.section];
    
    // extract step information based on the table row
    StepInLeg *step = leg.stepsArray[indexPath.row];
    NSString *rowText = step.instruction;
    cell.textLabel.text = rowText;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    return cell;
}



#pragma mark - UITableViewDelegate - instruction table

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;//height of section;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // create view for header with distance and travel time and neg number
    UILabel *lblSectionName = [[UILabel alloc] init];
    lblSectionName.text = [NSString stringWithFormat:@"  Leg %ld, Distance : %lu KM, Travel Time : %lu Minutes", section + 1, self.routeInfo.legArray[section].length/ 1000 , self.routeInfo.legArray[section].travelTime/ 60];
    lblSectionName.textColor = [UIColor whiteColor];
    lblSectionName.lineBreakMode = NSLineBreakByWordWrapping;
    lblSectionName.backgroundColor = [UIColor grayColor];
    
    lblSectionName.lineBreakMode = NSLineBreakByWordWrapping;
    
    return lblSectionName;
}


@end
