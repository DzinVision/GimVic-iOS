//
//  VDDDataFetch.m
//  GimVic
//
//  Created by Vid Drobnič on 09/13/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDSuplenceDataFetch.h"
#import "VDDMetaData.h"
#import "VDDReachability.h"
#import "VDDHybridDataFetch.h"
#import "VDDCrypto.h"

@interface VDDSuplenceDataFetch ()

@end


@implementation VDDSuplenceDataFetch

#pragma mark - Singleton Declaration

+ (instancetype)sharedSuplenceDataFetch {
    static VDDSuplenceDataFetch *suplenceDataFetch;
    if (!suplenceDataFetch) {
        suplenceDataFetch = [[self alloc] initPrivate];
    }
    return suplenceDataFetch;
}

#pragma mark - Initialization

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        _isRefreshing = NO;
    }
    
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"VDDSuplenceDataFetch is a singleton. You should use +sharedSuplenceDataFetch to access its instance."
                                 userInfo:nil];
}

#pragma mark - Data Creation & Manipulation

- (void)refresh {
    [self downloadNewData];
}

- (void)downloadNewData {
    _isRefreshing = YES;
    
    if (![VDDReachability checkInternetConnection]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VDDDataFetchComplete" object:nil];
        
        _isRefreshing = NO;
        return;
    }
    
    
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    
    int weekday = (int)[calendar component:NSCalendarUnitWeekday fromDate:today];
    if (weekday == 7)
        today = [today dateByAddingTimeInterval:24*3600];
    
    
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:today];
    NSDateComponents *componentsToSubstract = [[NSDateComponents alloc] init];
    [componentsToSubstract setDay:-(components.weekday - calendar.firstWeekday)];
    NSDate *sunday = [calendar dateByAddingComponents:componentsToSubstract toDate:today options:0];
    
    NSString *data0 = [NSString stringWithContentsOfURL:[self generateUrlForDate:[sunday dateByAddingTimeInterval:1 * 24 * 3600]]
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
    NSString *data1 = [NSString stringWithContentsOfURL:[self generateUrlForDate:[sunday dateByAddingTimeInterval:2 * 24 * 3600]]
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
    NSString *data2 = [NSString stringWithContentsOfURL:[self generateUrlForDate:[sunday dateByAddingTimeInterval:3 * 24 * 3600]]
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
    NSString *data3 = [NSString stringWithContentsOfURL:[self generateUrlForDate:[sunday dateByAddingTimeInterval:4 * 24 * 3600]]
                                            encoding:NSUTF8StringEncoding
                                                  error:nil];
    NSString *data4 = [NSString stringWithContentsOfURL:[self generateUrlForDate:[sunday dateByAddingTimeInterval:5 * 24 * 3600]]
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;

    
    NSDictionary *json0 = [NSJSONSerialization JSONObjectWithData:[data0 dataUsingEncoding:NSUTF8StringEncoding]
                                                          options:NSJSONReadingMutableContainers
                                                            error:nil];
    json0 = [self cleanDictionary:json0];
    [json0 writeToFile:[NSString stringWithFormat:@"%@/unfiltered-0", documentsPath] atomically:YES];

    
    NSDictionary *json1 = [NSJSONSerialization JSONObjectWithData:[data1 dataUsingEncoding:NSUTF8StringEncoding]
                                                          options:NSJSONReadingMutableContainers
                                                            error:nil];
    json1 = [self cleanDictionary:json1];
    [json1 writeToFile:[NSString stringWithFormat:@"%@/unfiltered-1", documentsPath] atomically:YES];
    
    
    NSDictionary *json2 = [NSJSONSerialization JSONObjectWithData:[data2 dataUsingEncoding:NSUTF8StringEncoding]
                                                          options:NSJSONReadingMutableContainers
                                                            error:nil];
    json2 = [self cleanDictionary:json2];
    [json2 writeToFile:[NSString stringWithFormat:@"%@/unfiltered-2", documentsPath] atomically:YES];
    
    
    NSDictionary *json3 = [NSJSONSerialization JSONObjectWithData:[data3 dataUsingEncoding:NSUTF8StringEncoding]
                                                          options:NSJSONReadingMutableContainers
                                                            error:nil];
    json3 = [self cleanDictionary:json3];
    [json3 writeToFile:[NSString stringWithFormat:@"%@/unfiltered-3", documentsPath] atomically:YES];
    
    
    NSDictionary *json4 = [NSJSONSerialization JSONObjectWithData:[data4 dataUsingEncoding:NSUTF8StringEncoding]
                                                          options:NSJSONReadingMutableContainers
                                                            error:nil];
    json4 = [self cleanDictionary:json4];
    [json4 writeToFile:[NSString stringWithFormat:@"%@/unfiltered-4", documentsPath] atomically:YES];
    
    
    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"lastUpdatedSuplence" toObject:[NSDate date]];

    [self filter];
}

- (void)filter {
    _isRefreshing = YES;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
  
    NSString *filter = (NSString *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"filter"];
    if (filter == nil)
        filter = @"";
    
    NSArray *subFilters = (NSArray *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"podFilter"];
    if (subFilters == nil)
        subFilters = @[];
    
    if ([filter isEqualToString:@""] && [subFilters isEqualToArray:@[]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VDDDataFetchComplete" object:nil];
        _isRefreshing = NO;
        return;
    }
    
    
    NSDictionary *dictionary0 = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/unfiltered-0", documentsPath]];
    NSDictionary *dictionary1 = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/unfiltered-1", documentsPath]];
    NSDictionary *dictionary2 = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/unfiltered-2", documentsPath]];
    NSDictionary *dictionary3 = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/unfiltered-3", documentsPath]];
    NSDictionary *dictionary4 = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/unfiltered-4", documentsPath]];
    
    dictionary0 = [self filterDictionary:dictionary0 withFilter:filter subFilters:subFilters];
    dictionary1 = [self filterDictionary:dictionary1 withFilter:filter subFilters:subFilters];
    dictionary2 = [self filterDictionary:dictionary2 withFilter:filter subFilters:subFilters];
    dictionary3 = [self filterDictionary:dictionary3 withFilter:filter subFilters:subFilters];
    dictionary4 = [self filterDictionary:dictionary4 withFilter:filter subFilters:subFilters];
    
    [dictionary0 writeToFile:[NSString stringWithFormat:@"%@/filtered-0", documentsPath] atomically:YES];
    [dictionary1 writeToFile:[NSString stringWithFormat:@"%@/filtered-1", documentsPath] atomically:YES];
    [dictionary2 writeToFile:[NSString stringWithFormat:@"%@/filtered-2", documentsPath] atomically:YES];
    [dictionary3 writeToFile:[NSString stringWithFormat:@"%@/filtered-3", documentsPath] atomically:YES];
    [dictionary4 writeToFile:[NSString stringWithFormat:@"%@/filtered-4", documentsPath] atomically:YES];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VDDDataFetchComplete" object:nil];
    
    _isRefreshing = NO;
    
    
    /*if (![NSThread isMainThread])
        [NSThread exit];*/
}

/*-(NSURL *)generateUrlForDate:(NSDate *)dateToGenerate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = [NSTimeZone defaultTimeZone];
    
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *requestDate = [dateFormatter stringFromDate:dateToGenerate];
    
    dateFormatter.dateFormat = @"yyyy-MM-dd%20HH:mm:ss";
    NSString *lastUpdateDate = [dateFormatter stringFromDate:(NSDate *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"lastUpdatedSuplence"]];
    
    NSString *urlString = [NSString stringWithFormat:@"http://app.gimvic.org/APIv2/json_provider.php?datum=%@&last_update=%@", requestDate, lastUpdateDate];
    NSLog(@"%@", urlString);
    return [NSURL URLWithString:urlString];
}*/

#pragma mark - URL Creation

- (NSURL *)generateUrlForDate:(NSDate *)dateToGenerate {
    NSString *serverName = @"solsis.gimvic.org";
    NSString *apiKey = @"ede5e730-8464-11e3-baa7-0800200c9a66";
    NSMutableString *url = [NSMutableString stringWithString: [NSString stringWithFormat:@"https://%@/?", serverName]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    NSString *date = [dateFormatter stringFromDate:dateToGenerate];
    NSString *nonsense = [[NSUUID UUID] UUIDString];
    
    NSString *params = [NSString stringWithFormat:@"func=gateway&call=suplence&datum=%@&nonsense=%@", date, nonsense];
    NSString *signatureString = [NSString stringWithFormat:@"%@||%@||%@", serverName, params, apiKey];
    
    NSString *signature = [VDDCrypto sha256hashFor:signatureString];
    [url appendString:[NSString stringWithFormat:@"%@&signature=%@", params, signature]];
    
    NSURL *serverUrl = [NSURL URLWithString:url];
    
    return serverUrl;
}

#pragma mark - Filtering

- (NSDictionary *)filterDictionary:(NSDictionary *)dict withFilter:(NSString *)filter subFilters:(NSArray *)subFilter {
    NSMutableDictionary *resultDictionary = [[NSMutableDictionary alloc] init];
    
    NSArray *rootDictionaryKeys = [dict allKeys];
    for (NSString *key in rootDictionaryKeys) {
        NSArray *item = [dict valueForKey:key];
        if (item.count == 0) {
            [resultDictionary setObject:item forKey:key];
            continue;
        }
        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary *subDictionary in item) {
            NSArray *subDictionaryKeys = [subDictionary allKeys];
            
            for (NSString *subKey in subDictionaryKeys) {
                NSString *value = [[subDictionary valueForKey:subKey] stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString;
                
                if ([value containsString:filter]) {
                    [resultArray addObject:subDictionary];
                    break;
                }
                
                NSString *firstLetter = [filter substringToIndex:1];
                NSString *other = [filter substringWithRange:NSMakeRange(1, filter.length-1)];
                NSString *filter1 = [NSString stringWithFormat:@"%@%@", other, firstLetter];
                    
                if ([value containsString:filter1]) {
                    [resultArray addObject:subDictionary];
                    break;
                }
                
                NSString *lastLetter = [filter substringFromIndex:filter.length - 1];
                other = [filter substringToIndex:filter.length - 1];
                filter1 = [NSString stringWithFormat:@"%@%@", lastLetter, other];
                    
                if ([value containsString:filter1]) {
                    [resultArray addObject:subDictionary];
                    break;
                }
                
                
                if (subFilter.count == 0) continue;
                
                BOOL contains = NO;
                for (int i = 0; i < subFilter.count; i++) {
                    if ([value containsString:subFilter[i]]) {
                        contains = YES;
                        break;
                    }
                }
                
                
                if (contains) {
                    [resultArray addObject:subDictionary];
                    break;
                }
            }
            
            [resultDictionary setObject:resultArray forKey:key];
        }
    }
    
    return resultDictionary;
}

- (NSDictionary *)cleanDictionary:(NSDictionary *)rootDictionary
{
    //Clean nadomescanja
    NSString *razred;
    NSString *nadomesca;
    NSString *opomba;
    NSString *predmet;
    NSString *ucilnica;
    NSString *ura;
    NSString *odsoten;
    
    NSMutableArray *nadomescanjaFinal = [[NSMutableArray alloc] init];
    
    NSArray *nadomescanja = [rootDictionary valueForKey:@"nadomescanja"];
    for (NSDictionary *itemInNadomescanja in nadomescanja) {
        odsoten = [itemInNadomescanja valueForKey:@"odsoten_fullname"];
        
        NSArray *nadomescanjaUre = [itemInNadomescanja valueForKey:@"nadomescanja_ure"];
        for (NSDictionary *itemInNadomescanjaUre in nadomescanjaUre) {
            razred = [itemInNadomescanjaUre valueForKey:@"class_name"];
            razred = [razred stringByReplacingOccurrencesOfString:@" " withString:@""];
            nadomesca = [itemInNadomescanjaUre valueForKey:@"nadomesca_full_name"];
            opomba = [itemInNadomescanjaUre valueForKey:@"opomba"];
            predmet = [itemInNadomescanjaUre valueForKey:@"predmet"];
            ucilnica = [itemInNadomescanjaUre valueForKey:@"ucilnica"];
            ura = [itemInNadomescanjaUre valueForKey:@"ura"];
            ura = [ura stringByReplacingOccurrencesOfString:@"." withString:@""];
            
            NSDictionary *nadomescanjaCleanedDictionary = @{@"odsoten": odsoten,
                                                            @"razred": razred,
                                                            @"nadomesca": nadomesca,
                                                            @"opomba": opomba,
                                                            @"predmet": predmet,
                                                            @"ucilnica": ucilnica,
                                                            @"ura": ura};
            [nadomescanjaFinal addObject:nadomescanjaCleanedDictionary];
        }
    }

    
    //Clean menjava predmeta
    NSString *ucitelj;
    NSString *originalPredmet;
    NSString *newPredmet;
    
    NSMutableArray *menjavaPredmetaFinal = [[NSMutableArray alloc] init];
    
    NSArray *menjavaPredmeta = [rootDictionary valueForKey:@"menjava_predmeta"];
    
    for (NSDictionary *itemInMenjavaPredmeta in menjavaPredmeta) {
        ura = [itemInMenjavaPredmeta valueForKey:@"ura"];
        ura = [ura stringByReplacingOccurrencesOfString:@"." withString:@""];
        razred = [itemInMenjavaPredmeta valueForKey:@"class_name"];
        razred = [razred stringByReplacingOccurrencesOfString:@" " withString:@""];
        ucilnica = [itemInMenjavaPredmeta valueForKey:@"ucilnica"];
        ucitelj = [itemInMenjavaPredmeta valueForKey:@"ucitelj"];
        originalPredmet = [itemInMenjavaPredmeta valueForKey:@"original_predmet"];
        newPredmet = [itemInMenjavaPredmeta valueForKey:@"predmet"];
        opomba = [itemInMenjavaPredmeta valueForKey:@"opomba"];
        
        NSDictionary *menjavaPredmetaCleanedDictionary = @{@"ura": ura,
                                                           @"razred": razred,
                                                           @"ucilnica": ucilnica,
                                                           @"ucitelj": ucitelj,
                                                           @"originalPredmet": originalPredmet,
                                                           @"newPredmet": newPredmet,
                                                           @"opomba": opomba};
        [menjavaPredmetaFinal addObject:menjavaPredmetaCleanedDictionary];
    }
    
    
    //Clean menjava ur
    NSString *zamenjavaUciteljev;
    
    NSMutableArray *menjavaUrFinal = [[NSMutableArray alloc] init];
    
    NSArray *menjavaUr = [rootDictionary valueForKey:@"menjava_ur"];
    for (NSDictionary *itemInMenjavaUr in menjavaUr) {
        ura = [itemInMenjavaUr valueForKey:@"ura"];
        ura = [ura stringByReplacingOccurrencesOfString:@"." withString:@""];
        razred = [itemInMenjavaUr valueForKey:@"class_name"];
        razred = [razred stringByReplacingOccurrencesOfString:@" " withString:@""];
        ucilnica = [itemInMenjavaUr valueForKey:@"ucilnica"];
        opomba = [itemInMenjavaUr valueForKey:@"opomba"];
        predmet = [itemInMenjavaUr valueForKey:@"predmet"];
        zamenjavaUciteljev = [itemInMenjavaUr valueForKey:@"zamenjava_uciteljev"];
        
        
        
        NSRange range = [predmet rangeOfString:@" -> "];
        NSString *predmetFrom = [predmet substringToIndex:range.location];
        NSString *predmetTo = [predmet substringFromIndex:range.location + range.length];
        
        range = [zamenjavaUciteljev rangeOfString:@" -> "];
        NSString *uciteljFrom = [zamenjavaUciteljev substringToIndex:range.location];
        NSString *uciteljTo = [zamenjavaUciteljev substringFromIndex:range.location + range.length];
        
        
        NSDictionary *menjavaUrCleanedDictionary = @{@"razred": razred,
                                                     @"opomba": opomba,
                                                     @"predmetFrom": predmetFrom,
                                                     @"predmetTo": predmetTo,
                                                     @"ucilnica": ucilnica,
                                                     @"uciteljFrom": uciteljFrom,
                                                     @"uciteljTo": uciteljTo,
                                                     @"ura": ura};
        [menjavaUrFinal addObject:menjavaUrCleanedDictionary];
    }
    
    
    //Clean menjava ucilnic
    NSString *ucilnicaFrom;
    NSString *ucilnicaTo;
    
    NSMutableArray *menjavaUcilnicFinal = [[NSMutableArray alloc] init];
    
    NSArray *menjavaUcilnic = [rootDictionary valueForKey:@"menjava_ucilnic"];
    for (NSDictionary *itemInMenjavaUcilnic in menjavaUcilnic) {
        ura = [itemInMenjavaUcilnic valueForKey:@"ura"];
        ura = [ura stringByReplacingOccurrencesOfString:@"." withString:@""];
        razred = [itemInMenjavaUcilnic valueForKey:@"class_name"];
        razred = [razred stringByReplacingOccurrencesOfString:@" " withString:@""];
        opomba = [itemInMenjavaUcilnic valueForKey:@"opomba"];
        predmet = [itemInMenjavaUcilnic valueForKey:@"predmet"];
        ucitelj = [itemInMenjavaUcilnic valueForKey:@"ucitelj"];
        ucilnicaFrom = [itemInMenjavaUcilnic valueForKey:@"ucilnica_from"];
        ucilnicaTo = [itemInMenjavaUcilnic valueForKey:@"ucilnica_to"];
        
        NSDictionary *menjavaUcilnicCleanedDictionary = @{@"razred": razred,
                                                          @"opomba": opomba,
                                                          @"predmet": predmet,
                                                          @"ucilnicaFrom": ucilnicaFrom,
                                                          @"ucilnicaTo": ucilnicaTo,
                                                          @"ucitelj": ucitelj,
                                                          @"ura": ura};
        [menjavaUcilnicFinal addObject:menjavaUcilnicCleanedDictionary];
    }
    
    
    //Clean rezervacija ucilnic
    NSString *rezervator;
    
    NSMutableArray *rezervacijaUcilnicFinal = [[NSMutableArray alloc] init];
    
    NSArray *rezervacijaUcilnic = [rootDictionary valueForKey:@"rezerviranje_ucilnice"];
    for (NSDictionary *itemInRezervacijaUcilnic in rezervacijaUcilnic) {
        ura = [itemInRezervacijaUcilnic valueForKey:@"ura"];
        ura = [ura stringByReplacingOccurrencesOfString:@"." withString:@""];
        ucilnica = [itemInRezervacijaUcilnic valueForKey:@"ucilnica"];
        rezervator = [itemInRezervacijaUcilnic valueForKey:@"rezervator"];
        opomba = [itemInRezervacijaUcilnic valueForKey:@"opomba"];
        
        NSDictionary *rezervacijaUcilnicCleanedDictionary = @{@"ura": ura,
                                                              @"ucilnica": ucilnica,
                                                              @"rezervator": rezervator,
                                                              @"opomba": opomba};
        [rezervacijaUcilnicFinal addObject:rezervacijaUcilnicCleanedDictionary];
    }
    
    
    //Clean vec uciteljev v razredu
    NSMutableArray *vecUciteljevFinal = [[NSMutableArray alloc] init];
    
    NSArray *vecUciteljev = [rootDictionary valueForKey:@"vec_uciteljev_v_razredu"];
    for (NSDictionary *itemInVecUciteljev in vecUciteljev) {
        ura = [itemInVecUciteljev valueForKey:@"ura"];
        ura = [ura stringByReplacingOccurrencesOfString:@"." withString:@""];
        ucitelj = [itemInVecUciteljev valueForKey:@"ucitelj"];
        razred = [itemInVecUciteljev valueForKey:@"class_name"];
        razred = [razred stringByReplacingOccurrencesOfString:@" " withString:@""];
        ucilnica = [itemInVecUciteljev valueForKey:@"ucilnica"];
        opomba = [itemInVecUciteljev valueForKey:@"opomba"];
        
        NSDictionary *vecUciteljevCleanedDictionary = @{@"ura": ura,
                                                        @"ucitelj": ucitelj,
                                                        @"razred": razred,
                                                        @"ucilnica": ucilnica,
                                                        @"opomba": opomba};
        [vecUciteljevFinal addObject:vecUciteljevCleanedDictionary];
    }
    
    
    NSDictionary *result = @{@"nadomescanja": nadomescanjaFinal,
                             @"menjavaPredmeta": menjavaPredmetaFinal,
                             @"menjavaUr": menjavaUrFinal,
                             @"menjavaUcilnic": menjavaUcilnicFinal,
                             @"rezervacijaUcilnic": rezervacijaUcilnicFinal,
                             @"vecUciteljevVRazredu": vecUciteljevFinal};
    return result;
}

@end