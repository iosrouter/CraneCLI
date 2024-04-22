#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#import <Foundation/Foundation.h>
#import <libCrane.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <rootless.h>
@import ObjectiveC.runtime;

@interface UIApplication (Private)
- (BOOL)launchApplicationWithIdentifier:(NSString *)identifier suspended:(BOOL)suspended;
@end
//// run this function to access the CraneManager class from processes other than SpringBoard
//__attribute__ ((unused)) static void loadLibCrane()
//{
//	dlopen("/usr/lib/libcrane.dylib", RTLD_NOW);
//}
//
//// make a class that conforms to this protocol and add it to CraneManager using the addObserver: method
//@protocol CraneManagerObserver
//
//@optional
//- (void)didChangeRootSettings;
//- (void)didChangeSettingsForApplicationWithIdentifier:(NSString*)applicationID;
//- (void)didChangeContainersOfApplicationWithIdentifier:(NSString*)applicationID;
//- (void)didChangeContainerSettingsForContainerWithIdentifier:(NSString*)containerID onApplicationWithIdentifier:(NSString*)applicationID;
//
//@end
//
//typedef NS_ENUM(NSInteger, ContainerPathType) {
//    ContainerPathTypeApp,
//    ContainerPathTypeGroup,
//	ContainerPathTypePlugin
//};
//
//@interface CraneManager : NSObject
//
//+ (instancetype)sharedManager;
//
//// prefs
//- (NSDictionary*)preferencesCopy;
//- (void)setPreferenceValue:(id)value forKey:(NSString*)key;
//- (void)removePreferenceValueForKey:(NSString*)key;
//- (id)preferenceValueForKey:(NSString*)key;
//
//// observers
//- (void)addObserver:(NSObject<CraneManagerObserver>*)observer;
//- (void)removeObserver:(NSObject<CraneManagerObserver>*)observer;
//
//// app settings
//- (BOOL)isApplicationSupportedByCrane:(NSString*)applicationID;
//- (NSArray*)identfiersOfApplicationsThatHaveNonDefaultContainers;
//- (NSArray*)identifiersOfAllSupportedApplications;
//- (NSString*)displayNameForApplicationWithIdentifier:(NSString*)applicationID;
//- (NSDictionary*)applicationSettingsForApplicationWithIdentifier:(NSString*)applicationID;
//- (void)setApplicationSettings:(NSDictionary*)appSettings forApplicationWithIdentifier:(NSString*)applicationID;
//- (NSString*)activeContainerIdentifierForApplicationWithIdentifier:(NSString*)applicationID;
//- (void)setActiveContainerIdentifier:(NSString*)containerID forApplicationWithIdentifier:(NSString*)applicationID; // does not respect biometric protection setting
//- (void)setActiveContainerIdentifier:(NSString*)containerID forApplicationWithIdentifier:(NSString*)applicationID usingBiometricsIfNeededWithSuccessHandler:(void (^)(BOOL))successHandler; //respects biometric protection setting and does authentication if neccessary
//- (NSArray*)containerIdentifiersOfApplicationWithIdentifier:(NSString*)applicationID;
//
//// container management
//- (void)createNewContainerWithName:(NSString*)containerName andIdentifier:(NSString*)containerID forApplicationWithIdentifier:(NSString*)applicationID;
//- (NSString*)createNewContainerWithName:(NSString*)containerName forApplicationWithIdentifier:(NSString*)applicationID; // returns containerIdentifier
//- (void)deleteContainerWithIdentifier:(NSString*)containerID forApplicationWithIdentifier:(NSString*)applicationID;
//- (void)wipeContainerWithIdentifier:(NSString*)containerIdD forApplicationWithIdentifier:(NSString*)applicationID shouldRepopulate:(BOOL)repopulate;
//- (NSString*)makeDefaultForContainerWithIdentifier:(NSString*)containerID forApplicationWithIdentifier:(NSString*)applicationID;
//
//// containers settings
//- (NSDictionary*)containerSettingsForContainerWithIdentifier:(NSString*)containerID ofApplicationWithIdentifier:(NSString*)applicationID;
//- (void)setContainerSettings:(NSDictionary*)containerSettings forContainerWithIdentifier:(NSString*)containerID ofApplicationWithIdentifier:(NSString*)applicationID;
//- (void)enumerate:(void (^)(ContainerPathType type, NSString* identifier, NSString* path))block pathsAssociatedToContainerWithIdentifier:(NSString*)containerID ofApplicationWithIdentifier:(NSString*)applicationID;
//- (NSDictionary*)pathsAssociatedToContainerWithIdentifier:(NSString*)containerID ofApplicationWithIdentifier:(NSString*)applicationID;
//- (void)sizeOccupiedByContainerWithIdentifier:(NSString*)containerID ofApplicationWithIdentifier:(NSString*)applicationID completionHandler:(void (^)(uint64_t))completionHandler;
//- (NSString*)displayNameForContainerWithName:(NSString*)containerName isDefaultContainer:(BOOL)isDefault shouldUseShortVersion:(BOOL)shortVersion;
//- (NSString*)displayNameForContainerWithIdentifier:(NSString*)containerID ofApplicationWithIdentifier:(NSString*)applicationID shouldUseShortVersion:(BOOL)shortVersion;
//
//// name to display in notifications
//- (NSString*)displayNameForContainerInNotificationWithIdentifier:(NSString*)containerID ofApplicationWithIdentifier:(NSString*)applicationID;
//- (NSString*)containerNameToDisplayInNotificationWithUserInfoOrContext:(NSDictionary*)userInfoOrContext ofApplicationWithIdentifier:(NSString*)applicationID;
//
//// SpringBoard
//- (void)flushCFPrefsdCacheForApplicationWithIdentifier:(NSString*)applicationID;
//- (void)reloadApplicationWithIdentifier:(NSString*)applicationID;
//
//@end

