//
//  AppDelegate.m
//  GimVic
//
//  Created by Vid Drobnič on 09/13/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDAppDelegate.h"
#import "VDDRootViewController.h"
#import "VDDSuplenceDataFetch.h"
#import "VDDMetaData.h"
#import "VDDJedilnikDataFetch.h"
#import "VDDUrnikDataFetch.h"
#import "VDDHybridDataFetch.h"
#import "VDDIntroViewController.h"

@interface VDDAppDelegate ()

@end


@implementation VDDAppDelegate

#pragma mark - Delegate Functions

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? paths[0] : nil;
    
    NSString *metaDataPath = [NSString stringWithFormat:@"%@/metaData", documentsPath];
    NSData *metaDataData = [NSData dataWithContentsOfFile:metaDataPath];
    
    if (metaDataData == nil) {
        NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:nil];
        if (directoryContent.count > 0) {
            for (int i = 0; i < directoryContent.count; i++)
                [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", documentsPath, directoryContent[i]] error:nil];
        }
        
        NSDictionary *data = @{@"filter": @"",
                               @"podFilter": @[],
                               @"numberOfChangesLeft": @3,
                               @"uciteljskiNacin": @NO,
                               @"lastUpdatedSuplence": [NSNull null],
                               @"lastUpdatedUrnik": [NSNull null],
                               @"showedView": @(VDDSetupView),
                               @"lastUpdatedJedilnik": [NSNull null],
                               @"malicaFromDate": [NSNull null],
                               @"malicaToDate": [NSNull null],
                               @"kosiloFromDate": [NSNull null],
                               @"kosiloToDate": [NSNull null],
                               @"malicaFileName": [NSNull null],
                               @"kosiloFileName": [NSNull null],
                               @"lastUpdatedUrnik": [NSNull null],
                               @"lastUpdatedHybrid": [NSNull null],
                               @"lastOpened": [NSNull null],
                               @"lastAddedChanges": [NSDate date]
                               };
        
        metaDataData = [NSKeyedArchiver archivedDataWithRootObject:data];
        [metaDataData writeToFile:metaDataPath atomically:YES];
    }
    
    [self addChanges];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.window.rootViewController = [VDDRootViewController sharedRootViewController];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self checkDate];
    
    [NSThread detachNewThreadSelector:@selector(updateData) toTarget:self withObject:nil];
}

#pragma mark - Update Data Functions

- (void)updateData {
    NSString *filter = (NSString *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"filter"];
    NSArray *podfilter = (NSArray *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"podFilter"];
    if ([filter isEqualToString:@""] && [podfilter isEqualToArray:@[]]) {
        [[VDDUrnikDataFetch sharedUrnikDataFetch] refresh];
        [[VDDSuplenceDataFetch sharedSuplenceDataFetch] refresh];
        [[VDDHybridDataFetch sharedHybridDataFetch] refresh];
        [[VDDJedilnikDataFetch sharedJedilnikDataFetch] downloadJedilnik];
        return;
    }
    
    [self updateUrnikData];
    [self updateSuplenceData];
    [self updateHybrid];
    [self updateJedilnikData];
}

- (void)checkDate {
    if ([[VDDMetaData sharedMetaData] metaDataObjectForKey:@"lastOpened"] == [NSNull null]) {
        [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"lastOpened" toObject:[NSDate date]];
        return;
    }
    
    NSDate *lastOpened = (NSDate *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"lastOpened"];
    long startDay = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] ordinalityOfUnit:NSCalendarUnitDay
                                                                                                 inUnit:NSCalendarUnitEra
                                                                                                forDate:lastOpened];
    
    long endDay = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] ordinalityOfUnit:NSCalendarUnitDay
                                                                                               inUnit:NSCalendarUnitEra
                                                                                              forDate:[NSDate date]];
    long numberOfDays = endDay - startDay;
    if (numberOfDays > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VDDDatesChanged" object:nil];
        [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"lastOpened" toObject:[NSDate date]];
    }
}

- (void)updateHybrid {
    if ([[VDDMetaData sharedMetaData] metaDataObjectForKey:@"lastUpdatedHybrid"] == [NSNull null]) {
        if ([VDDHybridDataFetch sharedHybridDataFetch].isRefreshing == NO)
            [[VDDHybridDataFetch sharedHybridDataFetch] refresh];
        return;
    }
    
    NSDate *suplenceDate = (NSDate *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"lastUpdatedSuplence"];
    NSDate *urnikDate = (NSDate *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"lastUpdatedUrnik"];
    NSDate *hybridDate = (NSDate *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"lastUpdatedHybrid"];
    
    if ([suplenceDate timeIntervalSinceDate:hybridDate] > 0 || [urnikDate timeIntervalSinceDate:hybridDate] > 0) {
        if ([VDDHybridDataFetch sharedHybridDataFetch].isRefreshing == NO)
            [[VDDHybridDataFetch sharedHybridDataFetch] refresh];
    }
}

