#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CalloutMapAnnotationView : MKAnnotationView {
	MKAnnotationView *_parentAnnotationView;
	MKMapView *_mapView;
	CGRect _endFrame;
	UIView *_contentView;
	UIImageView *_mPhotoView;
	UILabel *_mTitleView;
	UILabel *_mExtraView;
	CGFloat _yShadowOffset;
	CGPoint _offsetFromParent;
	CGFloat _contentHeight;
}

@property (nonatomic, retain) MKAnnotationView *parentAnnotationView;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic, retain) UIImageView *mPhotoView;
@property (nonatomic, retain) UILabel *mTitleView;
@property (nonatomic, retain) UILabel *mExtraView;
@property (nonatomic) CGPoint offsetFromParent;
@property (nonatomic) CGFloat contentHeight;

- (void)animateIn;
- (void)animateInStepTwo;
- (void)animateInStepThree;

@end
