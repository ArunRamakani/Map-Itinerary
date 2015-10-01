//
//  RouteSettingVC.m
//  MapItineraryManager
//
//  Created by Arun Ramakani on 24-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//

#import "RouteSettingVC.h"
#import "HERERoutesDataProvider.h"

@interface RouteSettingVC ()

// Instances that hold the configuration data
@property (nonatomic, strong) NSDictionary *settingDict;
@property (nonatomic, strong) NSMutableArray *sectionArray;


// instance variables to hold the selected configs
@property (nonatomic, strong) NSArray   *sectionTitleArr;
@property (nonatomic, strong) NSString  *selectedTrafficMode;
@property (nonatomic, strong) NSString  *selectedTransportMode;
@property (nonatomic, strong) NSString  *selectedRouteMode;
@property (nonatomic, strong) NSString  *selectedWaypointType;


@end

@implementation RouteSettingVC


#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

    // Add save and close button to the navigation bar to save and close the settings menu
    UIBarButtonItem* saveButton     = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveSettings:)];
    UIBarButtonItem* closeButton    = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeSettings:)];
    
    self.navigationController.topViewController.navigationItem.rightBarButtonItem  = saveButton;
    self.navigationController.topViewController.navigationItem.leftBarButtonItem   = closeButton;
    
    // Populate instance data variables for configuration settings from static plist file
    _settingDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SettingPlist" ofType:@"plist"]];

    _sectionTitleArr    = [_settingDict allKeys];
    _sectionArray       = [[NSMutableArray alloc] init];
    
    for (NSString *sectionTitle in _sectionTitleArr){
        [_sectionArray addObject:[_settingDict valueForKey:sectionTitle]];
    }
    
    // Get the user prefered options to populate default selected values from the singulton  setting model
    self.selectedTrafficMode    = [[HERERoutesDataProvider sharedInstance] routeSearchSettings].trafficMode;
    self.selectedTransportMode  = [[HERERoutesDataProvider sharedInstance] routeSearchSettings].transportMode;
    self.selectedRouteMode      = [[HERERoutesDataProvider sharedInstance] routeSearchSettings].routeMode;
    self.selectedWaypointType   = [[HERERoutesDataProvider sharedInstance] routeSearchSettings].waypointType;
    
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -  Navigation bar button click events

// method to save the selected roure config
-(void)saveSettings:(id)sender {
    
    // Save user selected data into NSUser default
    [[NSUserDefaults standardUserDefaults] setObject:self.selectedTrafficMode forKey:TrafficModeSetting];
    [[NSUserDefaults standardUserDefaults] setObject:self.selectedTransportMode forKey:TransportModeSetting];
    [[NSUserDefaults standardUserDefaults] setObject:self.selectedRouteMode forKey:RouteModeSetting];
    [[NSUserDefaults standardUserDefaults] setObject:self.selectedWaypointType forKey:WaypointSetting];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Update route data provider to sonstruct next route request with updated config
    [[[HERERoutesDataProvider sharedInstance] routeSearchSettings] updateSettigs];
    
    [self dismissViewControllerAnimated:TRUE completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SettingClosed" object:self];
    }];
     
    
}

// close setting view with out any change
-(void)closeSettings:(id)sender {
    
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

#pragma mark - UITableViewDataSource - settings table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // number of rows under each parent configuration in plist
    return [[_sectionArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell"];
    // Using cached table view call with ID "SettingsCell"
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SettingsCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.textColor = [UIColor darkGrayColor];
            
    }
    // set text for row from setting plist configs
    NSArray *sectionListArr = [_sectionArray objectAtIndex:indexPath.section];
    NSString *rowText = (NSString*)[sectionListArr objectAtIndex:indexPath.row];
    cell.textLabel.text = rowText;
    
    // set accessor view for selected/default configurations rows
    if([rowText isEqualToString:self.selectedTrafficMode] || [rowText isEqualToString:self.selectedTransportMode] || [rowText isEqualToString:self.selectedRouteMode] || [rowText isEqualToString:self.selectedWaypointType]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Number of sections from parent config .
    return _sectionTitleArr.count;
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Parent config titles
    return [_sectionTitleArr objectAtIndex:section];
}


#pragma mark - UITabBarDelegate - settings table

// on select of table view cell update the select confice variables and update check mark configs
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row     = indexPath.row;
    NSString *sectionTitle = [self.sectionTitleArr objectAtIndex:section];
    NSArray *selectedsectionArr = [self.sectionArray objectAtIndex:section];
    NSString *selectedRow = [selectedsectionArr objectAtIndex:row];
    
    if([sectionTitle isEqualToString:TrafficModeSetting]) {
        self.selectedTrafficMode = selectedRow;
    } else if([sectionTitle isEqualToString:TransportModeSetting]) {
        self.selectedTransportMode = selectedRow;
    } else if([sectionTitle isEqualToString:RouteModeSetting]) {
        self.selectedRouteMode = selectedRow;
    } else if([sectionTitle isEqualToString:WaypointSetting]) {
        self.selectedWaypointType = selectedRow;
    }
    
    [tableView reloadData];
}

@end
