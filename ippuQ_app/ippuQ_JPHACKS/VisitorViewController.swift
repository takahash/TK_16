
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
        let url = "https://redimpulz.cybozu.com/k/v1/records.json?totalCount=true&app=14&query=name=%22\(TextBoxName.text!)%22%20and%20passwd=%22\(TextBoxPass.text!)%22"
        getServer(url){statusCode,error in
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
            "app": 14,
            "record": [
                "name": [
                    "value":"\(TextBoxName.text!)"
                ],
                "passwd": [
                    "value":"\(TextBoxPass.text!)"
                ],
                "device_token": [
                   "value": readToken()
                ],
                "beacon_id": [
                    "value": "0001"
                ]
            ]
        ]
        postServer(params,url:"https://redimpulz.cybozu.com/k/v1/record.json",method:"POST"){statusCode,error in
            if let statusCode = statusCode {
                if statusCode == 200{
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
    
    
    func postServer(params:[String:AnyObject],url:String,method:String, completionHandler: (Int?, NSError?) -> Void ) -> NSURLSessionTask{
        // create the url-request
        let urlString = url
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        // set the method(HTTP-POST)
        request.HTTPMethod = method
        // set the header(s)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("usww5ikOCMm5Xbut97srqBYkHmcWLInbz3eLiCfL", forHTTPHeaderField: "X-Cybozu-API-Token")
        
        //        // set the request-body(JSON)
        //        let params: [String: AnyObject] = [
        //            "user": "test",
        //            "passwd":"test"
        //
        //        ]
        print(params)
        do{
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
            print(request.HTTPBody)
        }catch{
        }
        
        // use NSURLSessionDataTask
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error in
            do {
                let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary

                
                if(dict["errors"] == nil){
                    completionHandler(200, nil)
                }else{
                    completionHandler(400, nil)
                }
                return
                
            } catch {
            }
        })
        task.resume()
        return task
        
        
        
    }
    
    func getServer(url:String,completionHandler: (Int?, NSError?) -> Void ) -> NSURLSessionTask{
        // create the url-request
        let urlString = url
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        // set the method(HTTP-POST)
        request.HTTPMethod = "GET"
        // set the header(s)
        request.addValue("usww5ikOCMm5Xbut97srqBYkHmcWLInbz3eLiCfL", forHTTPHeaderField: "X-Cybozu-API-Token")
        
    
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error in
            do {
                let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! NSDictionary
                var totalCount = dict["totalCount"]
                print(totalCount!)
                if(totalCount as! String == "1"){
                    completionHandler(200, nil)
                }else{
                    completionHandler(400, nil)
                }
                return
                
            } catch {
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
