//
//  VDDHybridSource.m
//  GimVic
//
//  Created by Vid Drobnič on 11/22/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDHybridSource.h"
#import "VDDUrnikCell.h"
#import "VDDOpombaUrnikCell.h"

@interface VDDHybridSource ()
{
    int dayIndex;
    NSArray *data;
    int startIndex;
}
@end


@implementation VDDHybridSource

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
    @throw [NSException exceptionWithName:@"Wrong initializer" reason:@"You should use initWithIndex:data initializer on VDDHybridSource" userInfo:nil];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[data[indexPath.row] objectForKey:@"opomba"] isEqualToString:@""])
        return 85.0;
    return 110.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[data[indexPath.row] objectForKey:@"opomba"] isEqualToString:@""])
        return [self normalCellWithCellData:data[indexPath.row] inTableView:tableView];
    else
        return [self opombaCellWithCellData:data[indexPath.row] inTableView:tableView];
}

#pragma mark - Cell Creation

- (UITableViewCell *)normalCellWithCellData:(NSDictionary *)cellData inTableView:(UITableView *)tableView {
    VDDUrnikCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VDDUrnikCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VDDUrnikCell" owner:self options:nil];
        cell = nib[0];
    }
    
    if ([[cellData objectForKey:@"spremenjeno"] boolValue])
        cell.backgroundColor = [UIColor colorWithRed:200/255.0 green:230/255.0 blue:201/255.0 alpha:1.0];
    else
        cell.backgroundColor = [UIColor whiteColor];
    
    NSArray *profesorji = [cellData objectForKey:@"profesorji"];
    NSArray *predmeti = [cellData objectForKey:@"predmeti"];
    NSArray *ucilnice = [cellData objectForKey:@"ucilnice"];
    
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
        predmet = @"-";
    if ([profesor isEqualToString:@""])
        profesor = @"-";
    if ([ucilnica isEqualToString:@""])
        ucilnica = @"-";
    
    cell.ura.text = [cellData valueForKey:@"ura"];
    cell.predmet.text = predmet;
    cell.ucilnica.text = ucilnica;
    cell.ucitelj.text = profesor;
    
    return cell;
}

- (UITableViewCell *)opombaCellWithCellData:(NSDictionary *)cellData inTableView:(UITableView *)tableView {
    VDDOpombaUrnikCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VDDOpombaUrnikCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VDDOpombaUrnikCell" owner:self options:nil];
        cell = nib[0];
    }
    
    cell.backgroundColor = [UIColor colorWithRed:200/255.0 green:230/255.0 blue:201/255.0 alpha:1.0];
    
    NSArray *profesorji = [cellData objectForKey:@"profesorji"];
    NSArray *predmeti = [cellData objectForKey:@"predmeti"];
    NSArray *ucilnice = [cellData objectForKey:@"ucilnice"];
    
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
        predmet = @"-";
    if ([profesor isEqualToString:@""])
        profesor = @"-";
    if ([ucilnica isEqualToString:@""])
        ucilnica = @"-";
    
    cell.ura.text = [cellData valueForKey:@"ura"];
    cell.predmet.text = predmet;
    cell.ucilnica.text = ucilnica;
    cell.ucitelj.text = profesor;
    cell.opomba.text = [cellData valueForKey:@"opomba"];
    
    return cell;
}

@end