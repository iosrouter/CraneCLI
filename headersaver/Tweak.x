#import <MRYIPCCenter.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "libCrane.h"
#import <objc/runtime.h>
@import ObjectiveC.runtime;

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
		_center = [MRYIPCCenter centerNamed:@"com.iosrouter.headersaver"];
		[_center addTarget:self action:@selector(startHeaderDump)];
		[_center addTarget:self action:@selector(currentQueue)];
		[_center addTarget:self action:@selector(saveHeader: forContainer:)];
		[_center addTarget:self action:@selector(openContainer:)];
		[_center addTarget:self action:@selector(headers)];
	}
	return self;
}

-(NSArray *)currentQueue {
	return containerQueue;
}


-(void)startHeaderDump {
	loadLibCrane();
	CraneManager *craneManager = [objc_getClass("CraneManager") sharedManager];
	NSMutableArray *preQueue = [[craneManager containerIdentifiersOfApplicationWithIdentifier:@"com.cardify.tinder"] mutableCopy];
	[self openContainer:[preQueue firstObject]];
	[preQueue removeObjectAtIndex:0];
	containerQueue = [preQueue mutableCopy];
	headers = [NSMutableDictionary new];
	Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
	NSObject * workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
	[workspace performSelector:@selector(openApplicationWithBundleID:) withObject:@"com.cardify.tinder"];
}

-(void)saveHeader:(NSString *)header forContainer:(NSString *)container{
	@try {
		[headers setObject:header forKey:container];
	} @catch (NSException *exception) {
		NSLog(@"iosrouter saving header: %@", exception);
	}
}

-(void)openContainer:(NSString *)container{
	loadLibCrane();
	CraneManager *craneManager = [objc_getClass("CraneManager") sharedManager];
	[craneManager setActiveContainerIdentifier:container forApplicationWithIdentifier:@"com.cardify.tinder"];
	[containerQueue removeObject:container];
	Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
	NSObject * workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
	[workspace performSelector:@selector(openApplicationWithBundleID:) withObject:@"com.cardify.tinder"];
	

}

-(NSDictionary *)headers {
	return headers;
}


@end



