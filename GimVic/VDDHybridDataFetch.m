//
//  VDDHybridDataFetch.m
//  GimVic
//
//  Created by Vid Drobnič on 11/13/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDHybridDataFetch.h"
#import "VDDMetaData.h"

@interface VDDHybridDataFetch ()

@end


@implementation VDDHybridDataFetch

#pragma mark - Singleton Declaration

+ (instancetype)sharedHybridDataFetch {
    static VDDHybridDataFetch *sharedDataFetch;
    if (!sharedDataFetch)
        sharedDataFetch = [[self alloc] initPrivate];
    
    return sharedDataFetch;
}

#pragma mark - Initialization

- (instancetype)initPrivate {
    self = [super init];
    
    if (self)
        _isRefreshing = NO;
    
    return self;
}

#pragma mark - Parsing Hybrid

- (void)refresh {
    _isRefreshing = YES;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = (paths.count > 0) ? paths[0] : nil;
    
    
    for (int f = 0; f < 5; f++) {
        @try {
            NSMutableArray *urnikData = [NSMutableArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/filteredUrnik-%d", documentsPath, f + 1]];
            NSDictionary *suplenceData = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/filtered-%d", documentsPath, f]];
            
            if (urnikData == nil || suplenceData == nil) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"VDDHybridFetchComplete" object:nil];
                _isRefreshing = NO;
                return;
            }
            
            
            NSArray *menjavaPredmeta = suplenceData[@"menjavaPredmeta"];
            if (menjavaPredmeta.count > 0) {
                for (int i = 0; i < menjavaPredmeta.count; i++) {
                    NSDictionary *suplenceElement = menjavaPredmeta[i];
                    for (int j = 0; j < urnikData.count; j++) {
                        NSMutableDictionary *urnikElement = urnikData[j];
                        if ([urnikElement[@"ura"] isEqualToString:suplenceElement[@"ura"]]) {
                            NSMutableArray *predmeti = urnikElement[@"predmeti"];
                            int index = (int)[predmeti indexOfObject:suplenceElement[@"originalPredmet"]];
                            predmeti[index] = suplenceElement[@"newPredmet"];
                            urnikElement[@"predmeti"] = predmeti;
                            urnikData[j] = urnikElement;
                            (urnikData[j])[@"spremenjeno"] = @YES;
                            (urnikData[j])[@"opomba"] = suplenceElement[@"opomba"];
                        }
                    }
                }
            }
            
            
            NSArray *menjavaUcilnic = suplenceData[@"menjavaUcilnic"];
            if (menjavaUcilnic.count > 0) {
                for (int i = 0; i < menjavaUcilnic.count; i++) {
                    NSDictionary *suplenceElement = menjavaUcilnic[i];
                    for (int j = 0; j < urnikData.count; j++) {
                        NSMutableDictionary *urnikElement = urnikData[j];
                        if ([urnikElement[@"ura"] isEqualToString:suplenceElement[@"ura"]]) {
                            NSMutableArray *ucilnice = urnikElement[@"ucilnice"];
                            NSString *suplenceUcilniceString = suplenceElement[@"ucilnicaFrom"];
                            NSArray *suplenceUcilnice = [[NSArray alloc] init];
                            if ([suplenceUcilniceString containsString:@","]) {
                                suplenceUcilnice = [[suplenceUcilniceString stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
                            } else suplenceUcilnice = @[suplenceUcilniceString];
                            BOOL contains = YES;
                            for (int a = 0; a < suplenceUcilnice.count; a++) {
                                if (![ucilnice containsObject:suplenceUcilnice[a]]) {
                                    contains = NO;
                                    break;
                                }
                            }
                            if (contains) {
                                for (int a = 0 ; a < suplenceUcilnice.count; a++) {
                                    int index = (int)[ucilnice indexOfObject:suplenceUcilnice[a]];
                                    ucilnice[index] = suplenceElement[@"ucilnicaTo"];
                                }
                            } else ucilnice = [suplenceUcilnice mutableCopy];
                            urnikElement[@"ucilnice"] = ucilnice;
                            urnikData[j] = urnikElement;
                            (urnikData[j])[@"spremenjeno"] = @YES;
                            (urnikData[j])[@"opomba"] = suplenceElement[@"opomba"];
                        }
                    }
                }
            }
            
            NSArray *menjavaUr = suplenceData[@"menjavaUr"];
            if (menjavaUr.count > 0) {
                for (int i = 0; i < menjavaUr.count; i++) {
                    NSDictionary *suplenceElement = menjavaUr[i];
                    for (int j = 0; j < urnikData.count; j++) {
                        NSMutableDictionary *urnikElement = urnikData[j];
                        if ([urnikElement[@"ura"] isEqualToString:suplenceElement[@"ura"]]) {
                            NSMutableArray *predmeti = urnikElement[@"predmeti"];
                            int index = (int)[predmeti indexOfObject:suplenceElement[@"predmetFrom"]];
                            NSLog(@"%@", predmeti);
                            NSLog(@"%@", suplenceElement);
                            predmeti[index] = suplenceElement[@"predmetTo"];
                            urnikElement[@"predmeti"] = predmeti;
                            
                            NSMutableArray *profesorji = urnikElement[@"profesorji"];
                            index = [self indexOfProfesorNameFromSuplence:suplenceElement[@"uciteljFrom"] inUrnik:profesorji];
                            if (index > -1)
                                profesorji[index] = suplenceElement[@"uciteljTo"];
                            else
                                [profesorji addObject:suplenceElement[@"uciteljTo"]];
                            urnikElement[@"profesorji"] = profesorji;
                            urnikData[j] = urnikElement;
                            (urnikData[j])[@"spremenjeno"] = @YES;
                            (urnikData[j])[@"opomba"] = suplenceElement[@"opomba"];
                        }
                    }
                }
            }
            
            NSArray *nadomescanja = suplenceData[@"nadomescanja"];
            if (nadomescanja.count > 0) {
                for (int i = 0; i < nadomescanja.count; i++) {
                    NSDictionary *suplenceElement = nadomescanja[i];
                    for (int j = 0; j < urnikData.count; j++) {
                        NSMutableDictionary *urnikElement = urnikData[j];
                        if ([urnikElement[@"ura"] isEqualToString:suplenceElement[@"ura"]]) {
                            NSMutableArray *profesorji = urnikElement[@"profesorji"];
                            NSMutableArray *predmeti = urnikElement[@"predmeti"];
                            NSMutableArray *ucilnice = urnikElement[@"ucilnice"];
                            int index = [self indexOfProfesorNameFromSuplence:suplenceElement[@"odsoten"] inUrnik:profesorji];
                            if (index > -1) {
                                if (profesorji.count > index)
                                    profesorji[index] = suplenceElement[@"nadomesca"];
                                else
                                    [profesorji addObject:suplenceElement[@"nadomesca"]];
                                
                                if (predmeti.count > index)
                                    predmeti[index] = suplenceElement[@"predmet"];
                                else
                                    [predmeti addObject:suplenceElement[@"predmet"]];
                                
                                if (ucilnice.count > index)
                                    ucilnice[index] = suplenceElement[@"ucilnica"];
                                else
                                    [ucilnice addObject:suplenceElement[@"ucilnica"]];
                            } else {
                                [profesorji addObject:suplenceElement[@"nadomesca"]];
                                [predmeti addObject:suplenceElement[@"predmet"]];
                                [ucilnice addObject:suplenceElement[@"ucilnica"]];
                            }
                            urnikElement[@"profesorji"] = profesorji;
                            urnikElement[@"predmeti"] = predmeti;
                            urnikElement[@"ucilnice"] = ucilnice;
                            urnikData[j] = urnikElement;
                            (urnikData[j])[@"spremenjeno"] = @YES;
                            (urnikData[j])[@"opomba"] = suplenceElement[@"opomba"];
                        }
                    }
                }
            }
            
            NSArray *vecUciteljevVRazredu = suplenceData[@"vecUciteljevVRazredu"];
            if (vecUciteljevVRazredu.count > 0) {
                for (int i = 0; i < vecUciteljevVRazredu.count; i++) {
                    NSDictionary *suplenceElement = vecUciteljevVRazredu[i];
                    for (int j = 0; j < urnikData.count; j++) {
                        NSMutableDictionary *urnikElement = urnikData[j];
                        if ([urnikElement[@"ura"] isEqualToString:suplenceElement[@"ura"]]) {
                            NSMutableArray *profesorji = urnikElement[@"profesorji"];
                            [profesorji addObject:suplenceElement[@"ucitelj"]];
                            urnikElement[@"profesorji"] = profesorji;
                            urnikData[j] = urnikElement;
                            (urnikData[j])[@"spremenjeno"] = @YES;
                            (urnikData[j])[@"opomba"] = suplenceElement[@"opomba"];
                        }
                    }
                }
            }
            
            for (int i = 0; i < urnikData.count; i++) {
                NSNumber *boolean = (urnikData[i])[@"spremenjeno"];
                if (!boolean) {
                    (urnikData[i])[@"spremenjeno"] = @NO;
                    (urnikData[i])[@"opomba"] = @"";
                }
            }
            
            [urnikData writeToFile:[NSString stringWithFormat:@"%@/hybrid-%d", documentsPath, f] atomically:YES];
        } @catch (NSException *exception) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/filteredUrnik-%d", documentsPath, f + 1] error:nil];
        }
    }
    
    
    [[VDDMetaData sharedMetaData] changeMetaDataAtributeWithKey:@"lastUpdatedHybrid" toObject:[NSDate date]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"VDDHybridFetchComplete" object:nil];
    
    _isRefreshing = NO;
    return;
}

- (int)indexOfProfesorNameFromSuplence:(NSString *)profesorName inUrnik:(NSArray *)profesorji {
    profesorName = [profesorName stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString;
    for (int i = 0; i < profesorji.count; i++) {
        NSString *profesorjiElement = [profesorji[i] stringByReplacingOccurrencesOfString:@" " withString:@""].lowercaseString;
        if ([profesorName containsString:profesorjiElement])
            return i;
        
        NSString *firstLetter = [profesorjiElement substringToIndex:1];
        NSString *other = [profesorjiElement substringWithRange:NSMakeRange(1, profesorjiElement.length - 1)];
        NSString *filter1 = [NSString stringWithFormat:@"%@%@", other, firstLetter];
        if ([profesorName containsString:filter1])
            return i;
        
        NSString *lastLetter = [profesorjiElement substringFromIndex:profesorjiElement.length - 1];
        other = [profesorjiElement substringToIndex:profesorjiElement.length - 1];
        filter1 = [NSString stringWithFormat:@"%@%@", lastLetter, other];
        if ([profesorName containsString:filter1]) {
            return i;
        }
    }
    
    return -1;
}

@end