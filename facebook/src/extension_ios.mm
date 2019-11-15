#if defined(DM_PLATFORM_IOS)

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#include "extension.h"

#import "ios/utils.h"

#define ExtensionInterface FUNCTION_NAME_EXPANDED(EXTENSION_NAME, ExtensionInterface)

// Using proper Objective-C object for main extension entity.
@interface ExtensionInterface : NSObject
@end

@implementation ExtensionInterface {
	bool is_initialized;
}

static ExtensionInterface *extension_instance;
int EXTENSION_INIT(lua_State *L) {return [extension_instance init_:L];}
int EXTENSION_TRACK_EVENT(lua_State *L) {return [extension_instance track_event:L];}

-(id)init:(lua_State*)L {
	self = [super init];

	is_initialized = false;

	return self;
}

-(bool)check_is_initialized {
	if (is_initialized) {
		return true;
	} else {
		dmLogInfo("The extension is not initialized.");
		return false;
	}
}

# pragma mark - Lua functions -

-(int)init_:(lua_State*)L {
	[Utils check_arg_count:L count:1];
	if (is_initialized) {
		dmLogInfo("The extension is already initialized.");
		return 0;
	}

	Scheme *scheme = [[Scheme alloc] init];
	[scheme string:@"api_key"];

	Table *params = [[Table alloc] init:L index:1];
	[params parse:scheme];

	bool auto_log_app_events = false;
	bool advertiser_id_collection = false;

	if (lua_istable(L, 1)) {
		Scheme *scheme = [[Scheme alloc] init];
		[scheme boolean:@"auto_log_app_events"];
		[scheme boolean:@"advertiser_id_collection"];

		Table *params = [[Table alloc] init:L index:1];
		[params parse:scheme];
		auto_log_app_events = [params get_boolean:@"auto_log_app_events" default:false];
		advertiser_id_collection = [params get_boolean:@"advertiser_id_collection" default:false];
	}

	if (!is_initialized) {
		is_initialized = true;
		[FBSDKSettings setAutoLogAppEventsEnabled:auto_log_app_events];
		[FBSDKSettings setAdvertiserIDCollectionEnabled:advertiser_id_collection];
		[FBSDKSettings setAutoInitEnabled:true];

		[FBSDKAppEvents activateApp];
	}

	is_initialized = true;

	return 0;
}

-(int)track_event:(lua_State*)L {
	[Utils check_arg_count:L count:1];
	if (![self check_is_initialized]) {
		return 0;
	}

	Scheme *scheme = [[Scheme alloc] init];
	[scheme string:@"name"];
	[scheme number:@"value"];
	[scheme table:@"params"];
	[scheme any:@"params.*"];

	Table *params = [[Table alloc] init:L index:1];
	[params parse:scheme];
	NSString *name = [params get_string_not_null:@"name"];
	NSNumber *value = [params get_double:@"value"];
	NSDictionary *extra_params = [params get_table:@"params"];

	if (extra_params != nil) {
		if (value != nil) {
			[FBSDKAppEvents logEvent:name valueToSum:value.doubleValue parameters:extra_params];
		} else {
			[FBSDKAppEvents logEvent:name parameters:extra_params];
		}
	} else if (value != nil) {
		[FBSDKAppEvents logEvent:name valueToSum:value.doubleValue];
	} else {
		[FBSDKAppEvents logEvent:name];
	}

	return 0;
}

@end

#pragma mark - Defold lifecycle -

void EXTENSION_INITIALIZE(lua_State *L) {
	extension_instance = [[ExtensionInterface alloc] init:L];
}

void EXTENSION_UPDATE(lua_State *L) {
	[Utils execute_tasks:L];
}

void EXTENSION_APP_ACTIVATE(lua_State *L) {
}

void EXTENSION_APP_DEACTIVATE(lua_State *L) {
}

void EXTENSION_FINALIZE(lua_State *L) {
    extension_instance = nil;
}

#endif
