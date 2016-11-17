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

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    // MARK: Properties
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
        let userScript = WKUserScript(
            source: "redHeader()",
            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
            forMainFrameOnly: true
        )
        contentController.addUserScript(userScript)
        contentController.add(
            self,
            name: "getOneSignalId"
        )
        contentController.add(
            self,
            name: "enableNotifications"
        )
        contentController.add(
            self,
            name: "disableNotifications"
        )
        
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
        
//        let url = URL(string: "https://memorydeck.herokuapp.com/sessions")!
        let url = URL(string: "http://192.168.1.83:5000/sessions")!
        _browser.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        if(message.name == "getOneSignalId") {
            print("JavaScript requested one signal id: \(OneSignal.app_id())")
            _browser.evaluateJavaScript("setOneSignalId(\(OneSignal.app_id()))")
        } else if (message.name == "enableNotifications") {
            print("JavaScript requested to enable notifications")
        } else if (message.name == "disableNotifications") {
            print("JavaScript requested to disable notifications")
        }
    }
}
