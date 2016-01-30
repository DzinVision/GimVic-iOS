//
//  VDDJedilnikDataFetch.m
//  GimVic
//
//  Created by Vid Drobnič on 10/09/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDJedilnikDataFetch.h"
#import "VDDMetaData.h"
#import "VDDReachability.h"

@implementation VDDJedilnikDataFetch

#pragma mark - Singleton Declaration

+ (instancetype)sharedJedilnikDataFetch {
    static VDDJedilnikDataFetch *sharedJedilnikDataFetch;
    if (!sharedJedilnikDataFetch) {
        sharedJedilnikDataFetch = [[self alloc] initPrivate];
    }
    return sharedJedilnikDataFetch;
}

#pragma mark - Initialization

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Wrong initializer" reason:@"VDDJedilnikDataFetch is a singleton. You should use +sharedJedilnikDataFetch" userInfo:nil];
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _isRefreshing = NO;
    }
    return self;
}

#pragma mark - Refreshing

- (void)downloadJedilnik {
    _isRefreshing = YES;
    
    if (![VDDReachability checkInternetConnection]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VDDJedilnikFetchComplete" object:nil];
        
        _isRefreshing = NO;
        
        if (![NSThread isMainThread])
            [NSThread exit];
        
        return;
    }
    
    
    if (([[VDDMetaData sharedMetaData] metaDataObjectForKey:@"malicaFromDate"] == [NSNull null]) ||
        ([[VDDMetaData sharedMetaData] metaDataObjectForKey:@"malicaToDate"] == [NSNull null]) ||
        ([[VDDMetaData sharedMetaData] metaDataObjectForKey:@"kosiloFromDate"] == [NSNull null]) ||
        ([[VDDMetaData sharedMetaData] metaDataObjectForKey:@"kosiloToDate"] == [NSNull null]) ||
        ([[VDDMetaData sharedMetaData] metaDataObjectForKey:@"malicaFileName"] == [NSNull null]) ||
        ([[VDDMetaData sharedMetaData] metaDataObjectForKey:@"kosiloFileName"] == [NSNull null]))
    {
        [self downloadInfoData];
    }
    
    if ((![self date:[NSDate date]
     isBetweenDate:(NSDate *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"malicaFromDate"]
           andDate:(NSDate *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"malicaToDate"]]) ||
        
        (![self date:[NSDate date]
       isBetweenDate:(NSDate *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"kosiloFromDate"]
             andDate:(NSDate *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"kosiloToDate"]]))
    {
        [self downloadInfoData];
    }
    
    [self downloadMalica];
    [self downloadKosilo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VDDJedilnikFetchComplete" object:nil];

    _isRefreshing = NO;
    
    if (![NSThread isMainThread])
        [NSThread exit];
}

- (void)forceRefresh {
    _isRefreshing = YES;
    
    [self downloadInfoData];
    [self downloadMalica];
    [self downloadKosilo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VDDJedilnikFetchComplete" object:nil];
    _isRefreshing = NO;
}

#pragma mark - Downloading PDF

- (void)downloadMalica {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = (paths.count > 0) ? paths[0] : nil;
    
    
    NSURL *malicaDownload = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.gimvic.org/delovanjesole/solske_sluzbe_in_solski_organi/solska_prehrana/files/%@", (NSString *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"malicaFileName"]]];
    NSData *malicaPdf = [NSData dataWithContentsOfURL:malicaDownload];
    
    [malicaPdf writeToFile:[NSString stringWithFormat:@"%@/malica.pdf", documentsPath] atomically:YES];
}

- (void)downloadKosilo {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = (paths.count > 0) ? paths[0] : nil;
    
    NSURL *kosiloDownload = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.gimvic.org/delovanjesole/solske_sluzbe_in_solski_organi/solska_prehrana/files/%@", (NSString *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"kosiloFileName"]]];
    NSData *kosiloPdf = [NSData dataWithContentsOfURL:kosiloDownload];
    
    [kosiloPdf writeToFile:[NSString stringWithFormat:@"%@/kosilo.pdf", documentsPath] atomically:YES];
}

#pragma mark - Downloading Info Data

- (void)downloadInfoData {
    NSURL *infoUrl = [NSURL URLWithString:@"http://www.gimvic.org/delovanjesole/solske_sluzbe_in_solski_organi/solska_prehrana/jedilnik_data/"];
    NSString *rawInfoData = [NSString stringWithContentsOfURL:infoUrl encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *infoData = [NSJSONSerialization JSONObjectWithData:[rawInfoData dataUsingEncoding:NSUTF8StringEncoding]
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
    
    
    NSDictionary *kosiloInfoData = infoData[@"kosilo"];
    NSDictionary *malicaInfoData = infoData[@"malica"];
    
    if ((![infoData[@"kosilo"] isKindOfClass:[NSDictionary class]]) || (![infoData[@"malica"] isKindOfClass:[NSDictionary class]])) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = (paths.count > 0) ? paths[0] : nil;
        
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/malica.pdf", documentsPath] error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/kosilo.pdf", documentsPath] error:nil];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VDDJedilnikFetchComplete" object:nil];
        
        _isRefreshing = NO;
        
        if (![NSThread isMainThread])
            [NSThread exit];
        return;
    }
    
    
    NSString *kosiloFileName = kosiloInfoData[@"filename"];
    NSString *malicaFileName = malicaInfoData[@"filename"];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    
    NSDate *malicaFromDate = [dateFormatter dateFromString:malicaInfoData[@"fromdate"]];
    NSDate *malicaToDate = [dateFormatter dateFromString:malicaInfoData[@"todate"]];
    
    NSDate *kosiloFromDate = [dateFormatter dateFromString:kosiloInfoData[@"fromdate"]];
    NSDate *kosiloToDate = [dateFormatter dateFromString:kosiloInfoData[@"todate"]];
    
    
    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"malicaFromDate" toObject:malicaFromDate];
    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"malicaToDate" toObject:malicaToDate];
    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"kosiloFromDate" toObject:kosiloFromDate];
    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"kosiloToDate" toObject:kosiloToDate];
    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"malicaFileName" toObject:malicaFileName];
    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"kosiloFileName" toObject:kosiloFileName];
}

#pragma mark - Date Manipulation

- (BOOL)date:(NSDate *)date isBetweenDate:(NSDate *)beginDate andDate:(NSDate *)endDate {
    long beginDay = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] ordinalityOfUnit:NSCalendarUnitDay
                                                            inUnit:NSCalendarUnitEra
                                                           forDate:beginDate];
    
    long endDay = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] ordinalityOfUnit:NSCalendarUnitDay
                                                          inUnit:NSCalendarUnitEra
                                                         forDate:date];
    long numberOfDays = endDay - beginDay;
    if (numberOfDays == 0)
        return YES;
    
    beginDay = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] ordinalityOfUnit:NSCalendarUnitDay
                                                       inUnit:NSCalendarUnitEra
                                                      forDate:date];

    endDay = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] ordinalityOfUnit:NSCalendarUnitDay
                                                       inUnit:NSCalendarUnitEra
                                                      forDate:endDate];
    numberOfDays = endDay - beginDay;
    if (numberOfDays == 0)
        return YES;
    
    
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    return YES;
}

@end