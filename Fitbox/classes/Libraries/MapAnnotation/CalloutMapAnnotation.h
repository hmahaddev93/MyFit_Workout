#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CalloutMapAnnotation : NSObject <MKAnnotation> {
	CLLocationDegrees _latitude;
	CLLocationDegrees _longitude;
    NSString *_mKey;
}


@property (nonatomic, retain) NSString *mKey;

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;

- (id)initWithLatitude:(CLLocationDegrees)latitude
		  andLongitude:(CLLocationDegrees)longitude;

@end
