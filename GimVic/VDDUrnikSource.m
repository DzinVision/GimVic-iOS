//
//  VDDUrnikSource.m
//  GimVic
//
//  Created by Vid Drobnič on 11/08/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDUrnikSource.h"
#import "VDDUrnikCell.h"
#import "VDDMetaData.h"

@interface VDDUrnikSource ()
{
    int dayIndex;
    NSArray *data;
    int startIndex;
}
@end


@implementation VDDUrnikSource

#pragma mark - Initialization

- (instancetype)initWithIndex:(int)index data:(NSArray *)urnikData {
    self = [super init];
    if (self) {
        dayIndex = index;
        
        NSMutableArray *privateData = [urnikData mutableCopy];
        BOOL sorted = NO;
        while (!sorted) {
            sorted = YES;
            for (int i = 0; i < privateData.count - 1; i++) {
                NSDictionary *element1 = privateData[i];
                NSDictionary *element2 = privateData[i + 1];
                if ([[element1 objectForKey:@"ura"] intValue] > [[element2 objectForKey:@"ura"] intValue]) {
                    privateData[i] = element2;
                    privateData[i + 1] = element1;
                    sorted = NO;
                    break;
                }
            }
        }
        data = privateData;
        
        
        startIndex = [[data[0] objectForKey:@"ura"] intValue];
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Wrong initializer" reason:@"You should use initWithIndex:data initializer on VDDUrnikSource" userInfo:nil];
}

#pragma mark - Reloading

- (void)reloadData:(NSArray *)newData {
    NSMutableArray *privateData = [newData mutableCopy];
    BOOL sorted = NO;
    while (!sorted) {
        sorted = YES;
        for (int i = 0; i < privateData.count - 1; i++) {
            NSDictionary *element1 = privateData[i];
            NSDictionary *element2 = privateData[i + 1];
            if ([[element1 objectForKey:@"ura"] intValue] > [[element2 objectForKey:@"ura"] intValue]) {
                privateData[i] = element2;
                privateData[i + 1] = element1;
                sorted = NO;
                break;
            }
        }
    }
    data = privateData;
    
    
    startIndex = [[data[0] objectForKey:@"ura"] intValue];
}

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VDDUrnikCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VDDUrnikCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VDDUrnikCell" owner:self options:nil];
        cell = nib[0];
    }
    

    NSDictionary *dataDictionary;
    for (int i = 0; i < data.count; i++) {
        NSDictionary *element = data[i];
        if ([[element objectForKey:@"ura"] intValue] == (indexPath.row + startIndex))
            dataDictionary = element;
    }
    
    NSArray *profesorji = [dataDictionary objectForKey:@"profesorji"];
    NSArray *predmeti = [dataDictionary objectForKey:@"predmeti"];
    NSArray *ucilnice = [dataDictionary objectForKey:@"ucilnice"];
    
    NSString *predmet = predmeti[0];
    NSString *profesor = profesorji[0];
    NSString *ucilnica = ucilnice[0];
    
    if (predmeti.count > 1) {
        for (int i = 1; i < predmeti.count; i++)
            predmet = [predmet stringByAppendingString:[NSString stringWithFormat:@" / %@", predmeti[i]]];
    }
    if (profesorji.count > 1) {
        for (int i = 1; i < profesorji.count; i++)
            profesor = [profesor stringByAppendingString:[NSString stringWithFormat:@" / %@", profesorji[i]]];
    }
    if (ucilnice.count > 1) {
        for (int i = 1; i < ucilnice.count; i++)
            ucilnica = [ucilnica stringByAppendingString:[NSString stringWithFormat:@" / %@", ucilnice[i]]];
    }
    
    
    if ([predmet isEqualToString:@""])
        predmet = [@"-" mutableCopy];
    if ([profesor isEqualToString:@""])
        profesor = [@"-" mutableCopy];
    if ([ucilnica isEqualToString:@""])
        ucilnica = [@"-" mutableCopy];
    
    cell.ura.text = [dataDictionary objectForKey:@"ura"];
    cell.predmet.text = predmet;
    cell.ucilnica.text = ucilnica;
    cell.ucitelj.text = profesor;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}

@end