static void cliPrintHelp() {
	printf("Usage: crane-cli [options]\n");
	printf("Options:\n");
	printf("  -c <name> <appID> OPT:<containerID> Create a new container\n");
	printf("  -l List all applications with non-default containers\n");
	printf("  -d <appID> <containerID> Delete a specified container for an application\n");
	printf("  -h Print this help message\n");
	printf("  -o <appID> <containerID> Open app with active container\n");
	printf("  Created by iosrouter.\n");
}





int main(int argc, char *argv[]) {
	@autoreleasepool {
		loadLibCrane();
		CraneManager *craneManager = [objc_getClass("CraneManager") sharedManager];
		int opt;
		char *name;
		char *appID;
		char *containerID;
		NSArray *apps;
		// Thanks @YulkyTulky for the code
		if (argc == 1) {
			cliPrintHelp();
		}
		while ((opt = getopt(argc, argv, "c:ld:ho:")) != -1) {
			switch (opt) {
				case 'c':
					if (argc > 3) {
						name = argv[2];
						appID = argv[3];
						containerID = argv[4];
						if (containerID != NULL) {
							//convert to NSString
							NSString *nameString = [NSString stringWithUTF8String:name];
							NSString *appIDString = [NSString stringWithUTF8String:appID];
							NSString *containerIDString = [NSString stringWithUTF8String:containerID];
							@try {
								[craneManager createNewContainerWithName:nameString andIdentifier:containerIDString forApplicationWithIdentifier:appIDString];
								printf("crane-cli: Created container \"%s\" for app \"%s\" with ID \"%s\"\n", name, appID, containerID);
							} @catch (NSException *exception) {
								printf("%s\n", [[exception reason] UTF8String]);
							} 
						} else {
							NSString *nameString = [NSString stringWithUTF8String:name];
							NSString *appIDString = [NSString stringWithUTF8String:appID];
							@try {
								NSString *containerIDString = [craneManager createNewContainerWithName:nameString forApplicationWithIdentifier:appIDString];
								printf("crane-cli: Created container \"%s\" for app \"%s\" with ID \"%s\"\n", name, appID, [containerIDString UTF8String]);
							} @catch (NSException *exception) {
								printf("%s\n", [[exception reason] UTF8String]);
							}
						}
					} else {
						printf("Usage: crane -c <name> <appID> <containerID>\n");
					}
					break;

				case 'l':
					apps = [craneManager identfiersOfApplicationsThatHaveNonDefaultContainers];
					for (NSString *app in apps) {
						NSArray *containers = [craneManager containerIdentifiersOfApplicationWithIdentifier:app];
						for (NSString *container in containers) {
							NSString *displayName = [craneManager displayNameForContainerWithIdentifier:container ofApplicationWithIdentifier:app shouldUseShortVersion:YES];
							printf("[%s] Container: (%s: %s)\n", [app UTF8String], [displayName UTF8String], [container UTF8String]);
						}
					}
					break;
				case 'd':
					if (argc > 2) {
						appID = argv[2];
						containerID = argv[3];
						NSString *appIDString = [NSString stringWithUTF8String:appID];
						//NSString *containerIDString = [NSString stringWithUTF8String:containerID];
						//check if both argv's are greater than 1
						@try {
							NSArray *containers = [craneManager containerIdentifiersOfApplicationWithIdentifier:appIDString];
							//print all 
							printf
						} @catch (NSException *exception) {
							printf("%s\n", [[exception reason] UTF8String]);
						}
					} else {
						printf("Usage: crane -d <appID> <containerID>\n");
					}
					//JBROOT_PATH_CSTRING("/usr/lib/libcrane.dylib"
					//printf("%s\n", JBROOT_PATH_CSTRING("/usr/lib/libcrane.dylib"));
					//@try {
					//	dlopen(JBROOT_PATH_CSTRING("/usr/lib/libcrane.dylib"), RTLD_NOW);
					//	printf("crane-cli: Loaded libcrane.dylib\n");
					//} @catch (NSException *exception) {
					//	printf("%s\n", [[exception reason] UTF8String]);
					//
					//}
					break;
				case 'h':
					cliPrintHelp();
					break;
				case '?':
					exit(1);
				case 'o':
					if (argc > 2) {
						appID = argv[2];
						containerID = argv[3];
						NSString *appIDString = [NSString stringWithUTF8String:appID];
						NSString *containerIDString = [NSString stringWithUTF8String:containerID];
						@try {
							[craneManager setActiveContainerIdentifier:containerIDString forApplicationWithIdentifier:appIDString];
							[craneManager reloadApplicationWithIdentifier:appIDString];
							Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
							NSObject * workspace = [LSApplicationWorkspace_class performSelector:@selector(defaultWorkspace)];
							[workspace performSelector:@selector(openApplicationWithBundleID:) withObject:appIDString];
							printf("crane-cli: Opened app \"%s\" with container \"%s\"\n", appID, containerID);
						} @catch (NSException *exception) {
							printf("%s\n", [[exception reason] UTF8String]);
						}
					} else {
						printf("Usage: crane -o <appID> <containerID>\n");
					}
					break;
				default:
					break;
    		}
		}  
	}
}


