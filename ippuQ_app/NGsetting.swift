//
//  NGsetting.swift
//  ippuQ_JPHACKS
//
//  Created by 菊池文矩 on 2015/11/28.
//  Copyright © 2015年 れっどいんぱるす. All rights reserved.
//

import UIKit

class NGsetting :UIViewController{
    
    @IBOutlet weak var MapWebView: UIWebView!
    var targetURL = "http://210.140.162.64:10080"
    
    
    @IBOutlet weak var ngSwich: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ngSwich.on {
            setNG("NG")
        }else{
            setNG("OK")
        }
        
    }
    
    
    func loadAddressURL() {
    }
    
    
    @IBAction func changeSwich(sender: AnyObject) {
        if ngSwich.on{
            setNG("NG")
        }else{
            setNG("OK")
        }
    }
    
    
    func readNG()->String{
        // NSKeyedUnarchiverクラスを使って保存したデータを読み込む。
        var ng = NSUserDefaults.standardUserDefaults().stringForKey("NG")
        if(ng == nil){
            ng = "設定されてない"
        }
        return ng!
    }
    
    func setNG( ng:String) {
        // ng設定
        NSUserDefaults.standardUserDefaults().setObject(ng,forKey:"NG")
    }
    
}

