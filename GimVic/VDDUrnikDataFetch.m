//
//  VDDUrnikDataFetch.m
//  GimVic
//
//  Created by Vid Drobnič on 10/16/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDUrnikDataFetch.h"
#import "VDDMetaData.h"
#import "VDDReachability.h"

@implementation VDDUrnikDataFetch

#pragma mark - Singleton Declaraion

+ (instancetype)sharedUrnikDataFetch
{
    static VDDUrnikDataFetch *sharedUrnikDataFetch;
    if (!sharedUrnikDataFetch)
        sharedUrnikDataFetch = [[self alloc] initPrivate];
    
    return sharedUrnikDataFetch;
}

#pragma mark - Initialization

- (instancetype)initPrivate {
    self = [super init];
    if (self)
        _isRefreshing = NO;
    
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"VDDUrnikDataFetch is a singleton."
                                   reason:@"For VDDUrnikDataFetch you should use sharedUrnikDataFetch."
                                 userInfo:nil];
}

#pragma mark - Downloading

- (NSString *)download {
    NSURL *url = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/16258361/urnik/data.js"];
    NSString *dataStirng = [NSString stringWithContentsOfURL:url
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
    
    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"lastUpdatedUrnik" toObject:[NSDate date]];
    
    return dataStirng;
}

#pragma mark - Parsing

