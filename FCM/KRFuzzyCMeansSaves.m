//
//  KRFuzzySaves.h
//  KRFuzzyCMeans
//
//  Created by Kalvar Lin on 2015/11/15.
//  Copyright © 2015年 Kalvar. All rights reserved.
//

#import "KRFuzzyCMeansSaves.h"

static NSString *kKRFuzzyCMeansSavesCentersKey = @"kKRFuzzyCMeansSavesCentersKey";

@implementation KRFuzzyCMeansSaves (fixSaves)

-(NSUserDefaults *)_userDefaults
{
    return [NSUserDefaults standardUserDefaults];
}

-(void)_synchronize
{
    [[self _userDefaults] synchronize];
}

-(instancetype)_defaultValueForKey:(NSString *)_key
{
    return [[self _userDefaults] objectForKey:_key];
}

-(void)_saveDefaultValue:(NSArray *)_value forKey:(NSString *)_forKey
{
    [[self _userDefaults] setObject:_value forKey:_forKey];
    [self _synchronize];
}

-(void)_removeValueForKey:(NSString *)_key
{
    [[self _userDefaults] removeObjectForKey:_key];
    [self _synchronize];
}

@end

@implementation KRFuzzyCMeansSaves

+(instancetype)sharedInstance
{
    static dispatch_once_t pred;
    static KRFuzzyCMeansSaves *_object = nil;
    dispatch_once(&pred, ^{
        _object = [[KRFuzzyCMeansSaves alloc] init];
    });
    return _object;
}

-(instancetype)init
{
    self = [super init];
    if( self )
    {
        
    }
    return self;
}

-(void)saveCenters:(NSArray *)_centers
{
    [self _saveDefaultValue:[_centers copy] forKey:kKRFuzzyCMeansSavesCentersKey];
}

-(NSArray *)fetchCenters
{
    return (NSArray *)[self _defaultValueForKey:kKRFuzzyCMeansSavesCentersKey];
}

-(void)deleteCenters
{
    [self _removeValueForKey:kKRFuzzyCMeansSavesCentersKey];
}

@end