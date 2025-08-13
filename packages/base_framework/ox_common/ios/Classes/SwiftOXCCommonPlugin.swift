import Flutter
import UIKit
import MobileCoreServices
import Foundation
import Photos

public class SwiftOXCCommonPlugin: NSObject, FlutterPlugin, UINavigationControllerDelegate {
    
    private var channel: FlutterMethodChannel?
    
    lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        return imagePicker
    }()
    
    var result:FlutterResult?
    
    init(channel: FlutterMethodChannel? = nil, result: FlutterResult? = nil) {
        super.init()
        self.channel = channel
        self.result = result
        backgroundCoordinatorInitialized()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ox_common", binaryMessenger: registrar.messenger())
        let instance = SwiftOXCCommonPlugin(channel: channel)
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.result = result
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "getImageFromCamera":
            do {
                let params = call.arguments as? [String : Any]
                var allowEditing = false
                if let isNeedTailor = params?["isNeedTailor"] as? Bool {
                    allowEditing = isNeedTailor
                }
                getImageFromCamera(allowEditing: allowEditing)
            }
            break
        case "getImageFromGallery":
            do {
                let params = call.arguments as? [String : Any]
                var allowEditing = false
                if let isNeedTailor = params?["isNeedTailor"] as? Bool {
                    allowEditing = isNeedTailor
                }
                getImageFromGallery(allowEditing: allowEditing)
            }
            break
        case "getVideoFromCamera":
            getVideoFromCamera()
            
        case "getCompressionImg":
            do {
                let params = call.arguments as? [String : Any]
                guard let filePath = params?["filePath"] as? String else {
                    return result(nil)
                }
                
                guard let quality = params?["quality"] as? Int else {
                    return result(filePath)
                }
                getCompressionImg(filePath: filePath, quality: quality,result: result)
            }
            break;
        case "saveImageToGallery":
            saveImageToGallery(call.arguments as? [String:Any], result: result)
        case "callIOSSysShare":
            callIOSSysShare(call.arguments as? [String:Any], result: result)
        case "getDeviceId":
            getDeviceId(result: result)
        case "getPickerPaths":
            OXCImagePickerHelper.getPickerPaths(params: call.arguments as? [String : Any], result: result)
        case "scan_path":
            guard let path = (call.arguments as? [String: String])?["path"] else { 
                result("")
                return
            }
            if let features = OXCQRCodeHelper.detectQRCode(UIImage.init(contentsOfFile: path)), 
                let data = features.first as? CIQRCodeFeature {
                result(data.messageString);
            } else {
                OXCQRCodeHelper.detectBarCode(UIImage.init(contentsOfFile: path), result: result)
            }
            break;
        case "exportFile":
            guard let controller = UIApplication.shared.delegate?.window??.rootViewController else {
                return
            }
            guard let filePath = (call.arguments as? [String: String])?["filePath"] else {
                return
            }
            OXCFileHelper.exportFile(atPath: filePath, sender: controller) { _ in }
        case "importFile":
            guard let controller = UIApplication.shared.delegate?.window??.rootViewController else {
                result("")
                return
            }
            OXCFileHelper.importFile(sender: controller) { filePath in
                result(filePath)
            }
        case "hasImages":
            result(ClipboardHelper.hasImages())
        case "getImages":
            result(ClipboardHelper.getImages())
        case "copyImageToClipboard":
            guard let imagePath = (call.arguments as? [String: String])?["imagePath"] else {
                result(false)
                return
            }
            result(ClipboardHelper.copyImageToClipboard(imagePath: imagePath))
        case "registeNotification":
            registeNotification()
            result(nil)
        default:
            break;
        }
    }
    
    
}

extension SwiftOXCCommonPlugin: FlutterApplicationLifeCycleDelegate {
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
        IMBackgroundCoordinator.shared.handleSilentPush(userInfo: userInfo, fetchCompletionHandler: completionHandler)
        return true
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenStr = deviceToken.map { String(format: "%02.2hhx", arguments: [$0]) }.joined()
        print(deviceTokenStr)
        savePushToken(token: deviceTokenStr)
    }
    
    public func applicationDidEnterBackground(_ application: UIApplication) {
        IMBackgroundCoordinator.shared.applicationDidEnterBackground()
    }
}

// MARK: - Push
extension SwiftOXCCommonPlugin {
    private func savePushToken(token: String) {
        channel?.invokeMethod("savePushToken", arguments: token)
    }
    
    private func registeNotification() -> Void {
        if #available(iOS 10.0, *) {
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.delegate = self
            notificationCenter.requestAuthorization(options:[.sound, .alert, .badge]) { (granted, error) in
                if (granted) {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    
                }
            }
        }
        else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings.init(types: [.sound, .alert, .badge], categories: nil))
        }
    }
}