- (void)parseString:(NSString *)dataString {
    dataString = [dataString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    dataString = [dataString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    NSArray *dataArray = [dataString componentsSeparatedByString:@"\n"];
    
    NSMutableArray *podatki = [[NSMutableArray alloc] init];
    NSMutableArray *razredi = [[NSMutableArray alloc] init];
    NSMutableArray *ucitelji = [[NSMutableArray alloc] init];
    NSMutableArray *ucilnice = [[NSMutableArray alloc] init];
    NSMutableArray *podRazredi3 = [[NSMutableArray alloc] init];
    NSMutableArray *podRazredi4 = [[NSMutableArray alloc] init];
    NSMutableArray *podatkiOptions = [[NSMutableArray alloc] init];
    
    
    if (dataArray.count == 0 || dataArray == nil)
        return;
    
    
    for (int i = 0; i < dataArray.count; i++) {
        NSString *elementString = dataArray[i];
        
        if ([elementString containsString:@"new Array"]) continue;
        
        if ([elementString containsString:@"podatki"]) {
            NSMutableString *razred = [[self cleanPodatkiString:dataArray[i+1]][2] mutableCopy];
            NSString *razredFinal;
            if (razred.length == 2) {
                [razred insertString:@"." atIndex:1];
                razredFinal = razred.lowercaseString;
            } else
                razredFinal = razred;
            
            
            NSString *ura = [self cleanPodatkiString:dataArray[i+6]][2];
            NSString *dan = [self cleanPodatkiString:dataArray[i+5]][2];
            
            NSDictionary *podatkiCheck = @{@"filter": razredFinal,
                                           @"ura": ura,
                                           @"dan": dan};
            if (![podatkiOptions containsObject:podatkiCheck]) {
                NSMutableDictionary *onePodatekDictionary = [@{@"razred": razredFinal,
                                                               @"profesorji": @[],
                                                               @"predmeti": @[],
                                                               @"ucilnice": @[],
                                                               @"dan": dan,
                                                               @"ura": ura} mutableCopy];
                [podatki addObject:onePodatekDictionary];
                [podatkiOptions addObject:podatkiCheck];
            }
            
            for (int j = 0; j < podatki.count; j++) {
                if ([[podatki[j] valueForKey:@"razred"] isEqualToString:razredFinal] &&
                    [[podatki[j] valueForKey:@"dan"] isEqualToString:dan] &&
                    [[podatki[j] valueForKey:@"ura"] isEqualToString:ura])
                {
                    NSMutableArray *localProfesorji = [[podatki[j] valueForKey:@"profesorji"] mutableCopy];
                    NSString *localProfesor = [self cleanPodatkiString:dataArray[i+2]][2];
                    if (![localProfesorji containsObject:localProfesor])
                        [localProfesorji addObject:localProfesor];
                    
                    NSMutableArray *localPredmeti = [[podatki[j] valueForKey:@"predmeti"] mutableCopy];
                    NSString *localPredmet = [self cleanPodatkiString:dataArray[i+3]][2];
                    if (![localPredmeti containsObject:localPredmet])
                        [localPredmeti addObject:localPredmet];
                    
                    NSMutableArray *localUcilnice = [[podatki[j] valueForKey:@"ucilnice"] mutableCopy];
                    NSString *localUcilnica = [self cleanPodatkiString:dataArray[i+4]][2];
                    if (![localUcilnice containsObject:localUcilnica])
                        [localUcilnice addObject:localUcilnica];
                    
                    (podatki[j])[@"profesorji"] = localProfesorji;
                    (podatki[j])[@"predmeti"] = localPredmeti;
                    (podatki[j])[@"ucilnice"] = localUcilnice;
                }
            }
            
            i += 6;
            continue;
        }
        
        if ([elementString containsString:@"razredi"]) {
            NSMutableString *razred = [[self cleanOtherString:elementString][1] mutableCopy];
            NSString *razredFinal;
            BOOL isMain = NO;
            if (razred.length == 2) {
                [razred insertString:@"." atIndex:1];
                razredFinal = razred.lowercaseString;
                isMain = YES;
            } else razredFinal = razred;
            
            if (isMain)
                [razredi addObject:razredFinal];
            else {
                if ([[razredFinal substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"3"])
                    [podRazredi3 addObject:razredFinal];
                
                else if ([[razredFinal substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"M"])
                    [podRazredi4 addObject:razredFinal];
            }
            
        }
        
        if ([elementString containsString:@"ucitelji"])
            [ucitelji addObject:[self cleanOtherString:elementString][1]];
        
        if ([elementString containsString:@"ucilnice"])
            [ucilnice addObject:[self cleanOtherString:elementString][1]];
    }
    
    NSDictionary *podRazredi = @{@"3": podRazredi3,
                                 @"4": podRazredi4
                                 };
    
    NSDictionary *rootDictionary = @{@"podatki": podatki,
                                     @"razredi": razredi,
                                     @"podRazredi": podRazredi,
                                     @"ucitelji": ucitelji,
                                     @"ucilnice": ucilnice
                                     };
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? paths[0] : nil;
    
    [rootDictionary writeToFile:[NSString stringWithFormat:@"%@/unfilteredPodatki", documentsPath] atomically:YES];
}

- (NSArray *)cleanPodatkiString:(NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@"podatki" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"][" withString:@";"];
    string = [string stringByReplacingOccurrencesOfString:@"[" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"]" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" = " withString:@";"];
    
    return [string componentsSeparatedByString:@";"];
}

- (NSArray *)cleanOtherString:(NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@"razred" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"[" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"]" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" = " withString:@";"];
    
    return [string componentsSeparatedByString:@";"];
}

- (NSMutableArray *)mergeHours:(NSMutableArray *) array {
    for (int i = 0; i < array.count; ++i) {
        NSString *ura = array[i][@"ura"];
        for (int j = i+1; j < array.count; ++j) {
            if ([ura isEqualToString:array[j][@"ura"] ]) {
                for (NSString *predmet in array[j][@"predmeti"])
                    [array[i][@"predmeti"] addObject:predmet];
                for (NSString *profesor in array[j][@"profesorji"])
                    [array[i][@"profesorji"] addObject:profesor];
                for (NSString *ucilnica in array[j][@"ucilnice"])
                    [array[i][@"ucilnice"] addObject:ucilnica];
                [array removeObjectAtIndex:j];
                --j;
            }
        }
    }
    
    return array;
}

#pragma mark - Refreshing

- (void)refresh {
    _isRefreshing = YES;
    
    if (![VDDReachability checkInternetConnection]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VDDUrnikFetchComplete" object:nil];
        
        _isRefreshing = NO;
        return;
    }
    
    NSString *dataString = [self download];
    [self parseString:dataString];
    [self filter];
}

#pragma mark-  Filtering

- (void)filter {
    _isRefreshing = YES;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? paths[0] : nil;
    
    NSString *filter = (NSString *)[[VDDMetaData sharedMetaData] metaDataObjectForKey:@"filter"];
    if (filter == nil || [filter isEqualToString:@""]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VDDUrnikFetchComplete" object:nil];
        _isRefreshing = NO;
        return;
    }
    
    
    NSArray *subFilters = (NSArray *)[[VDDMetaData sharedMetaData]metaDataObjectForKey:@"podFilter"];
    if (subFilters == nil)
        subFilters = @[];
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/unfilteredPodatki", documentsPath]];
    
    
    if (data == nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VDDUrnikFetchComplete" object:nil];
        _isRefreshing = NO;
        return;
    }
    
    NSMutableArray *filteredPodatki = [[NSMutableArray alloc] init];

    NSArray *podatki = data[@"podatki"];
    for (int i = 0; i < podatki.count; i++) {
        NSDictionary *element = podatki[i];
        
        NSString *razred = [[element valueForKey:@"razred"] stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString;
        NSArray *ucilnice = [element valueForKey:@"ucilnice"];
        NSArray *proferosji = [element valueForKey:@"profesorji"];
        
        
        if (subFilters.count > 0) {
            BOOL hasFilter = NO;
            for (int j = 0; j < subFilters.count; j++) {
                if ([razred containsString:subFilters[j]]) {
                    hasFilter = YES;
                    break;
                }
            }
            
            if (hasFilter) {
                [filteredPodatki addObject:element];
                continue;
            }
        }
        
        
        if ([razred containsString:filter]) {
            [filteredPodatki addObject:element];
            continue;
        }
        
        
        BOOL hasFilter = NO;
        
        for (int j = 0; j < ucilnice.count; j++) {
            NSString *value = [ucilnice[j] stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString;
            if ([value containsString:filter]) {
                hasFilter = YES;
                break;
            }
            
            NSString *firstLetter = [filter substringToIndex:1];
            NSString *other = [filter substringWithRange:NSMakeRange(1, filter.length-1)];
            NSString *filter1 = [NSString stringWithFormat:@"%@%@", other, firstLetter];
            if ([value containsString:filter1]) {
                hasFilter = YES;
                break;
            }
            
            NSString *lastLetter = [filter substringFromIndex:filter.length - 1];
            other = [filter substringToIndex:filter.length - 1];
            filter1 = [NSString stringWithFormat:@"%@%@", lastLetter, other];
            if ([value containsString:filter1]) {
                hasFilter = YES;
                break;
            }
        }
        
        if (hasFilter) {
            [filteredPodatki addObject:element];
            continue;
        }
        
        
        hasFilter = NO;
        
        for (int j = 0; j < proferosji.count; j++) {
            NSString *value = [proferosji[j] stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString;
            if ([value containsString:filter]) {
                hasFilter = YES;
                break;
            }
            
            NSString *firstLetter = [filter substringToIndex:1];
            NSString *other = [filter substringWithRange:NSMakeRange(1, filter.length-1)];
            NSString *filter1 = [NSString stringWithFormat:@"%@%@", other, firstLetter];
            if ([value containsString:filter1]) {
                hasFilter = YES;
                break;
            }
            
            NSString *lastLetter = [filter substringFromIndex:filter.length - 1];
            other = [filter substringToIndex:filter.length - 1];
            filter1 = [NSString stringWithFormat:@"%@%@", lastLetter, other];
            if ([value containsString:filter1]) {
                hasFilter = YES;
                break;
            }
        }
        
        if (hasFilter)
            [filteredPodatki addObject:element];
    }
    
    
    data[@"podatki"] = filteredPodatki;
    [data writeToFile:[NSString stringWithFormat:@"%@/filteredPodatki", documentsPath] atomically:YES];
    
    NSMutableArray *filteredUrnik1 = [[NSMutableArray alloc] init];
    NSMutableArray *filteredUrnik2 = [[NSMutableArray alloc] init];
    NSMutableArray *filteredUrnik3 = [[NSMutableArray alloc] init];
    NSMutableArray *filteredUrnik4 = [[NSMutableArray alloc] init];
    NSMutableArray *filteredUrnik5 = [[NSMutableArray alloc] init];
    
    for (NSDictionary *element in data[@"podatki"]) {
        int dan = [element[@"dan"] intValue];
        if (dan == 1)
            [filteredUrnik1 addObject:element];
        
        if (dan == 2)
            [filteredUrnik2 addObject:element];
        
        if (dan == 3)
            [filteredUrnik3 addObject:element];
        
        if (dan == 4)
            [filteredUrnik4 addObject:element];
        
        if (dan == 5)
            [filteredUrnik5 addObject:element];
    }
    
    filteredUrnik1 = [self mergeHours:filteredUrnik1];
    filteredUrnik2 = [self mergeHours:filteredUrnik2];
    filteredUrnik3 = [self mergeHours:filteredUrnik3];
    filteredUrnik4 = [self mergeHours:filteredUrnik4];
    filteredUrnik5 = [self mergeHours:filteredUrnik5];
    
    [filteredUrnik1 writeToFile:[NSString stringWithFormat:@"%@/filteredUrnik-1", documentsPath] atomically:YES];
    [filteredUrnik2 writeToFile:[NSString stringWithFormat:@"%@/filteredUrnik-2", documentsPath] atomically:YES];
    [filteredUrnik3 writeToFile:[NSString stringWithFormat:@"%@/filteredUrnik-3", documentsPath] atomically:YES];
    [filteredUrnik4 writeToFile:[NSString stringWithFormat:@"%@/filteredUrnik-4", documentsPath] atomically:YES];
    [filteredUrnik5 writeToFile:[NSString stringWithFormat:@"%@/filteredUrnik-5", documentsPath] atomically:YES];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VDDUrnikFetchComplete" object:nil];
    _isRefreshing = NO;
}
@end