//
//  SecondViewC.swift
//  RSS Reader
//
//  Created by Rohit Singh on 17/07/16.
//  Copyright © 2016 sra. All rights reserved.
//

import UIKit

class SecondViewC: UIViewController, UIWebViewDelegate {
    
    
    var strUrl : String = ""
    @IBOutlet var webView: UIWebView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        self.activityIndicator.hidden = true
        super.viewDidLoad()
        
        self.webView.delegate = self
        
        let url : NSURL = NSURL(string: self.strUrl)!
        let urlRequest : NSURLRequest = NSURLRequest(URL: url)
        
        if Utils.isConnected(){
            self.webView.loadRequest(urlRequest)
        } else {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true

        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Web View Delegate Methods
    func webViewDidStartLoad(webView: UIWebView) {
        self.activityIndicator.hidden = false

    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.activityIndicator.hidden = false

    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.activityIndicator.hidden = true

    }
    

    

}
