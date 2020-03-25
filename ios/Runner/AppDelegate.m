#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (id)init {
    
    self = [super init];
    
    if (self) {
        engine = [[CChessEngine alloc] init];
    }
    
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [GeneratedPluginRegistrant registerWithRegistry:self];
    
    FlutterViewController* controller = (FlutterViewController*) self.window.rootViewController;
    
    /// Chinese Chess Engine
    
    FlutterMethodChannel* engineChannel = [FlutterMethodChannel
                                           methodChannelWithName:@"cn.apppk.chessroad/engine"
                                           binaryMessenger:controller.binaryMessenger];
    
    __weak CChessEngine* weakEngine = engine;
    
    [engineChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        
        if ([@"startup" isEqualToString:call.method]) {
            result(@([weakEngine startup: controller]));
        }
        else if ([@"send" isEqualToString:call.method]) {
            result(@([weakEngine send: call.arguments]));
        }
        else if ([@"read" isEqualToString:call.method]) {
            result([weakEngine read]);
        }
        else if ([@"shutdown" isEqualToString:call.method]) {
            result(@([weakEngine shutdown]));
        }
        else if ([@"isReady" isEqualToString:call.method]) {
            result(@([weakEngine isReady]));
        }
        else if ([@"isThinking" isEqualToString:call.method]) {
            result(@([weakEngine isThinking]));
        }
        else {
            result(FlutterMethodNotImplemented);
        }
    }];
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
