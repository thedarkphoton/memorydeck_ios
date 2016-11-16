//
//  ViewController.swift
//  memorydeck
//
//  Created by dovydas on 15/11/2016.
//  Copyright © 2016 dovydas. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    var _browser: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        UIApplication.shared.statusBarStyle = .lightContent
        view.backgroundColor = UIColor.init(red: 121 / 255, green: 134 / 255, blue: 203 / 255, alpha: 1)
        
        _browser = WKWebView()
        _browser.customUserAgent = "App (iOS 0.0.1)"
        _browser.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(_browser)
        
        let leadingConstraint = NSLayoutConstraint(item: _browser, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: _browser, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: _browser, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: _browser, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
        
        let url = URL(string: "https://memorydeck.herokuapp.com/sessions")!
        
        _browser.load(URLRequest(url: url))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

