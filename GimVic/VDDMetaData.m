//
//  VDDMetaData.m
//  GimVic
//
//  Created by Vid Drobnič on 10/08/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDMetaData.h"

@interface VDDMetaData()
{
    NSMutableDictionary *metaData;
    NSString *metaDataPath;
}
@end


@implementation VDDMetaData

#pragma mark - Singleton Declaration

+ (instancetype)sharedMetaData {
    static VDDMetaData *sharedMetaData;
    if (!sharedMetaData) {
        sharedMetaData = [[self alloc] initPrivate];
    }
    return sharedMetaData;
}

#pragma mark - Initialization

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Wrong initializer" reason:@"VDDMetaData is a singleton. You should use +sharedMetaData" userInfo:nil];
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = (paths.count > 0) ? paths[0] : nil;
        metaDataPath = [NSString stringWithFormat:@"%@/metaData", documentsPath];
        metaData = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:metaDataPath]]];
    }
    return self;
}

#pragma mark - Data Manipulation

- (void)changeMetaDataAtributeWithKey:(NSString *)key toObject:(NSObject *)object {
    metaData[key] = object;
    [[NSKeyedArchiver archivedDataWithRootObject:metaData] writeToFile:metaDataPath atomically:YES];
}

- (NSObject *)metaDataObjectForKey:(NSString *)key {
    return [metaData valueForKey:key];
}

@end