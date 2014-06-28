//
//  DZNRefresh.m
//  GimVic
//
//  Created by Vid Drobnič on 13/05/14.
//  Copyright (c) 2014 Vid Drobnic. All rights reserved.
//

#import "DZNRefresh.h"
#import "XMLReader.h"

@interface DZNRefresh ()

@end


@implementation DZNRefresh

-(void)downloadNewContent
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    
    NSDateFormatter *dFormatter = [[NSDateFormatter alloc] init];
    dFormatter.dateFormat = @"yyyy-MM-dd";
    
    NSString *date0 = [dFormatter stringFromDate:[NSDate date]];
    NSString *date1 = [dFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:24*3600]];
    NSString *date2 = [dFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:24*3600*2]];
    
    NSURL *url0 = [NSURL URLWithString:[NSString stringWithFormat:@"http://app.gimvic.org/f5f5d4903e9686b21f49cd417d24779001b432a5/index.php?datum=%@", date0]];
    NSURL *url1 = [NSURL URLWithString:[NSString stringWithFormat:@"http://app.gimvic.org/f5f5d4903e9686b21f49cd417d24779001b432a5/index.php?datum=%@", date1]];
    NSURL *url2 = [NSURL URLWithString:[NSString stringWithFormat:@"http://app.gimvic.org/f5f5d4903e9686b21f49cd417d24779001b432a5/index.php?datum=%@", date2]];
    
    
    NSString *data0 = [[NSString alloc] initWithContentsOfURL:url0 encoding:NSUTF8StringEncoding error:nil];
    data0 = [data0 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    data0 = [data0 stringByReplacingOccurrencesOfString:@"  " withString:@""];
    
    NSString *data1 = [[NSString alloc] initWithContentsOfURL:url1 encoding:NSUTF8StringEncoding error:nil];
    data1 = [data1 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    data1 = [data1 stringByReplacingOccurrencesOfString:@"  " withString:@""];
    
    NSString *data2 = [[NSString alloc] initWithContentsOfURL:url2 encoding:NSUTF8StringEncoding error:nil];
    data2 = [data2 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    data2 = [data2 stringByReplacingOccurrencesOfString:@"  " withString:@""];
    
    
    NSError *parseError = nil;
    
    NSDictionary *download0 = [XMLReader dictionaryForXMLString:data0 error:&parseError];
    download0 = [download0 valueForKey:@"root-element-here"];
    download0 = [self cleanDictionary:download0];
    
    NSDictionary *download1 = [XMLReader dictionaryForXMLString:data1 error:&parseError];
    download1 = [download1 valueForKey:@"root-element-here"];
    download1 = [self cleanDictionary:download1];
    
    NSDictionary *download2 = [XMLReader dictionaryForXMLString:data2 error:&parseError];
    download2 = [download2 valueForKey:@"root-element-here"];
    download2 = [self cleanDictionary:download2];
    
    
    [download0 writeToFile:[NSString stringWithFormat:@"%@/unorganised-%@", documentsPath, date0] atomically:YES];
    [download1 writeToFile:[NSString stringWithFormat:@"%@/unorganised-%@", documentsPath, date1] atomically:YES];
    [download2 writeToFile:[NSString stringWithFormat:@"%@/unorganised-%@", documentsPath, date2] atomically:YES];
    
    [self sortContent];
}

-(void)sortContent
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSDateFormatter *dFormatter = [[NSDateFormatter alloc] init];
    dFormatter.dateFormat = @"yyyy-MM-dd";
    
    NSString *date0 = [dFormatter stringFromDate:[NSDate date]];
    NSString *date1 = [dFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:24*3600]];
    NSString *date2 = [dFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:24*3600*2]];
    
    NSString *filter = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/filter", documentsPath]
                                                 encoding:NSUTF8StringEncoding
                                                    error:nil];
    filter = [filter stringByReplacingOccurrencesOfString:@" " withString:@""];
    filter = [filter lowercaseString];
    
    
    NSDictionary *dict0 = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/unorganised-%@", documentsPath, date0]];
    NSDictionary *dict1 = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/unorganised-%@", documentsPath, date1]];
    NSDictionary *dict2 = [[NSDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/unorganised-%@", documentsPath, date2]];
    
    if (filter != nil) {
        if (![filter isEqualToString:@""]) {
            dict0 = [self filterDictionary:dict0 withFilter:filter];
            dict1 = [self filterDictionary:dict1 withFilter:filter];
            dict2 = [self filterDictionary:dict2 withFilter:filter];
        }
    }
    

    [dict0 writeToFile:[NSString stringWithFormat:@"%@/organised-%@", documentsPath, date0] atomically:YES];
    [dict1 writeToFile:[NSString stringWithFormat:@"%@/organised-%@", documentsPath, date1] atomically:YES];
    [dict2 writeToFile:[NSString stringWithFormat:@"%@/organised-%@", documentsPath, date2] atomically:YES];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DZNRefreshComplete" object:nil];
    
    if (![NSThread isMainThread]) {
        [NSThread exit];
    }
}

-(NSDictionary *)filterDictionary:(NSDictionary *)dict
                       withFilter:(NSString *)filter
{
    NSMutableDictionary *resultDictionary = [[NSMutableDictionary alloc] init];
    
    NSArray *rootDictionaryKeys = [dict allKeys];
    for (NSString *key in rootDictionaryKeys) {
        NSArray *item = [dict valueForKey:key];
        NSMutableArray *resultArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary *subDictionary in item) {
            NSArray *subDictionaryKeys = [subDictionary allKeys];
            
            for (NSString *subKey in subDictionaryKeys) {
                if ([[[[subDictionary valueForKey:subKey] stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString] rangeOfString:filter].location != NSNotFound) {
                    [resultArray addObject:subDictionary];
                    break;
                }
            }
            [resultDictionary setObject:resultArray forKey:key];
        }
    }
    
    return resultDictionary;
}

-(NSDictionary *)cleanDictionary:(NSDictionary *)rootDic
{
    //Sort nadomescanja
    NSMutableArray *nadomescanjaFinal = [[NSMutableArray alloc] init];
    
    NSString *razred;
    NSString *nadomesca;
    NSString *opomba;
    NSString *predmet;
    NSString *ucilnica;
    NSString *ura;
    NSString *odsoten;
    
    if ([[rootDic valueForKey:@"nadomescanja"] isKindOfClass:[NSArray class]]) {
        NSArray *nadomescanja = [rootDic valueForKey:@"nadomescanja"];
        
        for (int i = 0; i < [nadomescanja count]; i++) {
            NSDictionary *item = nadomescanja[i];

            odsoten = [[item valueForKey:@"odsoten_fullname"] valueForKey:@"text"];
            if (odsoten == nil) {
                odsoten = @"";
            }
            
            if ([[item valueForKey:@"nadomescanja_ure"] isKindOfClass:[NSArray class]]) {
                NSArray *nadomescanjaUre = [item valueForKey:@"nadomescanja_ure"];
                
                for (int j = 0; j < [nadomescanjaUre count]; j++) {
                    NSDictionary *nadomescanjaItem = nadomescanjaUre[j];
                    
                    razred = [[nadomescanjaItem valueForKey:@"class_name"] valueForKey:@"text"];
                    if (razred == nil) {
                        razred = @"";
                    }
                    
                    nadomesca = [[nadomescanjaItem valueForKey:@"nadomesca_full_name"] valueForKey:@"text"];
                    if (nadomesca == nil) {
                        nadomesca = @"";
                    }
                    
                    opomba = [[nadomescanjaItem valueForKey:@"opomba"] valueForKey:@"text"];
                    if (opomba == nil) {
                        opomba = @"";
                    }
                    
                    predmet = [[nadomescanjaItem valueForKey:@"predmet"] valueForKey:@"text"];
                    if (predmet == nil) {
                        predmet = @"";
                    }
                    
                    ucilnica = [[nadomescanjaItem valueForKey:@"ucilnica"] valueForKey:@"text"];
                    if (ucilnica == nil) {
                        ucilnica = @"";
                    }
                    
                    ura = [[nadomescanjaItem valueForKey:@"ura"] valueForKey:@"text"];
                    if (ura == nil) {
                        ura = @"";
                    }
                    
                    NSDictionary *nadomescanjaResult = @{@"odsoten": odsoten,
                                                         @"razred": razred,
                                                         @"nadomesca": nadomesca,
                                                         @"opomba": opomba,
                                                         @"predmet": predmet,
                                                         @"ucilnica": ucilnica,
                                                         @"ura": ura};
                    [nadomescanjaFinal addObject:nadomescanjaResult];
                }
            }
            else {
                NSDictionary *nadomescanjaItem = [item valueForKey:@"nadomescanja_ure"];
                
                razred = [[nadomescanjaItem valueForKey:@"class_name"] valueForKey:@"text"];
                if (razred == nil) {
                    razred = @"";
                }
                
                nadomesca = [[nadomescanjaItem valueForKey:@"nadomesca_full_name"] valueForKey:@"text"];
                if (nadomesca == nil) {
                    nadomesca = @"";
                }
                
                opomba = [[nadomescanjaItem valueForKey:@"opomba"] valueForKey:@"text"];
                if (opomba == nil) {
                    opomba = @"";
                }
                
                predmet = [[nadomescanjaItem valueForKey:@"predmet"] valueForKey:@"text"];
                if (predmet == nil) {
                    predmet = @"";
                }
                
                ucilnica = [[nadomescanjaItem valueForKey:@"ucilnica"] valueForKey:@"text"];
                if (ucilnica == nil) {
                    ucilnica = @"";
                }
                
                ura = [[nadomescanjaItem valueForKey:@"ura"] valueForKey:@"text"];
                if (ura == nil) {
                    ura = @"";
                }
                
                NSDictionary *nadomescanjaResult = @{@"odsoten": odsoten,
                                                     @"razred": razred,
                                                     @"nadomesca": nadomesca,
                                                     @"opomba": opomba,
                                                     @"predmet": predmet,
                                                     @"ucilnica": ucilnica,
                                                     @"ura": ura};
                [nadomescanjaFinal addObject:nadomescanjaResult];
            }
        }
    }
    else if ([[rootDic valueForKey:@"nadomescanja"] count] != 0){
        NSDictionary *nadomescanja = [rootDic valueForKey:@"nadomescanja"];
        
        NSString *odsoten = [[NSString alloc] initWithString:[[nadomescanja valueForKey:@"odsoten_fullname"] valueForKey:@"text"]];
        
        if ([[nadomescanja valueForKey:@"nadomescanja_ure"] isKindOfClass:[NSArray class]]) {
            NSArray *nadomescanjaUre = [nadomescanja valueForKey:@"nadomescanja_ure"];
            
            for (int i = 0; i < [nadomescanjaUre count]; i++) {
                NSDictionary *nadomescanjaItem = nadomescanjaUre[i];
                razred = [[nadomescanjaItem valueForKey:@"class_name"] valueForKey:@"text"];
                if (razred == nil) {
                    razred = @"";
                }
                
                nadomesca = [[nadomescanjaItem valueForKey:@"nadomesca_full_name"] valueForKey:@"text"];
                if (nadomesca == nil) {
                    nadomesca = @"";
                }
                
                opomba = [[nadomescanjaItem valueForKey:@"opomba"] valueForKey:@"text"];
                if (opomba == nil) {
                    opomba = @"";
                }
                
                predmet = [[nadomescanjaItem valueForKey:@"predmet"] valueForKey:@"text"];
                if (predmet == nil) {
                    predmet = @"";
                }
                
                ucilnica = [[nadomescanjaItem valueForKey:@"ucilnica"] valueForKey:@"text"];
                if (ucilnica == nil) {
                    ucilnica = @"";
                }
                
                ura = [[nadomescanjaItem valueForKey:@"ura"] valueForKey:@"text"];
                if (ura == nil) {
                    ura = @"";
                }
                
                NSDictionary *nadomescanjaResult = @{@"odsoten": odsoten,
                                                     @"razred": razred,
                                                     @"nadomesca": nadomesca,
                                                     @"opomba": opomba,
                                                     @"predmet": predmet,
                                                     @"ucilnica": ucilnica,
                                                     @"ura": ura};
                [nadomescanjaFinal addObject:nadomescanjaResult];
            }
        }
        else {
            NSDictionary *nadomescanjaItem = [nadomescanja valueForKey:@"nadomescanja_ure"];
            
            razred = [[nadomescanjaItem valueForKey:@"class_name"] valueForKey:@"text"];
            if (razred == nil) {
                razred = @"";
            }
            
            nadomesca = [[nadomescanjaItem valueForKey:@"nadomesca_full_name"] valueForKey:@"text"];
            if (nadomesca == nil) {
                nadomesca = @"";
            }
            
            opomba = [[nadomescanjaItem valueForKey:@"opomba"] valueForKey:@"text"];
            if (opomba == nil) {
                opomba = @"";
            }
            
            predmet = [[nadomescanjaItem valueForKey:@"predmet"] valueForKey:@"text"];
            if (predmet == nil) {
                predmet = @"";
            }
            
            ucilnica = [[nadomescanjaItem valueForKey:@"ucilnica"] valueForKey:@"text"];
            if (ucilnica == nil) {
                ucilnica = @"";
            }
            
            ura = [[nadomescanjaItem valueForKey:@"ura"] valueForKey:@"text"];
            if (ura == nil) {
                ura = @"";
            }
            
            NSDictionary *nadomescanjaResult = @{@"odsoten": odsoten,
                                                 @"razred": razred,
                                                 @"nadomesca": nadomesca,
                                                 @"opomba": opomba,
                                                 @"predmet": predmet,
                                                 @"ucilnica": ucilnica,
                                                 @"ura": ura};
            [nadomescanjaFinal addObject:nadomescanjaResult];
        }
    }
    
    
    //Menjava predmeta
    NSString *ucitelj;
    NSString *originalPredmet;
    NSString *newPredmet;
    
    NSMutableArray *menjavaPredmetaFinal = [[NSMutableArray alloc] init];
    
    if ([[rootDic valueForKey:@"menjava_predmeta"] isKindOfClass:[NSArray class]]) {
        NSArray *menjavaPredmeta = [rootDic valueForKey:@"menjava_predmeta"];
        
        for (int i = 0; i < [menjavaPredmeta count]; i++) {
            NSDictionary *item = menjavaPredmeta[i];
            
            ura = [[item valueForKey:@"ura"] valueForKey:@"text"];
            if (ura == nil) {
                ura = @"";
            }
            
            razred = [[item valueForKey:@"class_name"] valueForKey:@"text"];
            if (razred == nil) {
                razred = @"";
            }
            
            ucilnica = [[item valueForKey:@"ucilnica"] valueForKey:@"text"];
            if (ucilnica == nil) {
                ucilnica = @"";
            }
            
            ucitelj = [[item valueForKey:@"ucitelj"] valueForKey:@"text"];
            if (ucitelj == nil) {
                ucitelj = @"";
            }
            
            originalPredmet = [[item valueForKey:@"original_predmet"] valueForKey:@"text"];
            if (originalPredmet == nil) {
                originalPredmet = @"";
            }
            
            newPredmet = [[item valueForKey:@"predmet"] valueForKey:@"text"];
            if (newPredmet == nil) {
                newPredmet = @"";
            }
            
            opomba = [[item valueForKey:@"opomba"] valueForKey:@"text"];
            if (opomba == nil) {
                opomba = @"";
            }
            
            NSDictionary *menjavaPredmetaResult = @{@"ura": ura,
                                                    @"razred": razred,
                                                    @"ucilnica": ucilnica,
                                                    @"ucitelj": ucitelj,
                                                    @"originalPredmet": originalPredmet,
                                                    @"newPredmet": newPredmet,
                                                    @"opomba": opomba};
            [menjavaPredmetaFinal addObject:menjavaPredmetaResult];
        }
    }
    else if ([[rootDic valueForKey:@"menjava_predmeta"] count] != 0){
        NSDictionary *item = [rootDic valueForKey:@"menjava_predmeta"];
        
        ura = [[item valueForKey:@"ura"] valueForKey:@"text"];
        if (ura == nil) {
            ura = @"";
        }
        
        razred = [[item valueForKey:@"class_name"] valueForKey:@"text"];
        if (razred == nil) {
            razred = @"";
        }
        
        ucilnica = [[item valueForKey:@"ucilnica"] valueForKey:@"text"];
        if (ucilnica == nil) {
            ucilnica = @"";
        }
        
        ucitelj = [[item valueForKey:@"ucitelj"] valueForKey:@"text"];
        if (ucitelj == nil) {
            ucitelj = @"";
        }
        
        originalPredmet = [[item valueForKey:@"original_predmet"] valueForKey:@"text"];
        if (originalPredmet == nil) {
            originalPredmet = @"";
        }
        
        newPredmet = [[item valueForKey:@"predmet"] valueForKey:@"text"];
        if (newPredmet == nil) {
            newPredmet = @"";
        }
        
        opomba = [[item valueForKey:@"opomba"] valueForKey:@"text"];
        if (opomba == nil) {
            opomba = @"";
        }
        
        NSDictionary *menjavaPredmetaResult = @{@"ura": ura,
                                                @"razred": razred,
                                                @"ucilnica": ucilnica,
                                                @"ucitelj": ucitelj,
                                                @"originalPredmet": originalPredmet,
                                                @"newPredmet": newPredmet,
                                                @"opomba": opomba};
        [menjavaPredmetaFinal addObject:menjavaPredmetaResult];
    }
    
    
    //Menjava ur
    NSString *zamenjavaUciteljev;
    
    NSMutableArray *menjavaUrFinal = [[NSMutableArray alloc] init];
    
    if ([[rootDic valueForKey:@"menjava_ur"] isKindOfClass:[NSArray class]]) {
        NSArray *menjavaUr = [rootDic valueForKey:@"menjava_ur"];
        
        for (int i = 0; i < [menjavaUr count]; i++) {
            NSDictionary *item = menjavaUr[i];
            
            ura = [[item valueForKey:@"ura"] valueForKey:@"text"];
            if (ura == nil) {
                ura = @"";
            }
            
            razred = [[item valueForKey:@"class_name"] valueForKey:@"text"];
            if (razred == nil) {
                razred = @"";
            }
            
            ucilnica = [[item valueForKey:@"ucilnica"] valueForKey:@"text"];
            if (ucilnica == nil) {
                ucilnica = @"";
            }
            
            opomba = [[item valueForKey:@"opomba"] valueForKey:@"text"];
            if (opomba == nil) {
                opomba = @"";
            }
            
            predmet = [[item valueForKey:@"predmet"] valueForKey:@"text"];
            if (predmet == nil) {
                predmet = @"";
            }
            
            zamenjavaUciteljev = [[item valueForKey:@"zamenjava_uciteljev"] valueForKey:@"text"];
            if (zamenjavaUciteljev == nil) {
                zamenjavaUciteljev = @"";
            }
            
            NSDictionary *menjavaUrResult = @{@"razred": razred,
                                              @"opomba": opomba,
                                              @"predmet": predmet,
                                              @"ucilnica": ucilnica,
                                              @"ura": ura,
                                              @"zamenjavaProf": zamenjavaUciteljev};
            [menjavaUrFinal addObject:menjavaUrResult];
        }
    }
    else if ([[rootDic valueForKey:@"menjava_ur"] count] != 0) {
        NSDictionary *item = [rootDic valueForKey:@"menjava_ur"];
        
        ura = [[item valueForKey:@"ura"] valueForKey:@"text"];
        if (ura == nil) {
            ura = @"";
        }
        
        razred = [[item valueForKey:@"class_name"] valueForKey:@"text"];
        if (razred == nil) {
            razred = @"";
        }
        
        ucilnica = [[item valueForKey:@"ucilnica"] valueForKey:@"text"];
        if (ucilnica == nil) {
            ucilnica = @"";
        }
        
        opomba = [[item valueForKey:@"opomba"] valueForKey:@"text"];
        if (opomba == nil) {
            opomba = @"";
        }
        
        predmet = [[item valueForKey:@"predmet"] valueForKey:@"text"];
        if (predmet == nil) {
            predmet = @"";
        }
        
        zamenjavaUciteljev = [[item valueForKey:@"zamenjava_uciteljev"] valueForKey:@"text"];
        if (zamenjavaUciteljev == nil) {
            zamenjavaUciteljev = @"";
        }
        
        NSDictionary *menjavaUrResult = @{@"razred": razred,
                                          @"opomba": opomba,
                                          @"predmet": predmet,
                                          @"ucilnica": ucilnica,
                                          @"ura": ura,
                                          @"zamenjavaProf": zamenjavaUciteljev};
        [menjavaUrFinal addObject:menjavaUrResult];
    }
    
    //Menjava Ucilnic
    NSMutableArray *menjavaUcilnicFinal = [[NSMutableArray alloc] init];
    
    NSString *ucilnicaFrom;
    NSString *ucilnicaTo;
    
    if ([[rootDic valueForKey:@"menjava_ucilnic"] isKindOfClass:[NSArray class]]) {
        NSArray *menjavaUcilnic = [rootDic valueForKey:@"menjava_ucilnic"];
        
        for (int i = 0; i < [menjavaUcilnic count]; i++) {
            NSDictionary *item = menjavaUcilnic[i];
            
            ura = [[item valueForKey:@"ura"] valueForKey:@"text"];
            if (ura == nil) {
                ura = @"";
            }
            
            razred = [[item valueForKey:@"class_name"] valueForKey:@"text"];
            if (razred == nil) {
                razred = @"";
            }
            
            opomba = [[item valueForKey:@"opomba"] valueForKey:@"text"];
            if (opomba == nil) {
                opomba = @"";
            }
            
            predmet = [[item valueForKey:@"predmet"] valueForKey:@"text"];
            if (predmet == nil) {
                predmet = @"";
            }
            
            ucitelj = [[item valueForKey:@"ucitelj"] valueForKey:@"text"];
            if (ucitelj == nil) {
                ucitelj = @"";
            }
            
            ucilnicaFrom = [[item valueForKey:@"ucilnica_from"] valueForKey:@"text"];
            if (ucilnicaFrom == nil) {
                ucilnicaFrom = @"";
            }
            
            ucilnicaTo = [[item valueForKey:@"ucilnica_to"] valueForKey:@"text"];
            if (ucilnicaTo == nil) {
                ucilnicaTo = @"";
            }
            
            NSDictionary *menjavaUcilnicResult = @{@"razred": razred,
                                                   @"opomba": opomba,
                                                   @"predmet": predmet,
                                                   @"ucilnicaFrom": ucilnicaFrom,
                                                   @"ucilnicaTo": ucilnicaTo,
                                                   @"ucitelj": ucitelj,
                                                   @"ura": ura};
            [menjavaUcilnicFinal addObject:menjavaUcilnicResult];
        }
    }
    else if ([[rootDic valueForKey:@"menjava_ucilnic"] count] != 0) {
        NSDictionary *item = [rootDic valueForKey:@"menjava_ucilnic"];
        
        ura = [[item valueForKey:@"ura"] valueForKey:@"text"];
        if (ura == nil) {
            ura = @"";
        }
        
        razred = [[item valueForKey:@"class_name"] valueForKey:@"text"];
        if (razred == nil) {
            razred = @"";
        }
        
        opomba = [[item valueForKey:@"opomba"] valueForKey:@"text"];
        if (opomba == nil) {
            opomba = @"";
        }
        
        predmet = [[item valueForKey:@"predmet"] valueForKey:@"text"];
        if (predmet == nil) {
            predmet = @"";
        }
        
        ucitelj = [[item valueForKey:@"ucitelj"] valueForKey:@"text"];
        if (ucitelj == nil) {
            ucitelj = @"";
        }
        
        ucilnicaFrom = [[item valueForKey:@"ucilnica_from"] valueForKey:@"text"];
        if (ucilnicaFrom == nil) {
            ucilnicaFrom = @"";
        }
        
        ucilnicaTo = [[item valueForKey:@"ucilnica_to"] valueForKey:@"text"];
        if (ucilnicaTo == nil) {
            ucilnicaTo = @"";
        }
        
        NSDictionary *menjavaUcilnicResult = @{@"razred": razred,
                                               @"opomba": opomba,
                                               @"predmet": predmet,
                                               @"ucilnicaFrom": ucilnicaFrom,
                                               @"ucilnicaTo": ucilnicaTo,
                                               @"ucitelj": ucitelj,
                                               @"ura": ura};
        [menjavaUcilnicFinal addObject:menjavaUcilnicResult];
    }
    
    
    //Rezervacija Ucilnic
    
    NSMutableArray *rezervacijaUcilnicFinal = [[NSMutableArray alloc] init];
    
    NSString *rezervator;
    
    if ([[rootDic valueForKey:@"rezerviranje_ucilnice"] isKindOfClass:[NSArray class]]) {
        NSArray *rezervacijaUcilnic = [rootDic valueForKey:@"rezerviranje_ucilnice"];
        
        for (int i = 0; i < [rezervacijaUcilnic count]; i++) {
            NSDictionary *item = rezervacijaUcilnic[i];
            
            ura = [[item valueForKey:@"ura"] valueForKey:@"text"];
            if (ura == nil) {
                ura = @"";
            }
            
            ucilnica = [[item valueForKey:@"ucilnica"] valueForKey:@"text"];
            if (ucilnica == nil) {
                ucilnica = @"";
            }
            
            rezervator = [[item valueForKey:@"rezervator"] valueForKey:@"text"];
            if (rezervator == nil) {
                rezervator = @"";
            }
            
            opomba = [[item valueForKey:@"opomba"] valueForKey:@"text"];
            if (opomba == nil) {
                opomba = @"";
            }
            
            NSDictionary *rezervacijaUcilnicResult = @{@"ura": ura,
                                                       @"ucilnica": ucilnica,
                                                       @"rezervator": rezervator,
                                                       @"opomba": opomba};
            [rezervacijaUcilnicFinal addObject:rezervacijaUcilnicResult];
        }
    }
    else if ([[rootDic valueForKey:@"rezerviranje_ucilnice"] count] != 0) {
        NSDictionary *item = [rootDic valueForKey:@"rezerviranje_ucilnice"];
        
        ura = [[item valueForKey:@"ura"] valueForKey:@"text"];
        if (ura == nil) {
            ura = @"";
        }
        
        ucilnica = [[item valueForKey:@"ucilnica"] valueForKey:@"text"];
        if (ucilnica == nil) {
            ucilnica = @"";
        }
        
        rezervator = [[item valueForKey:@"rezervator"] valueForKey:@"text"];
        if (rezervator == nil) {
            rezervator = @"";
        }
        
        opomba = [[item valueForKey:@"opomba"] valueForKey:@"text"];
        if (opomba == nil) {
            opomba = @"";
        }
        
        NSDictionary *rezervacijaUcilnicResult = @{@"ura": ura,
                                                   @"ucilnica": ucilnica,
                                                   @"rezervator": rezervator,
                                                   @"opomba": opomba};
        [rezervacijaUcilnicFinal addObject:rezervacijaUcilnicResult];
    }
    
    
    //Vec uciteljev v razredu
    NSMutableArray *vecUciteljevFinal = [[NSMutableArray alloc] init];
    
    if ([[rootDic valueForKey:@"vec_uciteljev_v_razredu"] isKindOfClass:[NSArray class]]) {
        NSArray *vecUciteljev = [rootDic valueForKey:@"vec_uciteljev_v_razredu"];
        
        for (int i = 0; i < [vecUciteljev count]; i++) {
            NSDictionary *item = vecUciteljev[i];
            ura = [[item valueForKey:@"ura"] valueForKey:@"text"];
            if (ura == nil) {
                ura = @"";
            }
            
            ucitelj = [[item valueForKey:@"ucitelj"] valueForKey:@"text"];
            if (ucitelj == nil) {
                ucitelj = @"";
            }
            
            razred = [[item valueForKey:@"class_name"] valueForKey:@"text"];
            if (razred == nil) {
                razred = @"";
            }
            
            ucilnica = [[item valueForKey:@"ucilnica"] valueForKey:@"text"];
            if (ucilnica == nil) {
                ucilnica = @"";
            }
            
            opomba = [[item valueForKey:@"opomba"] valueForKey:@"text"];
            if (opomba == nil) {
                opomba = @"";
            }
            
            NSDictionary *vecUciteljevResult = @{@"ura": ura,
                                                 @"ucitelj": ucitelj,
                                                 @"razred": razred,
                                                 @"ucilnica": ucilnica,
                                                 @"opomba": opomba};
            [vecUciteljevFinal addObject:vecUciteljevResult];
        }
    }
    else if ([[rootDic valueForKey:@"vec_uciteljev_v_razredu"] count] != 0) {
        NSDictionary *item = [rootDic valueForKey:@"vec_uciteljev_v_razredu"];
        
        ura = [[item valueForKey:@"ura"] valueForKey:@"text"];
        if (ura == nil) {
            ura = @"";
        }
        
        ucitelj = [[item valueForKey:@"ucitelj"] valueForKey:@"text"];
        if (ucitelj == nil) {
            ucitelj = @"";
        }
        
        razred = [[item valueForKey:@"class_name"] valueForKey:@"text"];
        if (razred == nil) {
            razred = @"";
        }
        
        ucilnica = [[item valueForKey:@"ucilnica"] valueForKey:@"text"];
        if (ucilnica == nil) {
            ucilnica = @"";
        }
        
        opomba = [[item valueForKey:@"opomba"] valueForKey:@"text"];
        if (opomba == nil) {
            opomba = @"";
        }
        
        NSDictionary *vecUciteljevResult = @{@"ura": ura,
                                             @"ucitelj": ucitelj,
                                             @"razred": razred,
                                             @"ucilnica": ucilnica,
                                             @"opomba": opomba};
        [vecUciteljevFinal addObject:vecUciteljevResult];
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
