//
//  VDDSuplenceSource.m
//  GimVic
//
//  Created by Vid Drobnič on 09/14/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDSuplenceSource.h"
#import "VDDNadomescanjaCell.h"
#import "VDDMenjavaPredmetaCell.h"
#import "VDDMenjavaUrCell.h"
#import "VDDMenjavaUcilnicCell.h"
#import "VDDRezervacijaUcilnicCell.h"
#import "VDDVecUciteljevCell.h"

@interface VDDSuplenceSource ()
{
    int dayIndex;
    int numberOfSections;
    NSDictionary *data;
}
@end


@implementation VDDSuplenceSource

#pragma mark - Initialization

- (instancetype)initWithIndex:(int)index data:(NSDictionary *)nadomescanjaData numberOfSections:(int)count {
    self = [super init];
    if (self){
        dayIndex = index;
        data = nadomescanjaData;
        numberOfSections = count;
        
        NSArray *keys = [data allKeys];
        
        NSMutableDictionary *cleanDictionary = [[NSMutableDictionary alloc] init];
        
        for (NSString *key in keys) {
            NSArray *array = [data valueForKey:key];
            if (array.count > 0) {
                [cleanDictionary setObject:array forKey:key];
            }
        }
        
        data = cleanDictionary;
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Wrong initializer" reason:@"On VDDSuplenceSource permited initializer is initWithIndex:index!" userInfo:nil];
}

#pragma mark - Reloading

- (void)reloadData:(NSDictionary *)newData {
    int count = 0;
    
    NSArray *keys = [newData allKeys];
    for (NSString *key in keys) {
        if ([[newData valueForKey:key] count] != 0) {
            count++;
        }
    }
    
    numberOfSections = count;
    
    
    keys = [newData allKeys];
    
    NSMutableDictionary *cleanDictionary = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in keys) {
        NSArray *array = [newData valueForKey:key];
        if (array.count > 0) {
            [cleanDictionary setObject:array forKey:key];
        }
    }
    
    data = cleanDictionary;
}

#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return numberOfSections;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    long section = indexPath.section;
    NSArray *keys = [data allKeys];
    NSString *key = keys[section];
    
    if ([key isEqualToString:@"nadomescanja"])
        return [self nadomescanjaCellForIndexPath:indexPath inTableView:tableView];
    if ([key isEqualToString:@"menjavaPredmeta"])
        return [self menjavaPredmetaCellForIndexPath:indexPath inTableView:tableView];
    if ([key isEqualToString:@"menjavaUr"])
        return [self menjavaUrCellForIndexPath:indexPath inTableView:tableView];
    if ([key isEqualToString:@"menjavaUcilnic"])
        return [self menjavaUcilnicCellForIndexPath:indexPath inTableView:tableView];
    if ([key isEqualToString:@"rezervacijaUcilnic"])
        return [self rezervacijaUcilnicCellForIndexPath:indexPath inTableView:tableView];
    if ([key isEqualToString:@"vecUciteljevVRazredu"])
        return [self vecUciteljevCellForIndexPath:indexPath inTableView:tableView];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StandardCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StandardCell"];
    }
    cell.textLabel.text = @"Če se to dogaja pogosto me prosim kontaktiraj.";
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *keys = [data allKeys];
    NSString *key = keys[section];
    return [[data valueForKey:key] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *keys = [data allKeys];
    
    NSDictionary *dictionaryOfKeys = @{@"nadomescanja": @"Nadomeščanja",
                                       @"menjavaPredmeta": @"Menjava Predmeta",
                                       @"menjavaUr": @"Menjava Ur",
                                       @"menjavaUcilnic": @"Menjava Učilnic",
                                       @"rezervacijaUcilnic": @"Rezervacija Učilnic",
                                       @"vecUciteljevVRazredu": @"Več Učiteljev v Razredu"};
    
    return [dictionaryOfKeys valueForKey:keys[section]];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [UIFont systemFontOfSize:15];
    header.textLabel.textColor = [UIColor colorWithRed:56/255.0 green:142/255.0 blue:60/255.0 alpha:1.0];
 }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *keys = [data allKeys];
    NSString *key = keys[indexPath.section];
    if ([key isEqualToString:@"nadomescanja"])
        return 227.0;
    if ([key isEqualToString:@"menjavaPredmeta"])
        return 227.0;
    if ([key isEqualToString:@"menjavaUr"])
        return 315.0;
    if ([key isEqualToString:@"menjavaUcilnic"])
        return 231.0;
    if ([key isEqualToString:@"rezervacijaUcilnic"])
        return 144.0;
    if ([key isEqualToString:@"vecUciteljevVRazredu"])
        return 171.0;

    return 40.0;
}

#pragma mark - Cell Creation

- (UITableViewCell *)nadomescanjaCellForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    VDDNadomescanjaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VDDNadomescanjaCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VDDNadomescanjaCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSArray *nadomescanja = [data valueForKey:@"nadomescanja"];
    
    cell.odsoten.text = [nadomescanja[indexPath.row] valueForKey:@"odsoten"];
    cell.ura.text = [nadomescanja[indexPath.row] valueForKey:@"ura"];
    cell.razred.text = [nadomescanja[indexPath.row] valueForKey:@"razred"];
    cell.ucilnica.text = [nadomescanja[indexPath.row] valueForKey:@"ucilnica"];
    cell.nadomesca.text = [nadomescanja[indexPath.row] valueForKey:@"nadomesca"];
    cell.predmet.text = [nadomescanja[indexPath.row] valueForKey:@"predmet"];
    cell.opomba.text = [nadomescanja[indexPath.row] valueForKey:@"opomba"];
    
    return cell;
}

