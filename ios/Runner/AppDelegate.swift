import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let zipChannel = FlutterMethodChannel(name: "com.example.app/zip", binaryMessenger: controller.binaryMessenger)
        
        zipChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "createPasswordProtectedZip" {
                guard let args = call.arguments as? [String: Any],
                      let filePaths = args["filePaths"] as? [String],
                      let password = args["password"] as? String,
                      let outputPath = args["outputPath"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
                    return
                }
                createPasswordProtectedZip(paths: filePaths, password: password, outputPath: outputPath, result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}