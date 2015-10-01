//
//  AppDelegate.h
//  MapItineraryManager
//
//  Created by Arun Ramakani on 18-9-15.
//  Copyright © 2015 Arun Ramakani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CurrentLocationProvider.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
// Managed object context and supporting clases
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//  instance to Current location provider
@property (readonly, strong, nonatomic) CurrentLocationProvider *locationProvider;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

