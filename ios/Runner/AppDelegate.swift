import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Read Maps API key from Info.plist → GOOGLE_MAPS_IOS_API_KEY
    // To update the key: change the value in ios/Runner/Info.plist only.
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_IOS_API_KEY") as? String {
      GMSServices.provideAPIKey(apiKey)
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
