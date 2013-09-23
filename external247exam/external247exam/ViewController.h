//
//  ViewController.h
//  external247exam
//
//  Created by Jonathan Francis M. Gonzalez on 9/23/13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <NSURLConnectionDataDelegate, NSXMLParserDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapview;
@end
