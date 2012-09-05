//
//  common.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class CUError;

void alert(NSString *title, NSString *message);

MKMapRect optimalRectForCoordinates(CLLocationCoordinate2D c1, CLLocationCoordinate2D c2);
MKMapRect mapRectWithEdgePadding(MKMapRect rect, UIEdgeInsets edgePadding, MKMapView *view);
MKCoordinateRegion defaultRegion();

NSError *errorWithDescription(NSInteger code, NSString *description);
void handleCommonError(CUError *error);

NSString *formattedTime(NSString *fullTime);
