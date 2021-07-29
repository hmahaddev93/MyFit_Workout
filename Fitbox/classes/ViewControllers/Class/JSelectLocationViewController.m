//
//  JSelectLocationViewController.m
//  Fitbox
//
//  Created by Khatib H. on 2/20/16.
//  
//

#import "JSelectLocationViewController.h"
#import "BasicMapAnnotation.h"

@import MapKit;

@interface JSelectLocationViewController ()
{
    IBOutlet MKMapView *mMapView;
    UIImageView                 *mImgAnnot;
}



@end

@implementation JSelectLocationViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (_isSelectLocation) {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(foundTap:)];
        
        tapRecognizer.numberOfTapsRequired = 1;
        
        tapRecognizer.numberOfTouchesRequired = 1;
        
        [mMapView addGestureRecognizer:tapRecognizer];
//        self.navigationItem.rightBarButtonItem = nil;
//        self.navigationItem.rightBarButtonItems = nil;
        self.navigationItem.title = @"Select Location";
    }
    else
    {
        self.navigationItem.title = @"Location";
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self initView];
}


-(void)initView
{
    mImgAnnot=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    mImgAnnot.layer.cornerRadius=12;
    mImgAnnot.layer.masksToBounds=YES;
    
    if (!_mLat) {
        if ([JUtils isLocationAvailable]) {
            _mLat = [NSNumber numberWithDouble:[Engine myLocation].latitude];
            _mLng = [NSNumber numberWithDouble:[Engine myLocation].longitude];
        }
    }
    if (_mLat) {
//        [mMapView ]
        [self removeAndSetPin:[_mLat doubleValue] lng:[_mLng doubleValue] moveCenter:true];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)removeAndSetPin:(double)lat lng:(double)lng moveCenter:(BOOL)moveCenter
{
    //
    //    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
    //        return;
    
    [mMapView removeAnnotations:[mMapView annotations]];
    
    BasicMapAnnotation* mAnnot=[[BasicMapAnnotation alloc] initWithLatitude:lat andLongitude:lng];
    [mMapView addAnnotation:mAnnot];

    
    if(moveCenter)
    {
        CLLocationCoordinate2D centerLocation;
        centerLocation.latitude = lat;
        centerLocation.longitude = lng;
        MKCoordinateSpan span;

        span.latitudeDelta=MAP_SHOW_DISTANCE_FOR_PLACE;
        span.longitudeDelta=MAP_SHOW_DISTANCE_FOR_PLACE;
        centerLocation.latitude += MAP_SHOW_DISTANCE_FOR_PLACE/8;
        MKCoordinateRegion region = {centerLocation, span};
        [mMapView setRegion:region];
    }
    else
    {
//        span.latitudeDelta=MAP_SHOW_DISTANCE_FOR_ANONYMOUSE;
//        span.longitudeDelta=MAP_SHOW_DISTANCE_FOR_ANONYMOUSE;
//        centerLocation.latitude += MAP_SHOW_DISTANCE_FOR_ANONYMOUSE/8;
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView1 viewForAnnotation:(id <MKAnnotation>)annotation {
    
    
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                    reuseIdentifier:@"CustomAnnotation"];
    
    annotationView.canShowCallout = NO;
    //    BasicMapAnnotation* annot=(BasicMapAnnotation*)annotation;
    UIView* mAnnotationContainer=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 45)];
    UIImageView* imgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 45)];
    [imgView setImage:[UIImage imageNamed:@"iconPinkPin"]];
    [mAnnotationContainer addSubview:imgView];
    
    [mImgAnnot setFrame:CGRectMake(3, 4, 24, 24)];
    [mAnnotationContainer addSubview:mImgAnnot];
    [annotationView addSubview:mAnnotationContainer];
    
    annotationView.centerOffset = CGPointMake(-15, -45);
    return annotationView;
    
}

-(IBAction)onBtnBack:(id)sender
{
    if ([(id)delegate respondsToSelector: @selector(JSelectLocationViewControllerDelegateCancel)])
    {
        [delegate JSelectLocationViewControllerDelegateCancel];
    }
}

-(IBAction)onBtnDone:(id)sender
{
    if (!_mLat) {
        [self.navigationController.view makeToast:@"Please select a location" duration:1.0 position:CSToastPositionTop];
        return;
    }
    if ([(id)delegate respondsToSelector: @selector(JSelectLocationViewControllerDelegateLocationSelected:lng:)])
    {
        [delegate JSelectLocationViewControllerDelegateLocationSelected:[_mLat doubleValue] lng:[_mLng doubleValue]];
    }
}

-(IBAction)foundTap:(UITapGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:mMapView];
    
    CLLocationCoordinate2D tapPoint = [mMapView convertPoint:point toCoordinateFromView:mMapView];
    
    _mLat = [NSNumber numberWithDouble: tapPoint.latitude];
    _mLng = [NSNumber numberWithDouble: tapPoint.longitude];
    
    [self removeAndSetPin:tapPoint.latitude lng: tapPoint.longitude moveCenter:false];
}
@end
