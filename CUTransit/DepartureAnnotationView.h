//
//  DepartureAnnotationView.h
//  CU Transit
//
//  Copyright (c) 2012 Sukolsak Sakshuwong. All rights reserved.
//

#import <MapKit/MapKit.h>

@class HaloView;

// A view displaying the current location of a bus.
@interface DepartureAnnotationView : MKAnnotationView {
	HaloView *halo;
}

@end
