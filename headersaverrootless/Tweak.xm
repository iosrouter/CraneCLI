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
+(void)load
{
	[self sharedInstance];
}

+(id)sharedInstance
{
	static dispatch_once_t once = 0;
	__strong static id sharedInstance = nil;
	dispatch_once(&once, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

BOOL didInitServer = NO;
-(id)init
{
	if ((self = [super init]))
	{
		#define _serviceName @"com.iosrouter.headersaver"

        CrossOverIPC *crossOver = [objc_getClass("CrossOverIPC") centerNamed:_serviceName type:SERVICE_TYPE_LISTENER];

        [crossOver registerForMessageName:@"startHeaderDump" target:self selector:@selector(startHeaderDump:)];
		[crossOver registerForMessageName:@"saveHeader" target:self selector:@selector(saveHeader: userInfo:)];
		[crossOver registerForMessageName:@"openContainer" target:self selector:@selector(openContainer: userInfo:)];
		[crossOver registerForMessageName:@"headers" target:self selector:@selector(headers:)];
		[crossOver registerForMessageName:@"currentQueue" target:self selector:@selector(currentQueue:)];

	}
	return self;
}



-(NSDictionary *)currentQueue:(NSString *)name {
	return @{@"queue": containerQueue};
}


-(void)startHeaderDump:(NSString *)name {
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

-(void)saveHeader:(NSString *)name userInfo:(NSDictionary*)userInfo {
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

-(void)openContainer:(NSString *)name userInfo:(NSDictionary*)userInfo {
	NSString *container = [userInfo objectForKey:@"container"];
	loadLibCrane();
	CraneManager *craneManager = [objc_getClass("CraneManager") sharedManager];
	[craneManager setActiveContainerIdentifier:container forApplicationWithIdentifier:@"com.cardify.tinder"];
	Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
	NSObject * workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
	[workspace performSelector:@selector(openApplicationWithBundleID:) withObject:@"com.cardify.tinder"];
	

}

-(NSDictionary *)headers:(NSString *)name {
	NSLog(@"iosrouter headers: %@", headers);
	return headers;
}


@end




%ctor {
	[headersaverrootless load];
}