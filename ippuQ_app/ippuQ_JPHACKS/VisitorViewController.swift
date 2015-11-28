
//
//  VisitorViewController.swift
//  ippuQ_JPHACKS
//
//  Created by 菊池文矩 on 2015/11/28.
//  Copyright © 2015年 れっどいんぱるす. All rights reserved.
//

import UIKit

class VisitorViewController: UIViewController,NSURLSessionDataDelegate {
    var json:NSData!
    
    @IBOutlet weak var TextBoxName: UITextField!
    @IBOutlet weak var TextBoxPass: UITextField!
    @IBOutlet weak var UserNameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update:", name:"notifyNG", object: nil)
        UserNameLabel.text = readUserData()
        print(readToken())
        
    }
    
    func readUserData()->String{
        // NSKeyedUnarchiverクラスを使って保存したデータを読み込む。
        var name = NSUserDefaults.standardUserDefaults().stringForKey("name")
        if(name == nil){
            name = "ログインしていません"
        }
        return name!
    }
    
    func registUserData( name: String) {
        // nameを登録
        NSUserDefaults.standardUserDefaults().setObject(name,forKey:"name")
    }
    
    func readToken()->String{
        // NSKeyedUnarchiverクラスを使って保存したデータを読み込む。
        var token = NSUserDefaults.standardUserDefaults().stringForKey("token")
        if(token == nil){
            token = "トークンない"
        }
        return token!
    }
    
    
    @IBAction func signInButton(sender: AnyObject) {
        let params: [String: AnyObject] = [
            "user":"\(TextBoxName.text!)",
            "passwd":"\(TextBoxPass.text!)"
        ]
        postServer(params,path:"login"){statusCode,error in
            if let statusCode = statusCode {
                if statusCode == 200{
                    print("サインイン成功")
                    self.alert("おかえりなさい\(self.TextBoxName.text!)", body: "サインインが成功しました！")
                    self.registUserData(self.TextBoxName.text!)
                    self.UserNameLabel.text = self.readUserData()
                }else{
                    print("サインイン失敗")
                    self.alert("残念", body: "サインインが失敗しました")
                }
            } else {
                print("なんかエラー")
            }
        }
        
    }
    @IBAction func signUpButton(sender: AnyObject) {
        let params: [String: AnyObject] = [
            "user":"\(TextBoxName.text!)",
            "passwd":"\(TextBoxPass.text!)",
            "bc_id":"eeeeeeexit",
            "device_token":"\(readToken())"
        ]
        postServer(params, path:"users"){statusCode,error in
            if let statusCode = statusCode {
                if statusCode == 201{
                    print("ユーザ作成成功")
                    self.alert("ユーザ登録完了", body: "良い喫煙ライフを")
                }else{
                    print("ユーザ作成失敗")
                    self.alert("失敗", body: "あれれ、すでに登録してませんか？")
                }
            } else {
                print("なんかエラー")
            }
        }
        
        
        
    }
    
    
    func postServer(params:[String:AnyObject],path:String, completionHandler: (Int?, NSError?) -> Void ) -> NSURLSessionTask{
        // create the url-request
        let urlString = "http://210.140.162.64:10080/\(path)"
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        // set the method(HTTP-POST)
        request.HTTPMethod = "POST"
        // set the header(s)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //        // set the request-body(JSON)
        //        let params: [String: AnyObject] = [
        //            "user": "test",
        //            "passwd":"test"
        //
        //        ]
        print(params)
        do{
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
        }catch{
        }
        
        // use NSURLSessionDataTask
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error in
            if (error == nil) {
                let result = NSString(data:data! , encoding: NSUTF8StringEncoding)!
                if let httpResponse = response as? NSHTTPURLResponse {
                    print(httpResponse.statusCode)
                    completionHandler(httpResponse.statusCode, nil)
                    return
                } else {
                    assertionFailure("unexpected response")
                }
                print(result)
            } else {
                print(error)
            }
        })
        task.resume()
        return task
        
        
        
    }
    
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        print("URLSessionDidFinishEventsForBackgroundURLSession")
        
        // バックグラウンドからフォアグラウンドの復帰時に呼び出されるデリゲート.
    }
    
    func alert(title:String,body:String){
        let alertController = UIAlertController(title: title, message: body, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    //notifyNGが通知された時
    func update(notification: NSNotification?) {
        alert("hoge", body:"hoge")
        print("hogeVisit")
    }
    
    //キーボードを閉じる
    @IBAction func getText(sender : UITextField) {
        
    }
    
    
    
    
}
