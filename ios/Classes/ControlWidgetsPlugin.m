#import "ControlWidgetsPlugin.h"
#if __has_include(<control_widgets/control_widgets-Swift.h>)
#import <control_widgets/control_widgets-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "control_widgets-Swift.h"
#endif

@implementation ControlWidgetsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftControlWidgetsPlugin registerWithRegistrar:registrar];
}
@end
