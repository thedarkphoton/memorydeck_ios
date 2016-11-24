//
//  ViewController.swift
//  memorydeck
//
//  Created by dovydas on 15/11/2016.
//  Copyright © 2016 dovydas. All rights reserved.
//

import UIKit
import WebKit
import OneSignal
import Gloss

struct OneSignalData: Decodable {
    let oneSignalId: String?
    let iOSPushId: String?
    
    init?(json: JSON) {
        self.oneSignalId = "oneSignalId" <~~ json
        self.iOSPushId = "iOSPushId" <~~ json
    }
}

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    // MARK: Properties
    // let _domain = "https://memorydeck.herokuapp.com/"
    let _domain = "http://192.168.1.83:5000/"
    var _oneSignalId: String!
    var _iOSPushId: String!
    var _browser: WKWebView!
    @IBOutlet var _back: UISwipeGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        UIApplication.shared.statusBarStyle = .lightContent
        view.backgroundColor = UIColor.init(red: 0.4745, green: 0.5254, blue: 0.796, alpha: 1)
    
        initBrowser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Browser
    func initBrowser() {
        let contentController = WKUserContentController();
        contentController.add(self, name: "getOneSignalId")
        contentController.add(self, name: "enableNotifications")
        contentController.add(self, name: "disableNotifications")
        contentController.add(self, name: "updateSession")
        contentController.add(self, name: "log")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        _browser = WKWebView(frame: view.frame, configuration: config)
        _browser.customUserAgent = "App (iOS 0.0.1)"
        _browser.translatesAutoresizingMaskIntoConstraints = false
        _browser.navigationDelegate = self
        view.addSubview(_browser)
        
        let leadingConstraint = NSLayoutConstraint(item: _browser, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: _browser, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: _browser, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: _browser, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
        
        let url = URL(string: "\(_domain)sessions")!
        _browser.load(getMutableRequest(url: url) as URLRequest)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "getOneSignalId") {
            getOneSignalId()
        } else if (message.name == "enableNotifications") {
            print("JS INTERFACE: notifications enabled")
            OneSignal.setSubscription(true)
        } else if (message.name == "disableNotifications") {
            print("JS INTERFACE: notifications disabled")
            OneSignal.setSubscription(false)
        } else if (message.name == "updateSession") {
            let pref = UserDefaults.standard
            pref.set(message.body, forKey: "session")
            if !pref.synchronize() {
                print("SESSION: data failed to save to preferences")
            }
            print("JS INTERFACE: Client side update session")
        } else if (message.name == "log") {
            print("JS INTERFACE: \(message.body)")
        }
    }

    func getMutableRequest(url: URL) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: url)
        let pref = UserDefaults.standard
        
        if let json_string = pref.object(forKey: "session") as! String! {
            if let data = json_string.data(using: String.Encoding.utf8) {
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:String]
                for (key, value) in json! {
                    request.addValue("\(key)=\(value)", forHTTPHeaderField: "Cookie")
                }
            }
        }
        
        return request
    }
    
    func getOneSignalId() {
        let pref = UserDefaults.standard
        
        if pref.object(forKey: "oneSignal") == nil {
            print("ONE SIGNAL: id was not found in preferences, acquiring id...")
            OneSignal.idsAvailable({ (userId, pushToken) in
                var oneSignalId = ""
                var iOSPushId = ""
                
                oneSignalId = userId!;
                if (pushToken != nil) {
                    iOSPushId = pushToken!
                }
                
                let json = jsonify([
                    "oneSignalId" ~~> oneSignalId,
                    "iOSPushId" ~~> iOSPushId
                    ])
                
                pref.set(json, forKey: "oneSignal")
                if !pref.synchronize() {
                    print("ONE SIGNAL: data failed to save to preferences")
                }
                
                print("ONE SIGNAL: ... id acquired: \(oneSignalId)")
                self._browser.evaluateJavaScript("setOneSignalId('\(oneSignalId)')")
            })
        } else {
            if let json = pref.object(forKey: "oneSignal") as! JSON! {
                let oneSignalData = OneSignalData(json: json)!
                let oneSignalId = oneSignalData.oneSignalId!
                let iOSPushId = oneSignalData.iOSPushId!
                
                print("ONE SIGNAL: id found in preferences: \(oneSignalId)")
                print("ONE SIGNAL: iOS push id: \(iOSPushId)")
                _browser.evaluateJavaScript("setOneSignalId('\(oneSignalId)')")
            } else {
                print("ONE SIGNAL: There was an error retrieving data from preferences")
            }
        }
    }
}
