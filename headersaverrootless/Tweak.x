#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "libCrane.h"
#import <objc/runtime.h>
@import ObjectiveC.runtime;
@import UIKit.UIApplication;

@interface UIApplication (Private)
- (BOOL)launchApplicationWithIdentifier:(NSString *)identifier suspended:(BOOL)suspended;
@end

@interface headersaverrootless : NSObject
-(void)startHeaderDump;
-(void)saveHeader:(id)userInfo;
-(void)openContainer:(id)userInfo;
-(NSDictionary *)headers;
-(NSArray *)currentQueue;
@end

@implementation headersaverrootless
{
	NSMutableArray *containerQueue;
	NSMutableDictionary *headers;
}

-(id)init {

	if ((self = [super init])){ 

 
	   
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{


        #define _serviceName @"com.iosrouter.headersaver"

        CrossOverIPC *crossOver = [objc_getClass("CrossOverIPC") centerNamed:_serviceName type:SERVICE_TYPE_LISTENER];

        [crossOver registerForMessageName:@"startHeaderDump" target:self selector:@selector(startHeaderDump)];
		[crossOver registerForMessageName:@"saveHeader" target:self selector:@selector(saveHeader:)];
		[crossOver registerForMessageName:@"openContainer" target:self selector:@selector(openContainer:)];
		[crossOver registerForMessageName:@"headers" target:self selector:@selector(headers)];
		[crossOver registerForMessageName:@"currentQueue" target:self selector:@selector(currentQueue)];

 
        }); 

    }

    return self;
}


-(NSDictionary *)currentQueue {
	return @{@"queue": containerQueue};
}


-(void)startHeaderDump {
	NSLog(@"iosrouter starting header dump");
	@try {
		loadLibCrane();
		CraneManager *craneManager = [objc_getClass("CraneManager") sharedManager];
		NSMutableArray *preQueue = [[craneManager containerIdentifiersOfApplicationWithIdentifier:@"com.cardify.tinder"] mutableCopy];
		[self openContainer:@{@"container": preQueue[0]}];
		containerQueue = [preQueue mutableCopy];
		headers = [NSMutableDictionary new];
		Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
		NSObject * workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
		[workspace performSelector:@selector(openApplicationWithBundleID:) withObject:@"com.cardify.tinder"];
	} @catch (NSException *exception) {
		NSLog(@"iosrouter err: %@", exception);
	}
	NSLog(@"iosrouter started header dump");
}

-(void)saveHeader:(id)userInfo {
	NSString *container = [userInfo objectForKey:@"container"];
	NSArray *header = [userInfo objectForKey:@"header"];
	@try {
		NSLog(@"iosrouter saving header: %@ for container: %@", header, container);
		[headers setObject:header forKey:container];	
		[containerQueue removeObject:container];
	} @catch (NSException *exception) {
		NSLog(@"iosrouter saving headerXX: %@", exception);
	}
}

-(void)openContainer:(id)userInfo {
	NSString *container = [userInfo objectForKey:@"container"];
	loadLibCrane();
	CraneManager *craneManager = [objc_getClass("CraneManager") sharedManager];
	[craneManager setActiveContainerIdentifier:container forApplicationWithIdentifier:@"com.cardify.tinder"];
	Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
	NSObject * workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
	[workspace performSelector:@selector(openApplicationWithBundleID:) withObject:@"com.cardify.tinder"];
	

}

-(NSDictionary *)headers {
	NSLog(@"iosrouter headers: %@", headers);
	return headers;
}


@end




%ctor {
	[headersaverrootless new];
}