// MARK: - Private tools
extension SwiftOXCCommonPlugin {
    private func backgroundCoordinatorInitialized() {
        IMBackgroundCoordinator.shared.configure(
            with: .init(
                bgRefreshIdentifier: "com.xchat.app.refresh",
                bgProcessingIdentifier: "com.xchat.app.processing",
                urlSessionIdentifier: "com.xchat.app.bgtransfer"
            )
        )
    }
    
    private func getDeviceId(result:FlutterResult) {
        if let uuid = UserDefaults.standard.string(forKey: "com.ox.super_main.uuid") {
            result(uuid)
        }
        else {
            let uuid = UIDevice.current.identifierForVendor?.uuidString ?? NSUUID.init().uuidString
            UserDefaults.standard.set(uuid, forKey: "com.ox.super_main.uuid")
            UserDefaults.standard.synchronize()
            result(uuid)
        }
    }
    
    private func getImageFromCamera(allowEditing: Bool) {
        DispatchQueue.main.async {
            self.imagePicker.mediaTypes = [kUTTypeImage as String]
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = allowEditing
            UIApplication.shared.delegate?.window??.rootViewController?.present(self.imagePicker, animated: true, completion: {
                
            });
        }
    }
    
    private func getImageFromGallery(allowEditing: Bool) {
        DispatchQueue.main.async {
            self.imagePicker.mediaTypes = [kUTTypeImage as String]
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = allowEditing
            UIApplication.shared.delegate?.window??.rootViewController?.present(self.imagePicker, animated: true, completion: {
                
            });
        }
    }
    
    private func getVideoFromCamera() {
        DispatchQueue.main.async {
            self.imagePicker.mediaTypes = [kUTTypeMovie as String]
            self.imagePicker.sourceType = .camera
            self.imagePicker.cameraDevice = .front
            UIApplication.shared.delegate?.window??.rootViewController?.present(self.imagePicker, animated: true, completion: {
                
            });
        }
    }
    
    private func getCompressionImg(filePath:String, quality:Int, result: @escaping FlutterResult) {
        guard let image = UIImage.init(contentsOfFile: filePath) else {
            return result(nil)
        }
        let data = image.jpegData(compressionQuality: CGFloat(quality<0 ? 100 : quality)/100.0)
        let guid = ProcessInfo.processInfo.globallyUniqueString
        let tmpFile = "image_picker_\(guid).jpg"
        let tmpDirectory = NSTemporaryDirectory()
        let tmpPath = tmpDirectory.appending(tmpFile)
        if (FileManager.default.createFile(atPath: tmpPath, contents: data, attributes: nil)) {
            result(tmpPath)
        }
        else {
            result(nil)
        }
    }
    
