#import <MRYIPCCenter.h>
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

@interface headersaver : NSObject
@end

@implementation headersaver
{
	MRYIPCCenter* _center;
	NSMutableArray *containerQueue;
	NSMutableDictionary *headers;
}

+(void)load
{
	[self sharedInstance];
}

+(instancetype)sharedInstance
{
	static dispatch_once_t onceToken = 0;
	__strong static headersaver* sharedInstance = nil;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

-(instancetype)init
{
	if ((self = [super init]))
	{
		_center = [%c(MRYIPCCenter) centerNamed:@"com.iosrouter.headersaver"];
		[_center addTarget:self action:@selector(startHeaderDump)];
		[_center addTarget:self action:@selector(currentQueue)];
		[_center addTarget:self action:@selector(saveHeader:)];
		[_center addTarget:self action:@selector(openContainer:)];
		[_center addTarget:self action:@selector(headers)];
	}
	return self;
}

-(NSArray *)currentQueue {
	return containerQueue;
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

-(void)saveHeader:(id)data {
	NSString *container = [data objectForKey:@"container"];
	NSArray *header = [data objectForKey:@"header"];
	@try {
		NSLog(@"iosrouter saving header: %@ for container: %@", header, container);
		[headers setObject:header forKey:container];	
		[containerQueue removeObject:container];
	} @catch (NSException *exception) {
		NSLog(@"iosrouter saving headerXX: %@", exception);
	}
}

-(void)openContainer:(id)data {
	NSString *container = [data objectForKey:@"container"];
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



