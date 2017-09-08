//
//  WebViewController.swift
//  TTTMaps
//
//  Created by bl on 8/21/17.
//  Copyright © 2017 bl. All rights reserved.
//


import UIKit


// 
// Note: info.plist must be configured for UIWebView
//   App Transport Security Settings : Dictionary
//     Allows Arbitrary Loads : Boolean : Value YES
//
class WebViewController: UIViewController {
    public var displayTitle: String?
    public var pageUrl: String?
    
    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        edgesForExtendedLayout = []
        
        if displayTitle != nil {
            title = displayTitle!
        }
        
        // Load the web page for the point of interest
        if pageUrl != nil {
            if let url = URL(string: pageUrl!) {
                let urlRequest = URLRequest(url: url)
                webView.loadRequest(urlRequest)
            }
        }
    }
}