    private func saveImageToGallery(_ params:[String:Any]?,result:@escaping FlutterResult) {
        guard let param = params else {
            result("")
            return
        }
        
        guard let data = param["imageBytes"] as? FlutterStandardTypedData else {
            result("")
            return
        }
        
        guard  let image = UIImage.init(data: data.data) else {
            result("")
            return
        }
        
        var localIdentifier = ""
        PHPhotoLibrary.shared().performChanges {
            localIdentifier = PHAssetChangeRequest.creationRequestForAsset(from: image).placeholderForCreatedAsset?.localIdentifier ?? ""
        } completionHandler: { (success, error) in
            if success {
                let res = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil);
                guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil).lastObject else {
                    result("")
                    return
                }
                PHImageManager.default().requestImageData(for: asset, options: nil) { (_, url, _, info) in
                    result("save success")
                }
            }
            else {
                result("")
            }
        };
    }
    
    private func callIOSSysShare(_ params:[String:Any]?,result:@escaping FlutterResult) {
        guard let param = params else {
            result("")
            return
        }
        
        guard let data = param["imageBytes"] as? FlutterStandardTypedData else {
            result("")
            return
        }
        
        guard  let image = UIImage.init(data: data.data) else {
            result("")
            return
        }
        
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        UIApplication.shared.delegate?.window??.rootViewController?.present(activity, animated: true, completion: {
            
        });
    }
    
    
    private func _nromalizedImage(image:UIImage) -> UIImage?{
        if image.imageOrientation == .up {
            return image
        }
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect.init(x: 0, y: 0, width: image.size.width, height: image.size.height))
        guard let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        return normalizedImage
    }
    
    private func _scaled(image:UIImage, maxWidth:Double, maxHeight: Double) -> UIImage? {
        let originWidth = Double(image.size.width)
        let originHeight = Double(image.size.height)
        
        let hasMaxWidth = maxWidth != 0.0
        let hasMaxHeight = maxHeight != 0.0
        
        var width = hasMaxWidth ? Double.minimum(maxWidth,originWidth) : originWidth
        var height = hasMaxHeight ? Double.minimum(maxHeight, originHeight) : originHeight
        
        let shouldDownScaleWidth = hasMaxWidth && maxWidth < originWidth
        let shouldDownScaleHeight = hasMaxHeight && maxHeight < originHeight
        let shouldDownScale = shouldDownScaleWidth || shouldDownScaleHeight
        if shouldDownScale {
            let downScaleWidth = floor((height / originHeight) * originWidth)
            let downScaleHeight = floor((width / originWidth) * originHeight)
            
            if (width < height) {
                if (!hasMaxWidth) {
                    width =  downScaleWidth
                }
                else {
                    height = downScaleHeight
                }
            }
            else if (height < width) {
                if(!hasMaxHeight) {
                    height = downScaleHeight
                }
                else {
                    width = downScaleWidth
                }
            }
            else {
                if originWidth < originHeight {
                    width = downScaleWidth
                }
                else {
                    height = downScaleHeight
                }
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize.init(width: CGFloat(width), height: CGFloat(height)), false, 1.0)
        image.draw(in: CGRect.init(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        guard let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        return normalizedImage
    }
}

extension SwiftOXCCommonPlugin: UIImagePickerControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        UIApplication.shared.delegate?.window??.rootViewController?.dismiss(animated: true, completion: nil)
        if let result = result {
            result(nil)
        }
        result = nil
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let mediaType = info[.mediaType] as? String else {
            UIApplication.shared.delegate?.window??.rootViewController?.dismiss(animated: true, completion: nil)
            return
        }
        
        if mediaType.contains(kUTTypeImage as String) {
            if let image = info[.editedImage] as? UIImage {
                self._dealData(image: image, completion: {(success, filePath) in
                    guard let result = self.result else {
                        UIApplication.shared.delegate?.window??.rootViewController?.dismiss(animated: true, completion: nil)
                        return
                    }
                    if success {
                        result(filePath)
                    }
                    else {
                        result(nil)
                    }
                    
                    UIApplication.shared.delegate?.window??.rootViewController?.dismiss(animated: true, completion: nil)
                })
                return
            }
            
            if let image = info[.originalImage] as? UIImage {
                self._dealData(image: image, completion: { (success, filePath) in
                    guard let result = self.result else {
                        UIApplication.shared.delegate?.window??.rootViewController?.dismiss(animated: true, completion: nil)
                        return
                    }
                    
                    if success {
                        result(filePath)
                    }
                    else {
                        result(nil)
                    }
                    UIApplication.shared.delegate?.window??.rootViewController?.dismiss(animated: true, completion: nil)
                })
                return
            }
            
            guard let result = self.result else {
                UIApplication.shared.delegate?.window??.rootViewController?.dismiss(animated: true, completion: nil)
                return
            }
            result(nil)
            UIApplication.shared.delegate?.window??.rootViewController?.dismiss(animated: true, completion: nil)
            
        }
        else if mediaType.contains(kUTTypeVideo as String) {
            guard let mediaUrl = info[.mediaURL] as? URL else {
                UIApplication.shared.delegate?.window??.rootViewController?.dismiss(animated: true, completion: nil)
                result = nil
                return
            }
            
            guard let result = self.result else {
                UIApplication.shared.delegate?.window??.rootViewController?.dismiss(animated: true, completion: nil)
                return
            }
            result(mediaUrl.path)
        }
        
        result = nil
        UIApplication.shared.delegate?.window??.rootViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    func _dealData(image:UIImage, completion:@escaping((_ success: Bool,_ filePath: String?) -> Void)) {
        
        guard let norimalImage = self._nromalizedImage(image:image) else {
            completion(false, nil)
            return
        }
        
        let scale = UIScreen.main.scale
        guard  let scaleimage = self._scaled(image: norimalImage, maxWidth: Double(UIScreen.main.bounds.size.width * scale), maxHeight: Double(UIScreen.main.bounds.size.height * scale)) else {
            completion(false, nil)
            return
        }
        
        let data = scaleimage.jpegData(compressionQuality: 1.0)
        let guid = ProcessInfo.processInfo.globallyUniqueString
        let tmpFile = "image_picker_\(guid).jpg"
        let tmpDirectory = NSTemporaryDirectory()
        let tmpPath = tmpDirectory.appending(tmpFile)
        if (FileManager.default.createFile(atPath: tmpPath, contents: data, attributes: nil)) {
            completion(true, tmpPath)
        }
        else {
            completion(false, nil)
        }
    }
}
