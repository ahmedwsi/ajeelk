//
//  AppDelegate.swift
//  Truckers
//
//  Created by Ala'a Amerkani on 5/21/17.
//  Copyright © 2017 WARAQAT. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications


let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate

let appRedColor         = UIColor.init(red: 220/255, green: 20/255, blue: 60/255, alpha: 1.0)
let appGreenColor       = UIColor.init(red: 12/255, green: 177/255, blue: 155/255, alpha: 1.0)
let appLightGreenColor  = UIColor.init(red: 149/255, green: 201/255, blue: 64/255, alpha: 1.0)

var user: NSDictionary?

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    override init() {
        FirebaseApp.configure()
    }

    // boolean to check is erroView is currently showing or not
    var infoViewIsShowing = false
    var indicator = UIActivityIndicatorView()

    
    func addIndicator(){
        indicator = UIActivityIndicatorView(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.size.width, height:UIScreen.main.bounds.height)) as UIActivityIndicatorView
        //  indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        indicator.backgroundColor = UIColor.black
        indicator.alpha = 0.75
    }
    
    func showIndicator(){
        //show the Indicator
        indicator.startAnimating()
        window?.rootViewController?.view .addSubview(indicator)
        
    }
    
  
    
    func hideIndicator(){
        //Hide the Indicator
        indicator.stopAnimating()
        indicator.removeFromSuperview()
    }
    
    // infoView view on top
    func infoView(message:String, color:UIColor) {
        
        // if infoView is not showing ...
        if infoViewIsShowing == false {
            
            // cast as infoView is currently showing
            infoViewIsShowing = true
            
            
            // infoView - green background
            let infoView_Height = self.window!.bounds.height / 14.2
            let infoView_Y = 0 - infoView_Height
            
            let infoView = UIView(frame: CGRect(x: 0, y: (self.window!.bounds.height) / 2, width: 250, height: 60))
            infoView.center =  (self.window?.center)!
            infoView.backgroundColor = color
            infoView.layer.cornerRadius = 15.0

            self.window!.addSubview(infoView)
            
            
            // infoView - label to show info text
            let infoLabel_Width = infoView.bounds.width
            let infoLabel_Height = infoView.bounds.height + UIApplication.shared.statusBarFrame.height / 2
            
            let infoLabel = UILabel()
            infoLabel.frame.size.width = infoLabel_Width
            infoLabel.frame.size.height = infoLabel_Height
            infoLabel.numberOfLines = 0
            
            infoLabel.text = message
            infoLabel.font = UIFont(name: "GE SS Two", size: 13)
            infoLabel.textColor = .white
            infoLabel.textAlignment = .center
            
            infoView.addSubview(infoLabel)
            
            
            // animate info view
            UIView.animate(withDuration: 0.2, animations: {
                
                // move down infoView
                infoView.frame.origin.y = (self.window!.bounds.height) / 2
                
                // if animation did finish
            }, completion: { (finished:Bool) in
                
                // if it is true
                if finished {
                    
                    UIView.animate(withDuration: 0.1, delay: 3, options: .curveLinear, animations: {
                        
                        // move up infoView
                        infoView.frame.origin.y = infoView_Y
                        
                        // if finished all animations
                    }, completion: { (finished:Bool) in
                        
                        if finished {
                            infoView.removeFromSuperview()
                            infoLabel.removeFromSuperview()
                            self.infoViewIsShowing = false
                        }
                        
                    })
                    
                }
                
            })
            
            
        }
        
    }
   
    
    // func to pass to home page ro to tabBar
    func login() {
        
        // refer to our Main.storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // store our tabBar Object from Main.storyboard in tabBar var
        let taBar = storyboard.instantiateViewController(withIdentifier: "tabBar")
        
        // present tabBar that is storing in tabBar var
        window?.rootViewController = taBar
        
    }
    //circle image
    
    func circularImage(photoImageView: UIImageView?)
    {
        photoImageView!.layer.frame = photoImageView!.layer.frame.insetBy(dx: 0, dy: 0)
        photoImageView!.layer.borderColor = UIColor.clear.cgColor
        photoImageView!.layer.cornerRadius = photoImageView!.frame.height/2
        photoImageView!.layer.masksToBounds = false
        photoImageView!.clipsToBounds = true
        photoImageView!.layer.borderWidth = 0.5
        photoImageView!.contentMode = UIViewContentMode.scaleAspectFill
    }
    
    // func to pass to home page ro to tabBar
    func redirect() {
        
        // refer to our Main.storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // store our tabBar Object from Main.storyboard in tabBar var
        let taBar = storyboard.instantiateViewController(withIdentifier: "tabBar")
        
        // present tabBar that is storing in tabBar var
        window?.rootViewController = taBar
        
    }
    
    func preferedStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
  
        
        Thread.sleep(forTimeInterval: 3.0)
        

        addIndicator()


        if Reachability.shared.isConnectedToNetwork(){
        
        user = UserDefaults.standard.value(forKey: "parseJSON") as? NSDictionary
        UserDefaults.standard.synchronize()
            
        // if user is logged before, keep him login
        if user != nil {
            
            let id = user!["user_id"] as? String
            
            if id != nil {
                
                
               login()
                
           }
        }
            
        }else{
            
            DispatchQueue.main.async(execute: {
                appDelegate.infoView(message: "لا يوجد اتصال بالانترنت", color: appRedColor)
            })
            
        }
        
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        
        //Messaging.messaging().delegate = self as! MessagingDelegate
    
        //Messaging.messaging().isAutoInitEnabled = true

        
        UILabel.appearance().font = UIFont(name: "GE SS Two", size:  13.0)
        UITextView.appearance().font = UIFont(name: "GE SS Two", size:  13.0)
        UIButton.appearance().titleLabel?.font = UIFont(name: "GE SS Two", size: 13.0)
        UILabel.appearance().adjustsFontSizeToFitWidth = true
        UILabel.appearance().minimumScaleFactor = 0.5
        
        
        //UIButton.appearance().backgroundColor = appRedColor
        
        // load content in user var
        
        
        return true
    }

    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        
        // Print it to console
        print("APNs device token: \(deviceTokenString)")
        
        // Persist it in your backend in case it's new
    }
    // Push notification received
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        // Print notification payload data
        //print("Push notification received: \(data)")
    }
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        // print("APNs registration failed: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //let dict = userInfo["aps"] as! NSDictionary;
        //let message = dict["alert"];
        //print("%@", message);
     }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //UserDefaults.standard.synchronize()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    // Lock the orientation to Portrait mode
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.portrait.rawValue)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}


