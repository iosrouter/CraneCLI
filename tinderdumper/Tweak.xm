#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#ifdef ROOTLESS
	#import "CrossOverIPC.h"
#else
	#import <"MRYIPCCenter.h">
#endif
#import "libCrane.h"


#define _serviceName @"com.iosrouter.headersaver"

@interface headersaverrootless : NSObject
+(id)sharedInstance;
-(void)startHeaderDump;
-(void)saveHeader:(NSString *)name userInfo:(NSDictionary*)userInfo;
-(void)openContainer:(NSString *)name userInfo:(NSDictionary*)userInfo;
-(NSDictionary *)headers;
-(NSDictionary *)currentQueue;
@end

NSMutableString *getRefreshTokenFromKeychain() {
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitAll;
    query[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;
    query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;

    CFArrayRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecSuccess) {
        NSMutableString *allValues = [NSMutableString string];
        //return all values by account 
        for (NSDictionary *item in (__bridge NSArray *)result) {
            NSString *account = item[(__bridge id)kSecAttrAccount];
            NSData *data = item[(__bridge id)kSecValueData];
            NSString *value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [allValues appendFormat:@"%@: %@\n", account, value];
        }
		//print all lines
		for (NSString *line in [allValues componentsSeparatedByString:@"\n"]) {
			NSLog(@"iosrouter line: %@", line);
		}
        return allValues;
    } else {
        NSLog(@"iosrouter Failed to retrieve keychain items with status: %d", (int)status);
        return nil;
    }
}

void mainBundleDidLoad() {
	@try {
		
		#ifdef ROOTLESS
			NSMutableString *refreshToken = getRefreshTokenFromKeychain();
			NSLog(@"iosrouter refreshToken: %@", refreshToken);
			CrossOverIPC *crossOver = [objc_getClass("CrossOverIPC") centerNamed:_serviceName type:SERVICE_TYPE_SENDER];
			NSArray *currentQueue = [crossOver sendMessageAndReceiveReplyName:@"currentQueue" userInfo:nil][@"queue"];
			if ([currentQueue count] > 0 ) {
				//if ([currentQueue containsObject:activeContainer]) {
				//	[center callExternalMethod:@selector(openContainer:) withArguments:@[activeContainer]];
				//} else {
				//	[center callExternalMethod:@selector(saveHeader:forContainer:) withArguments:@[getRefreshTokenFromKeychain(), activeContainer]];
				//}
				if (refreshToken == nil) {
					NSLog(@"iosrouter refreshToken is nil");
					return;
				}
				NSLog(@"iosrouter currentQueue: %@", currentQueue[0]);
				NSLog(@"iosrouter refreshToken: %@", refreshToken);
				NSArray *tokens = [refreshToken componentsSeparatedByString:@"\n"];
				[crossOver sendMessageName:@"saveHeader" userInfo:@{@"header" : tokens, @"container" : [currentQueue[0] stringValue]}];
				if ([currentQueue count] > 1) {
					[crossOver sendMessageName:@"openContainer" userInfo:@{@"container" : currentQueue[1]}];
				}
			}
		#else
			NSMutableString *refreshToken = getRefreshTokenFromKeychain();
			NSLog(@"iosrouter refreshToken: %@", refreshToken);
			MRYIPCCenter* center = [%c(MRYIPCCenter) centerNamed:@"com.iosrouter.headersaver"];
			NSArray *currentQueue = [center callExternalMethod:@selector(currentQueue) withArguments:nil];
			if ([currentQueue count] > 0 ) {
				//if ([currentQueue containsObject:activeContainer]) {
				//	[center callExternalMethod:@selector(openContainer:) withArguments:@[activeContainer]];
				//} else {
				//	[center callExternalMethod:@selector(saveHeader:forContainer:) withArguments:@[getRefreshTokenFromKeychain(), activeContainer]];
				//}
				if (refreshToken == nil) {
					NSLog(@"iosrouter refreshToken is nil");
					return;
				}
				NSLog(@"iosrouter currentQueue: %@", currentQueue[0]);
				NSLog(@"iosrouter refreshToken: %@", refreshToken);
				NSArray *tokens = [refreshToken componentsSeparatedByString:@"\n"];
				[center callExternalVoidMethod:@selector(saveHeader:) withArguments:@{@"header" : tokens, @"container" : [currentQueue[0] stringValue]}];
				if ([currentQueue count] > 1) {
					[center callExternalVoidMethod:@selector(openContainer:) withArguments:@{@"container" : currentQueue[1]}];
				}
			}
		#endif

	} @catch (NSException *exception) {
		NSLog(@"iosrouter Error: %@", exception);
	}
}

%ctor {
	@autoreleasepool {
		// Wait until the app finishes loading
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			mainBundleDidLoad();
		});
	}
}