- (void)updateUrnikData {
    if ([[VDDMetaData sharedMetaData] metaDataObjectForKey:@"lastUpdatedUrnik"] == [NSNull null]) {
        if ([VDDUrnikDataFetch sharedUrnikDataFetch].isRefreshing == NO)
            [[VDDUrnikDataFetch sharedUrnikDataFetch] refresh];
        return;
    }
    
    NSDate *urnikUpdate = (NSDate *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"lastUpdatedUrnik"];
    long startDay = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] ordinalityOfUnit:NSCalendarUnitDay
                                                                                                 inUnit:NSCalendarUnitEra
                                                                                                forDate:urnikUpdate];
    
    long endDay = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] ordinalityOfUnit:NSCalendarUnitDay
                                                                                               inUnit:NSCalendarUnitEra
                                                                                              forDate:[NSDate date]];
    
    long numberOfDays = endDay - startDay;
    
    if (numberOfDays <= 0)
        return;
    
    if ([VDDUrnikDataFetch sharedUrnikDataFetch].isRefreshing == NO)
        [[VDDUrnikDataFetch sharedUrnikDataFetch] refresh];
}

- (void)updateJedilnikData {
    if ([[VDDMetaData sharedMetaData] metaDataObjectForKey:@"lastUpdatedJedilnik"] == [NSNull null]) {
        if ([VDDJedilnikDataFetch sharedJedilnikDataFetch].isRefreshing == NO)
            [[VDDJedilnikDataFetch sharedJedilnikDataFetch] downloadJedilnik];
        return;
    }
    
    NSDate *jedilnikUpdate = (NSDate *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"lastUpdatedJedilnik"];
    long startDay = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] ordinalityOfUnit:NSCalendarUnitDay
                                                                                                 inUnit:NSCalendarUnitEra
                                                                                                forDate:jedilnikUpdate];
    
    long endDay = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] ordinalityOfUnit:NSCalendarUnitDay
                                                                                               inUnit:NSCalendarUnitEra
                                                                                              forDate:[NSDate date]];
    long numberOfDays = endDay - startDay;
    
    if (numberOfDays <= 0)
        return;
    
    if ([VDDJedilnikDataFetch sharedJedilnikDataFetch].isRefreshing == NO)
        [[VDDJedilnikDataFetch sharedJedilnikDataFetch] downloadJedilnik];
}

- (void)updateSuplenceData {
    if ([[VDDMetaData sharedMetaData] metaDataObjectForKey:@"m"] == [NSNull null]) {
        if ([VDDSuplenceDataFetch sharedSuplenceDataFetch].isRefreshing == NO)
            [[VDDSuplenceDataFetch sharedSuplenceDataFetch] refresh];
        return;
    }
    
    if ([[NSDate date] timeIntervalSinceDate:(NSDate *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"lastUpdatedSuplence"]] < 5*60)
        return;
    
    if ([VDDSuplenceDataFetch sharedSuplenceDataFetch].isRefreshing == NO)
        [[VDDSuplenceDataFetch sharedSuplenceDataFetch] refresh];
}

- (void)addChanges {
    NSDate *today = [NSDate date];
    long year = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] component:NSCalendarUnitYear fromDate:today];
    long month = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] component:NSCalendarUnitMonth fromDate:today];
    long day = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] component:NSCalendarUnitDay fromDate:today];
    
    NSDateComponents *todayComps = [[NSDateComponents alloc] init];
    [todayComps setYear: year];
    [todayComps setMonth:month];
    [todayComps setDay:day];
    [todayComps setHour:1];
    [todayComps setMinute:0];
    [todayComps setSecond:0];
    today = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] dateFromComponents:todayComps];
    
    NSDate *lastAddedChanges = (NSDate *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"lastAddedChanges"];
    
    NSDateComponents *lastAddedChangesComponents = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] components:NSCalendarUnitYear fromDate:lastAddedChanges];
    int lastAddedYear = (int)lastAddedChangesComponents.year;
    
    NSDateComponents *firstSeptemberComponents = [[NSDateComponents alloc] init];
    [firstSeptemberComponents setYear:lastAddedYear];
    [firstSeptemberComponents setMonth:9];
    [firstSeptemberComponents setDay:2];
    [firstSeptemberComponents setHour:1];
    [firstSeptemberComponents setMinute:0];
    [firstSeptemberComponents setSecond:0];
    
    NSDate *firstSeptember = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] dateFromComponents:firstSeptemberComponents];
    
    if ([lastAddedChanges timeIntervalSinceDate:firstSeptember] >= 0) {
        [firstSeptemberComponents setYear:lastAddedYear + 1];
        [firstSeptemberComponents setHour:1];
        [firstSeptemberComponents setMinute:0];
        [firstSeptemberComponents setSecond:0];
        
        firstSeptember = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] dateFromComponents:firstSeptemberComponents];
        
        if ([today timeIntervalSinceDate:firstSeptember] >= 0) {
            [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"lastAddedChanges" toObject:[NSDate date]];
            [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"numberOfChangesLeft" toObject:@3];
            return;
        }
    } else {
        if ([today timeIntervalSinceDate:firstSeptember] >= 0) {
            [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"lastAddedChanges" toObject:[NSDate date]];
            [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"numberOfChangesLeft" toObject:@3];
            return;
        }
    }
}

@end
