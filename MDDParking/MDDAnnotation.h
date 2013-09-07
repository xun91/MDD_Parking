//
//  MDDAnnotation.h
//  MDDParking
//
//  Created by Biranchi on 9/7/13.
//  Copyright (c) 2013 Xchanging. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MDDAnnotation : NSObject <MKAnnotation> {
  CLLocationCoordinate2D coordinate;
  NSString *title;
  NSString *subtitle;
  id objectX;
}
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, retain) id objectX;


@end
