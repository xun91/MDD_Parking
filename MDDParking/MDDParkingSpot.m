//
//  MDDParkingSpot.m
//  Parking
//
//  Created by xun on 9/7/13.
//  Copyright (c) 2013 hackathon. All rights reserved.
//

#import "MDDParkingSpot.h"
#import "MDDAppAPIClient.h"
#import "MDDFee.h"

@implementation MDDParkingSpot

@synthesize id = _id;
@synthesize name = _name;
@synthesize lat = _lat;
@synthesize lng = _lng;
@synthesize fees = _fees;


+ (void)pumpinDummyParkingSpotsWithBlock:(void (^)(NSArray *posts, NSError *error))block
{
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"places-get"
                                                         ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    NSError *error = nil;
    id JSON = [NSJSONSerialization JSONObjectWithData:data
                                              options:kNilOptions
                                                error:&error];
    
    if(error)
    {
        if(block)
        {
            block([NSArray array], error);
        }
    }
    else
    {
        NSArray *parkingSpotsFromResponse = [JSON valueForKeyPath:@"results"];
        NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[parkingSpotsFromResponse count]];
        for (NSDictionary *attributes in parkingSpotsFromResponse) {
            MDDParkingSpot *parkingSpot = [[MDDParkingSpot alloc] initWithAttributes:attributes];
            [mutablePosts addObject:parkingSpot];
        }
        
        if (block)
        {
            block([NSArray arrayWithArray:mutablePosts], nil);
        }
    }
}


+ (void)nearestParkingSpotsWithBlock:(void (^)(NSArray *posts, NSError *error))block atCoordinate:(CLLocationCoordinate2D)coordinate 
{
    NSDictionary* parameters = @{
                                     @"lat"     :   @(coordinate.latitude),
                                     @"lng"     :   @(coordinate.longitude),
                                     @"action"  :   @"get_place"
                                 };
    
    [[MDDAppAPIClient sharedClient] getPath:nil parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSArray *parkingSpotsFromResponse = [JSON valueForKeyPath:@"results"];
        NSMutableArray *mutablePosts = [NSMutableArray arrayWithCapacity:[parkingSpotsFromResponse count]];
        for (NSDictionary *attributes in parkingSpotsFromResponse) {
            MDDParkingSpot *parkingSpot = [[MDDParkingSpot alloc] initWithAttributesLong:attributes];
            [mutablePosts addObject:parkingSpot];
        }
        
        if (block) {
            block([NSArray arrayWithArray:mutablePosts], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSArray array], error);
        }
    }];
}