- (UITableViewCell *)menjavaPredmetaCellForIndexPath:(NSIndexPath  *)indexPath inTableView:(UITableView *)tableView {
    VDDMenjavaPredmetaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VDDMenjavaPredmetaCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VDDMenjavaPredmetaCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSArray *menjavaPredmeta = [data valueForKey:@"menjavaPredmeta"];
    
    cell.ura.text = [menjavaPredmeta[indexPath.row] valueForKey:@"ura"];
    cell.razred.text = [menjavaPredmeta[indexPath.row] valueForKey:@"razred"];
    cell.ucilnica.text = [menjavaPredmeta[indexPath.row] valueForKey:@"ucilnica"];
    cell.profesor.text = [menjavaPredmeta[indexPath.row] valueForKey:@"ucitelj"];
    cell.prvotenPredmet.text = [menjavaPredmeta[indexPath.row] valueForKey:@"originalPredmet"];
    cell.novPredmet.text = [menjavaPredmeta[indexPath.row] valueForKey:@"newPredmet"];
    cell.opomba.text = [menjavaPredmeta[indexPath.row] valueForKey:@"opomba"];
    
    return cell;
}

- (UITableViewCell *)menjavaUrCellForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    VDDMenjavaUrCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VDDMenjavaUrCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VDDMenjavaUrCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSArray *menjavaUr = [data valueForKey:@"menjavaUr"];
    
    cell.razred.text = [menjavaUr[indexPath.row] valueForKey:@"razred"];
    cell.opomba.text = [menjavaUr[indexPath.row] valueForKey:@"opomba"];
    cell.ucilnica.text = [menjavaUr[indexPath.row] valueForKey:@"ucilnica"];
    cell.ura.text = [menjavaUr[indexPath.row] valueForKey:@"ura"];
    cell.profFrom.text = [menjavaUr[indexPath.row] valueForKey:@"uciteljFrom"];
    cell.profTo.text = [menjavaUr[indexPath.row] valueForKey:@"uciteljTo"];
    cell.predmetFrom.text = [menjavaUr[indexPath.row] valueForKey:@"predmetFrom"];
    cell.predmetTo.text = [menjavaUr[indexPath.row] valueForKey:@"predmetTo"];
    
    return cell;
}

- (UITableViewCell *)menjavaUcilnicCellForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    VDDMenjavaUcilnicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VDDMenjavaUcilnicCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VDDMenjavaUcilnicCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSArray *menjavaUcilnic = [data valueForKey:@"menjavaUcilnic"];
    
    cell.razred.text = [menjavaUcilnic[indexPath.row] valueForKey:@"razred"];
    cell.opomba.text = [menjavaUcilnic[indexPath.row] valueForKey:@"opomba"];
    cell.predmet.text = [menjavaUcilnic[indexPath.row] valueForKey:@"predmet"];
    cell.ucilnicaFrom.text = [menjavaUcilnic[indexPath.row] valueForKey:@"ucilnicaFrom"];
    cell.ucilnicaTo.text = [menjavaUcilnic[indexPath.row] valueForKey:@"ucilnicaTo"];
    cell.ucitelj.text = [menjavaUcilnic[indexPath.row] valueForKey:@"ucitelj"];
    cell.ura.text = [menjavaUcilnic[indexPath.row] valueForKey:@"ura"];
    
    return cell;
}

- (UITableViewCell *)rezervacijaUcilnicCellForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    VDDRezervacijaUcilnicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VDDRezervacijaUcilnicCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VDDRezervacijaUcilnicCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSArray *rezervacijaUcilnic = [data valueForKey:@"rezervacijaUcilnic"];
    
    cell.ura.text = [rezervacijaUcilnic[indexPath.row] valueForKey:@"ura"];
    cell.ucilnica.text = [rezervacijaUcilnic[indexPath.row] valueForKey:@"ucilnica"];
    cell.rezervator.text = [rezervacijaUcilnic[indexPath.row] valueForKey:@"rezervator"];
    cell.opomba.text = [rezervacijaUcilnic[indexPath.row] valueForKey:@"opomba"];
    
    return cell;
}

- (UITableViewCell *)vecUciteljevCellForIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
    VDDVecUciteljevCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VDDVecUciteljevCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VDDVecUciteljevCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSArray *vecUciteljev = [data valueForKey:@"vecUciteljevVRazredu"];
    
    cell.ura.text = [vecUciteljev[indexPath.row] valueForKey:@"ura"];
    cell.profesor.text = [vecUciteljev[indexPath.row] valueForKey:@"ucitelj"];
    cell.razred.text = [vecUciteljev[indexPath.row] valueForKey:@"razred"];
    cell.ucilnica.text = [vecUciteljev[indexPath.row] valueForKey:@"ucilnica"];
    cell.opomba.text = [vecUciteljev[indexPath.row] valueForKey:@"opomba"];
    
    return cell;
}

@end