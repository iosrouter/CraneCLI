#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <MRYIPCCenter.h>
#import "libCrane.h"

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
        return allValues;
    } else {
        NSLog(@"Failed to retrieve keychain items with status: %d", (int)status);
        return nil;
    }
}


%ctor {
	@autoreleasepool {
		@try {
			//loadLibCrane();
			//CraneManager *craneManager = [objc_getClass("CraneManager") sharedManager];
			//NSString *activeContainer = [craneManager activeContainerIdentifierForApplicationWithIdentifier:@"com.cardify.tinder"];
			NSString *refreshToken = getRefreshTokenFromKeychain();
			NSLog(@"iosrouter refreshToken: %@", refreshToken);
			MRYIPCCenter* center = [MRYIPCCenter centerNamed:@"com.iosrouter.headersaver"];
			NSArray *currentQueue = [center callExternalMethod:@selector(currentQueue) withArguments:nil];
			if (currentQueue != nil) {
				//if ([currentQueue containsObject:activeContainer]) {
				//	[center callExternalMethod:@selector(openContainer:) withArguments:@[activeContainer]];
				//} else {
				//	[center callExternalMethod:@selector(saveHeader:forContainer:) withArguments:@[getRefreshTokenFromKeychain(), activeContainer]];
				//}
				if (refreshToken == nil) {
					refreshToken = @"INVALID";
				}
				[center callExternalMethod:@selector(saveHeader:forContainer:) withArguments:@[refreshToken, currentQueue[0]]];
				[center callExternalMethod:@selector(openContainer:) withArguments:currentQueue[0]];

			}
		} @catch (NSException *exception) {
			NSLog(@"iosrouter Error: %@", exception);
		}
		
	}
}