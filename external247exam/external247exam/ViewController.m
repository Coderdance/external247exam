//
//  ViewController.m
//  external247exam
//
//  Created by Jonathan Francis M. Gonzalez on 9/23/13.
//
//

#import "ViewController.h"

#define METERS_PER_MILE 1609.344

@interface ViewController ()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableArray *resultArray;

@property (nonatomic, strong) NSString *groupKey;
@property (nonatomic, strong) NSMutableString *currentString;
@property (nonatomic, strong) NSMutableDictionary *tempDict;

- (void)getLocationData;
- (void)startGetData;
@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //now get the data from the server - Make sure it's
    
    
    [self getLocationData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)getLocationData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND,
                                             (unsigned long)NULL), ^(void) {
        [self startGetData];
    });
}


#pragma mark NSURL Connection delegate functions
- (void)startGetData
{
    NSString *urlString = @"https://dl.dropboxusercontent.com/u/101222705/business.xml";
    NSLog(@"url request to %@", urlString);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    //_connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (_connection)
    {
        [_connection cancel];
        _connection = nil;
    }
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
    [_connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                          forMode:NSDefaultRunLoopMode];
    
    [_connection start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"connection didReceiveResponse  %@", response);
    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
    NSLog(@" %@", [httpResp allHeaderFields]);;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"connection didReceiveData  %@ :::: %@", dataStr, data);
    
    //focus on just XML
    {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        [parser setDelegate:self];
        
        [parser setShouldProcessNamespaces:NO];
        [parser setShouldReportNamespacePrefixes:NO];
        [parser setShouldResolveExternalEntities:NO];
        
        if (!_resultArray)
            _resultArray = [[NSMutableArray alloc] init];
        [_resultArray removeAllObjects];
        
        _groupKey = @"business";
        
        BOOL isSuccess = [parser parse];
        
        if (!isSuccess)
        {
            //Now what?
            NSLog(@"Cannot parse downloaded string");
        }
        else
        {
            NSLog(@"result! : %@", _resultArray);
            
            if (_resultArray.count > 0)
            {
                id obj1, obj2;
                BOOL hasZoomed = NO;
                
                for (NSDictionary *dict in _resultArray)
                {
                    obj1 = [dict objectForKey:@"latitude"];
                    obj2 = [dict objectForKey:@"longitude"];
                    
                    if (obj1 && obj2)
                    {
                        NSString *lat = (NSString *)obj1;
                        NSString *lng = (NSString *)obj2;
                        
                        if (!hasZoomed)
                        {
                            CLLocationCoordinate2D zoomLocation;
                            zoomLocation.latitude = [lat doubleValue];
                            zoomLocation.longitude= [lng doubleValue];
                            
                            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
                            
                            [_mapview setRegion:viewRegion animated:YES];
                            
                            hasZoomed = YES;
                        }
                        
                        NSString *businessName = @"";
                        id obj3 = [dict objectForKey:@"name"];
                        if (obj3 && [obj3 isKindOfClass:[NSString class]])
                            businessName = (NSString *)obj3;
                        
                        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
                        CLLocationCoordinate2D location;
                        location.latitude = [lat doubleValue];
                        location.longitude = [lng doubleValue];
                        [point setCoordinate:(location)];
                        [point setTitle:businessName];
                        
                        [_mapview addAnnotation:point];
                    }
                }
            }
        }
    }
}

#pragma mark XML Parser delegates

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(!_currentString){
        _currentString = [[NSMutableString alloc] init];
    }
    
    [_currentString appendString:string];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSString *currentStringNoWhiteSpace = [_currentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([elementName isEqualToString:_groupKey]){
        if (_tempDict)
        {
            [_resultArray addObject:_tempDict];
            _tempDict = nil;
        }
        _tempDict = [[NSMutableDictionary alloc] init];
    }
    
    else if (currentStringNoWhiteSpace != nil)
    {
        if (!_tempDict)
            _tempDict = [[NSMutableDictionary alloc] init];
        [_tempDict setValue:currentStringNoWhiteSpace forKey:elementName];
    }
    
    currentStringNoWhiteSpace = nil;
    _currentString = nil;
}


- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
}

@end
