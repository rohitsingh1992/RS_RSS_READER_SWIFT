//
//  Utils.swift
//  RSS Reader
//
//  Created by Rohit Singh on 17/07/16.
//  Copyright © 2016 sra. All rights reserved.
//

import UIKit

class Utils: NSObject
{
    class func isConnected() -> Bool{
        let reach : Reachability =  Reachability.reachabilityForInternetConnection()
        let netStatus : NetworkStatus = reach.currentReachabilityStatus()
        
        if (netStatus == NetworkStatus.NotReachable)
        {
            return false
        }
        else
        {
            return true
        }
        
    }
    
   class  func showAlertViewOnViewController(viewC : UIViewController,title: String, message: String)
   {
        
        let alert : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        
        let okAction : UIAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (action: UIAlertAction) -> Void in
            alert.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            })
            
        }
        alert.addAction(okAction)
        viewC.presentViewController(alert, animated: true) { () -> Void in
            
        }

}
}