+ (void)addNewParkingSpotsWithBlock:(void (^)(MDDParkingSpot *post, NSError *error))block byUsing:(MDDParkingSpot*)parkingSpot
{  
    NSDictionary* parameters = @{
                                 @"name"    :   parkingSpot.name,
                                 @"lat"     :   @(parkingSpot.lat),
                                 @"lng"     :   @(parkingSpot.lng),
                                 };  
    
    NSMutableDictionary* mutableDict = [NSMutableDictionary dictionaryWithDictionary:parameters];
    
    int looperIndex = 0;
    for(MDDFee* fee in parkingSpot.fees)
    {
        NSDictionary * tempDict = @{[NSString stringWithFormat:@"fees[%d]", looperIndex]:
                                        @{
                                            @"type" : fee.type,
                                            @"rule" : fee.rule,
                                            @"fee" : @(fee.fee),
                                        }
                                    };
        [mutableDict addEntriesFromDictionary:tempDict];
        ++looperIndex;
    }
    
    [mutableDict addEntriesFromDictionary:@{ @"action": @"create_place" }];
    
    
    [[MDDAppAPIClient sharedClient] postPath:nil parameters:[NSDictionary dictionaryWithDictionary:mutableDict] success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSDictionary *attributes = [JSON valueForKeyPath:@"results"];
            MDDParkingSpot *parkingSpot = [[MDDParkingSpot alloc] initWithAttributes:attributes];
        
        if (block) {
            block(parkingSpot, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];    
}


+ (void)editParkingSpotsWithBlock:(void (^)(MDDParkingSpot *post, NSError *error))block byUsing:(MDDParkingSpot*)parkingSpot
{
    NSDictionary* parameters = @{
                                 @"id"      :   @(parkingSpot.id),
                                 @"name"    :   parkingSpot.name,
                                 @"lat"     :   @(parkingSpot.lat),
                                 @"lng"     :   @(parkingSpot.lng),
                                 };
    
    NSMutableDictionary* mutableDict = [NSMutableDictionary dictionaryWithDictionary:parameters];
    
    int looperIndex = 0;
    for(MDDFee* fee in parkingSpot.fees)
    {
        if(fee.id > 0)
        {
            NSDictionary * tempDict = @{ [NSString stringWithFormat:@"fees[%d]", looperIndex]:
                                        @{
                                            @"id"   : @(fee.id),
                                            @"type" : fee.type,
                                            @"rule" : fee.rule,
                                            @"fee" : @(fee.fee),
                                        }
                                    };

            [mutableDict addEntriesFromDictionary:tempDict];
        }
        else
        {
            NSDictionary * tempDict = @{ [NSString stringWithFormat:@"fees[%d]", looperIndex]:
                                             @{
//                                                 @"id"   : @(fee.id),
                                                 @"type" : fee.type,
                                                 @"rule" : fee.rule,
                                                 @"fee" : @(fee.fee),
                                                 }
                                         };
            
            [mutableDict addEntriesFromDictionary:tempDict];

        }

        ++looperIndex;
    }
    
    [mutableDict addEntriesFromDictionary:@{ @"action": @"edit_place" }];
    
    [[MDDAppAPIClient sharedClient] postPath:nil parameters:[NSDictionary dictionaryWithDictionary:mutableDict] success:^(AFHTTPRequestOperation *operation, id JSON) {
        NSDictionary *attributes = [JSON valueForKeyPath:@"results"];
	  
	  NSLog(@"attributes : %@", attributes);
        MDDParkingSpot *parkingSpot = [[MDDParkingSpot alloc] initWithAttributes:attributes];
        
        if (block) {
            block(parkingSpot, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

- (id)initWithAttributesLong:(NSDictionary*) attributes
{
    _id = [[attributes valueForKeyPath:@"id"] integerValue];
    _name = [attributes valueForKeyPath:@"name"];
    _lat = [[attributes valueForKeyPath:@"latitude"] floatValue];
    _lng = [[attributes valueForKeyPath:@"longitude"] floatValue];
    
    NSArray* feesList = [attributes valueForKeyPath:@"fees"];
    
    if(feesList)
    {
        NSMutableArray *mutableList = [NSMutableArray arrayWithCapacity:[feesList count]];
        
        for (NSDictionary *feeStructure in feesList) {
            MDDFee *parkingFee = [[MDDFee alloc] initWithAttributes:feeStructure];
            [mutableList addObject:parkingFee];
        }
        _fees = [NSArray arrayWithArray:mutableList];
    }
    
    return self;

}

- (id)initWithAttributes:(NSDictionary*) attributes
{
    _id = [[attributes valueForKeyPath:@"id"] integerValue];
    _name = [attributes valueForKeyPath:@"name"];
    _lat = [[attributes valueForKeyPath:@"lat"] floatValue];
    _lng = [[attributes valueForKeyPath:@"lng"] floatValue];
    
    NSArray* feesList = [attributes valueForKeyPath:@"fees"];
    
    if(feesList)
    {
        NSMutableArray *mutableList = [NSMutableArray arrayWithCapacity:[feesList count]];
        
        for (NSDictionary *feeStructure in feesList) {
            MDDFee *parkingFee = [[MDDFee alloc] initWithAttributes:feeStructure];
            [mutableList addObject:parkingFee];
        }
        _fees = [NSArray arrayWithArray:mutableList];
    }
    
    
    return self;
}


@end
