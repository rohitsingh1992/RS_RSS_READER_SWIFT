//
//  Feeds+CoreDataProperties.h
//  RSS Reader
//
//  Created by Rohit Singh on 17/07/16.
//  Copyright © 2016 sra. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Feeds.h"

NS_ASSUME_NONNULL_BEGIN

@interface Feeds (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *desc;
@property (nullable, nonatomic, retain) NSString *title;

@end

NS_ASSUME_NONNULL_END
