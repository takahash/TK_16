
//
//  MapViewController.swift
//  ippuQ_JPHACKS
//
//  Created by 菊池文矩 on 2015/11/28.
//  Copyright © 2015年 れっどいんぱるす. All rights reserved.
//

import Foundation
import UIKit

class MapViewController :UIViewController{
    var delegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var MapWebView: UIWebView!
    
    var targetURL:String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        targetURL = "http://210.140.162.64:10080/view/map?l=\(self.delegate.lat!)&l=\(self.delegate.lng!)"
        print(targetURL)
        
        loadAddressURL()
        
    }
    
    
    func loadAddressURL() {
        let requestURL = NSURL(string: targetURL!)
        let req = NSURLRequest(URL: requestURL!)
        MapWebView.loadRequest(req)
    }
    
    
    
    
    
}