// generate random string
func randomString(length: Int) -> String {
    
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"
    let len = UInt32(letters.length)
    
    var randomString = ""
    
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    
    return randomString
}

// Lock the orientation to Landscape(Horizontal) mode
func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    return UIInterfaceOrientationMask(rawValue: UIInterfaceOrientationMask.landscape.rawValue)
}



func isValidEmailAddress(emailAddressString: String) -> Bool {
    
    var returnValue = true
    let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
    
    do {
        let regex = try NSRegularExpression(pattern: emailRegEx)
        let nsString = emailAddressString as NSString
        let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
        
        if results.count == 0
        {
            returnValue = false
        }
        
    } catch let error as NSError {
        print("invalid regex: \(error.localizedDescription)")
        returnValue = false
    }
    
    return  returnValue
}


// custome button round corners
class MyCustomButton: UIButton {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.cornerRadius = self.bounds.width / 15
        self.backgroundColor = UIColor.white
        self.tintColor = appGreenColor
        
    }
}


// custome textbox round corners
class MyCustomTextBox: UITextField {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.cornerRadius = self.bounds.width / 15
        self.layer.borderColor  = UIColor.darkGray.cgColor
        self.layer.borderWidth = 0.5
        self.layer.opacity = 0.9
        self.backgroundColor = UIColor.clear
        self.tintColor = UIColor.darkGray
        
    }
}

// custome textbox round corners
class MyCustomTextView: UITextView {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.layer.cornerRadius = self.bounds.width / 15
        self.layer.borderColor  = UIColor.darkGray.cgColor
        self.layer.borderWidth = 0.5
        self.backgroundColor = UIColor.clear
        self.tintColor = UIColor.darkGray
        self.textColor = UIColor.darkGray
        
    }
}


/// text field style

@IBDesignable
class DesignableUITextField: UITextField {
    @IBInspectable var leftPadding: CGFloat = 0
    
    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            leftImage?.withRenderingMode(.alwaysTemplate)
            
            updateView()
            
            setBottomBorder(borderColor: UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0))
            
        }
    }
    
    
    
    
    @IBInspectable var color: UIColor = UIColor.white {
        didSet {
            updateView()
            setBottomBorder(borderColor: UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0))
        }
    }
    
    func setBottomBorder(borderColor: UIColor)
    {
        
        self.borderStyle = UITextBorderStyle.none
        self.backgroundColor = UIColor.clear
        let width = 0.5
        
        let borderLine = UIView()
        borderLine.frame = CGRect(x: 0, y: Double(self.frame.height) - width, width: Double(self.frame.width), height: width)
        
        borderLine.backgroundColor = borderColor
        self.addSubview(borderLine)
    }
    
    func updateView() {
        if let image = leftImage {
            leftViewMode = UITextFieldViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.image = image
            
            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
            imageView.tintColor = UIColor.white
            
            leftView = imageView
        } else {
            leftViewMode = UITextFieldViewMode.never
            leftView = nil
        }
        
        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSForegroundColorAttributeName: color])
    }
    
}

