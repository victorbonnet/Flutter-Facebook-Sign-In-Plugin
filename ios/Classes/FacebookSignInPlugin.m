#import "FacebookSignInPlugin.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation FacebookSignInPlugin
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
  return [[FBSDKApplicationDelegate sharedInstance] application:app
    openURL:url
    sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
    annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{

  return [[FBSDKApplicationDelegate sharedInstance] application:application
    openURL:url
    sourceApplication:sourceApplication
    annotation:annotation];
}
    
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    // Add any custom logic here.
    //return [super application:application didFinishLaunchingWithOptions:launchOptions];
    return YES;
}
    
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    // controller needed to launch FBSDKLoginManager
    FlutterViewController* controller = (FlutterViewController*)[[                                                                  [[UIApplication sharedApplication]delegate] window] rootViewController];
    
    FlutterMethodChannel *channel =
    [FlutterMethodChannel methodChannelWithName:@"facebook_sign_in"
                                binaryMessenger:[registrar messenger]];
    
    [channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        if ([@"login" isEqualToString:call.method]) {
            FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
            [login
             logInWithReadPermissions: @[@"public_profile", @"email"]
             fromViewController:controller
             handler:^(FBSDKLoginManagerLoginResult *fbResult, NSError *error) {
                 if (error) {
                     result(@"Process error");
                 } else if (fbResult.isCancelled) {
                     result(@"Cancelled");
                 } else {
                     FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
                     result(token.tokenString);
                 }
             }];
        } else if ([@"checkFacebookLogin" isEqualToString:call.method]) {
            if ([FBSDKAccessToken currentAccessToken]) {
                FBSDKAccessToken *accessToken = [FBSDKAccessToken currentAccessToken];
                NSLog(@"Logged in:");
                NSLog(@"%@", accessToken);
                result(@"YES");
            } else {
                NSLog(@"not logged in");
                result(@"NO");
            }
        } else if ([@"getFacebookToken" isEqualToString:call.method]) {
            FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
            if (token) {
                result(@{@"tokenString" : token.tokenString});
            } else {
                result(nil);
            }
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
}

@end
