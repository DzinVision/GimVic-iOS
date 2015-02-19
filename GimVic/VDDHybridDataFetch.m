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
            
            
            NSArray *menjavaPredmeta = [suplenceData objectForKey:@"menjavaPredmeta"];
            if (menjavaPredmeta.count > 0) {
                for (int i = 0; i < menjavaPredmeta.count; i++) {
                    NSDictionary *suplenceElement = menjavaPredmeta[i];
                    for (int j = 0; j < urnikData.count; j++) {
                        NSMutableDictionary *urnikElement = urnikData[j];
                        if ([[urnikElement objectForKey:@"ura"] isEqualToString:[suplenceElement objectForKey:@"ura"]]) {
                            NSMutableArray *predmeti = [urnikElement objectForKey:@"predmeti"];
                            int index = (int)[predmeti indexOfObject:[suplenceElement objectForKey:@"originalPredmet"]];
                            predmeti[index] = [suplenceElement objectForKey:@"newPredmet"];
                            [urnikElement setObject:predmeti forKey:@"predmeti"];
                            urnikData[j] = urnikElement;
                            [urnikData[j] setObject:[NSNumber numberWithBool:YES] forKey:@"spremenjeno"];
                            [urnikData[j] setObject:[suplenceElement objectForKey:@"opomba"] forKey:@"opomba"];
                        }
                    }
                }
            }
            
            
            NSArray *menjavaUcilnic = [suplenceData objectForKey:@"menjavaUcilnic"];
            if (menjavaUcilnic.count > 0) {
                for (int i = 0; i < menjavaUcilnic.count; i++) {
                    NSDictionary *suplenceElement = menjavaUcilnic[i];
                    for (int j = 0; j < urnikData.count; j++) {
                        NSMutableDictionary *urnikElement = urnikData[j];
                        if ([[urnikElement objectForKey:@"ura"] isEqualToString:[suplenceElement objectForKey:@"ura"]]) {
                            NSMutableArray *ucilnice = [urnikElement objectForKey:@"ucilnice"];
                            NSString *suplenceUcilniceString = [suplenceElement objectForKey:@"ucilnicaFrom"];
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
                                    ucilnice[index] = [suplenceElement objectForKey:@"ucilnicaTo"];
                                }
                            } else ucilnice = [suplenceUcilnice mutableCopy];
                            [urnikElement setObject:ucilnice forKey:@"ucilnice"];
                            urnikData[j] = urnikElement;
                            [urnikData[j] setObject:[NSNumber numberWithBool:YES] forKey:@"spremenjeno"];
                            [urnikData[j] setObject:[suplenceElement objectForKey:@"opomba"] forKey:@"opomba"];
                        }
                    }
                }
            }
            
            NSArray *menjavaUr = [suplenceData objectForKey:@"menjavaUr"];
            if (menjavaUr.count > 0) {
                for (int i = 0; i < menjavaUr.count; i++) {
                    NSDictionary *suplenceElement = menjavaUr[i];
                    for (int j = 0; j < urnikData.count; j++) {
                        NSMutableDictionary *urnikElement = urnikData[j];
                        if ([[urnikElement objectForKey:@"ura"] isEqualToString:[suplenceElement objectForKey:@"ura"]]) {
                            NSMutableArray *predmeti = [urnikElement objectForKey:@"predmeti"];
                            int index = (int)[predmeti indexOfObject:[suplenceElement objectForKey:@"predmetFrom"]];
                            NSLog(@"%@", predmeti);
                            NSLog(@"%@", suplenceElement);
                            predmeti[index] = [suplenceElement objectForKey:@"predmetTo"];
                            [urnikElement setObject:predmeti forKey:@"predmeti"];
                            
                            NSMutableArray *profesorji = [urnikElement objectForKey:@"profesorji"];
                            index = [self indexOfProfesorNameFromSuplence:[suplenceElement objectForKey:@"uciteljFrom"] inUrnik:profesorji];
                            if (index > -1)
                                profesorji[index] = [suplenceElement objectForKey:@"uciteljTo"];
                            else
                                [profesorji addObject:[suplenceElement objectForKey:@"uciteljTo"]];
                            [urnikElement setObject:profesorji forKey:@"profesorji"];
                            urnikData[j] = urnikElement;
                            [urnikData[j] setObject:[NSNumber numberWithBool:YES] forKey:@"spremenjeno"];
                            [urnikData[j] setObject:[suplenceElement objectForKey:@"opomba"] forKey:@"opomba"];
                        }
                    }
                }
            }
            
            NSArray *nadomescanja = [suplenceData objectForKey:@"nadomescanja"];
            if (nadomescanja.count > 0) {
                for (int i = 0; i < nadomescanja.count; i++) {
                    NSDictionary *suplenceElement = nadomescanja[i];
                    for (int j = 0; j < urnikData.count; j++) {
                        NSMutableDictionary *urnikElement = urnikData[j];
                        if ([[urnikElement objectForKey:@"ura"] isEqualToString:[suplenceElement objectForKey:@"ura"]]) {
                            NSMutableArray *profesorji = [urnikElement objectForKey:@"profesorji"];
                            NSMutableArray *predmeti = [urnikElement objectForKey:@"predmeti"];
                            NSMutableArray *ucilnice = [urnikElement objectForKey:@"ucilnice"];
                            int index = [self indexOfProfesorNameFromSuplence:[suplenceElement objectForKey:@"odsoten"] inUrnik:profesorji];
                            if (index > -1) {
                                if (profesorji.count > index)
                                    profesorji[index] = [suplenceElement objectForKey:@"nadomesca"];
                                else
                                    [profesorji addObject:[suplenceElement objectForKey:@"nadomesca"]];
                                
                                if (predmeti.count > index)
                                    predmeti[index] = [suplenceElement objectForKey:@"predmet"];
                                else
                                    [predmeti addObject:[suplenceElement objectForKey:@"predmet"]];
                                
                                if (ucilnice.count > index)
                                    ucilnice[index] = [suplenceElement objectForKey:@"ucilnica"];
                                else
                                    [ucilnice addObject:[suplenceElement objectForKey:@"ucilnica"]];
                            } else {
                                [profesorji addObject:[suplenceElement objectForKey:@"nadomesca"]];
                                [predmeti addObject:[suplenceElement objectForKey:@"predmet"]];
                                [ucilnice addObject:[suplenceElement objectForKey:@"ucilnica"]];
                            }
                            [urnikElement setObject:profesorji forKey:@"profesorji"];
                            [urnikElement setObject:predmeti forKey:@"predmeti"];
                            [urnikElement setObject:ucilnice forKey:@"ucilnice"];
                            urnikData[j] = urnikElement;
                            [urnikData[j] setObject:[NSNumber numberWithBool:YES] forKey:@"spremenjeno"];
                            [urnikData[j] setObject:[suplenceElement objectForKey:@"opomba"] forKey:@"opomba"];
                        }
                    }
                }
            }
            
            NSArray *vecUciteljevVRazredu = [suplenceData objectForKey:@"vecUciteljevVRazredu"];
            if (vecUciteljevVRazredu.count > 0) {
                for (int i = 0; i < vecUciteljevVRazredu.count; i++) {
                    NSDictionary *suplenceElement = vecUciteljevVRazredu[i];
                    for (int j = 0; j < urnikData.count; j++) {
                        NSMutableDictionary *urnikElement = urnikData[j];
                        if ([[urnikElement objectForKey:@"ura"] isEqualToString:[suplenceElement objectForKey:@"ura"]]) {
                            NSMutableArray *profesorji = [urnikElement objectForKey:@"profesorji"];
                            [profesorji addObject:[suplenceElement objectForKey:@"ucitelj"]];
                            [urnikElement setObject:profesorji forKey:@"profesorji"];
                            urnikData[j] = urnikElement;
                            [urnikData[j] setObject:[NSNumber numberWithBool:YES] forKey:@"spremenjeno"];
                            [urnikData[j] setObject:[suplenceElement objectForKey:@"opomba"] forKey:@"opomba"];
                        }
                    }
                }
            }
            
            for (int i = 0; i < urnikData.count; i++) {
                NSNumber *boolean = [urnikData[i] objectForKey:@"spremenjeno"];
                if (!boolean) {
                    [urnikData[i] setObject:[NSNumber numberWithBool:NO] forKey:@"spremenjeno"];
                    [urnikData[i] setObject:@"" forKey:@"opomba"];
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