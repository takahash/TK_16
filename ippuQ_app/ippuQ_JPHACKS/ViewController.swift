//
//  ViewController.swift
//  ippuQ_JPHACKS
//
//  Created by 菊池文矩 on 2015/11/28.
//  Copyright © 2015年 れっどいんぱるす. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

class ViewController: UIViewController ,CBCentralManagerDelegate,CBPeripheralDelegate,CLLocationManagerDelegate,NSURLSessionDataDelegate{
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    var isScanning = false
    var serviceUUID = CBUUID(string: "229BFF00-03FB-40DA-98A7-B0DEF65C2D4B")
    var characteristicUUID0 = CBUUID(string:"229B3000-03FB-40DA-98A7-B0DEF65C2D4B")//初期化
    var characteristicUUID2 = CBUUID(string: "229B3002-03FB-40DA-98A7-B0DEF65C2D4B")//LED
    var characteristicUUID3 = CBUUID(string: "229B3003-03FB-40DA-98A7-B0DEF65C2D4B")//ボタン
    var characteristicUUID1 = CBUUID(string: "229B3001-03FB-40DA-98A7-B0DEF65C2D4B")//pullup

    @IBOutlet weak var scanButton: UIButton!
    var lighterCharacteristicOutput: CBCharacteristic!
    var lighterCharacteristicNotify: CBCharacteristic!
    var lighterCharacteristicInit: CBCharacteristic!
    var lighterCharacteristicPullup: CBCharacteristic!
    @IBOutlet weak var writeDataTextField: UITextField!
    var json:NSData!
    var delegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    //GPS
    var lm: CLLocationManager! = nil
    var longitude: CLLocationDegrees!
    var latitude: CLLocationDegrees!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update:", name:"notifyNG", object: nil)
        // フィールドの初期化
        lm = CLLocationManager()
        longitude = CLLocationDegrees()
        latitude = CLLocationDegrees()
        
        // CLLocationManagerをDelegateに指定
        lm.delegate = self
        // 位置情報取得の許可を求めるメッセージの表示．必須．
        lm.requestAlwaysAuthorization()
        // 位置情報の精度を指定．任意，
        // lm.desiredAccuracy = kCLLocationAccuracyBest
        // 位置情報取得間隔を指定．指定した値（メートル）移動したら位置情報を更新する．任意．
        // lm.distanceFilter = 1000
        
        // GPSの使用を開始する
        lm.startUpdatingLocation()
        
        
        //セントラルマネージャを初期化する
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        
        //スキャンを開始する
        self.centralManager.scanForPeripheralsWithServices([serviceUUID], options: nil)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //セントラルマネージャーの状態変化を取得する
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print("status: \(central.state)")
    }
    
    
    // 周辺にあるデバイスを発見すると呼ばれる
    func centralManager(central: CBCentralManager,
        didDiscoverPeripheral peripheral: CBPeripheral,
        advertisementData: [String : AnyObject],
        RSSI: NSNumber)
    {
        //print("発見したBLEデバイス: \(peripheral)")
        self.peripheral = peripheral
        self.centralManager.connectPeripheral(self.peripheral, options: nil)
    }
    
    // ペリフェラルへの接続が成功すると呼ばれる
    func centralManager(central: CBCentralManager,
        didConnectPeripheral peripheral: CBPeripheral)
    {
        print("connected!")
        //サービス探索結果を受け取るためにデリゲートをセット
        peripheral.delegate = self
        //サービス探索開始
        peripheral.discoverServices([serviceUUID])
    }
    
    // ペリフェラルへの接続が失敗すると呼ばれる
    func centralManager(central: CBCentralManager,
        didFailToConnectPeripheral peripheral: CBPeripheral,
        error: NSError?)
    {
        print("failed...")
    }
    
    // サービス発見時に呼ばれる
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        if (error != nil) {
            print("エラー: \(error)")
            return
        }
        
        if !(peripheral.services?.count > 0) {
            print("no services")
            return
        }
        
        let services = peripheral.services!
        
        print("\(services.count) 個のサービスを発見！ \(services)")
        //スキャンを停止する
        self.centralManager.stopScan()
        isScanning = false
        scanButton.setTitle("START SCAN", forState: UIControlState.Normal)
        
        for service in services {
            
            // キャラクタリスティック探索開始
            peripheral.discoverCharacteristics([characteristicUUID3,characteristicUUID2,characteristicUUID0,characteristicUUID1], forService: service)
        }
    }
    
    
    // キャラクタリスティック発見時に呼ばれる
    func peripheral(peripheral: CBPeripheral,
        didDiscoverCharacteristicsForService service: CBService,
        error: NSError?)
    {
        if (error != nil) {
            print("エラー: \(error)")
            return
        }
        
        let characteristics = service.characteristics
        print("\(characteristics?.count) 個のキャラクタリスティックを発見！ \(characteristics)")
        
        for characteristic in characteristics! {
            
            // Read専用のキャラクタリスティックに限定して読み出す場合
            if characteristic.UUID.isEqual(characteristicUUID2){
                peripheral.readValueForCharacteristic(characteristic)
                lighterCharacteristicOutput = characteristic
                var value: CUnsignedChar = 0x02
                let data: NSData = NSData(bytes: &value, length: 1)
                peripheral.writeValue(data, forCharacteristic: self.lighterCharacteristicOutput, type: CBCharacteristicWriteType.WithoutResponse)
            }else if characteristic.UUID.isEqual(characteristicUUID3){
                lighterCharacteristicNotify = characteristic
                peripheral.setNotifyValue(true, forCharacteristic: lighterCharacteristicNotify)
            }else if characteristic.UUID.isEqual(characteristicUUID0){
                //初期化処理111110
                lighterCharacteristicInit = characteristic
                var value: CUnsignedChar = 0x3e
                let data: NSData = NSData(bytes: &value, length: 1)
                peripheral.writeValue(data, forCharacteristic: self.lighterCharacteristicInit, type: CBCharacteristicWriteType.WithoutResponse)
            }else if characteristic.UUID.isEqual(characteristicUUID1){
                lighterCharacteristicPullup = characteristic
                var value: CUnsignedChar = 0x01
                let data: NSData = NSData(bytes: &value, length: 1)
                peripheral.writeValue(data, forCharacteristic: self.lighterCharacteristicPullup, type: CBCharacteristicWriteType.WithoutResponse)

            }
           
            
        }
        
    }
    
    
    // データ読み出しが完了すると呼ばれる
    func peripheral(peripheral: CBPeripheral,
        didUpdateValueForCharacteristic characteristic: CBCharacteristic,
        error: NSError?)
    {
        if (error != nil) {
            print("読み出し失敗...error: \(error), characteristic uuid: \(characteristic.UUID)")
            return
        }
        
        print("読み出し成功！service uuid: \(characteristic.service.UUID), characteristic uuid: \(characteristic.UUID), value: \(characteristic.value)")
        if characteristic.UUID.isEqual(characteristicUUID3){
            var byte: CUnsignedChar = 0
            
            // 1バイト取り出す
            characteristic.value?.getBytes(&byte, length: 1)
            
            print("LighterNotify Data: \(byte)")
            //現在地取得
            print(longitude)
            print(latitude)
            putGPS(){statusCode,error in
                if let statusCode = statusCode {
                    if statusCode == 200{
                        print("GPS送信")
                    }else{
                        print("エラー")
                    }
                } else {
                    print("なんかエラー")
                }
            }
            
            
        }else{
            
            var byte: CUnsignedChar = 0
            
            // 1バイト取り出す
            characteristic.value?.getBytes(&byte, length: 1)
            
            print("LighterRead Data: \(byte)")
            print(NSUserDefaults.standardUserDefaults().stringForKey("NG"))
            if NSUserDefaults.standardUserDefaults().stringForKey("NG") == "NG"{
                print("NG送信")
                postNG(){statusCode,error in
                    if let statusCode = statusCode {
                        if statusCode == 200{
                            print("GPS送信")
                        }else{
                            print("エラー")
                        }
                    } else {
                        print("なんかエラー")
                    }
                }
            }
            
            
        }
    }
    
    
    //書き込み成功時に呼ばれるメソッド
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("write成功!")
    }
    
    //notify状態更新時に呼ばれるメソッド
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            print("Notify状態更新失敗・・・error: \(error)")
        }else{
            print("Notify状態更新成功！ isNotifying: \(characteristic.isNotifying)")
        }
    }
    
    
    
    
    
    
    
    @IBAction func stopScan(sender: AnyObject) {
        //        //スキャンを停止する
        //        self.centralManager.stopScan()
        //        print("push stop")
        if !isScanning {
            
            isScanning = true
            
            self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
            
            sender.setTitle("STOP SCAN", forState: UIControlState.Normal)
        }
        else {
            
            self.centralManager.stopScan()
            
            sender.setTitle("START SCAN", forState: UIControlState.Normal)
            
            isScanning = false
        }
        
        
    }
    
    
    //notifyNGが通知された時
    func update(notification: NSNotification?) {
        print("hoge")
    }
    
    
    @IBAction func writeData(sender: AnyObject) {
        var value: CUnsignedChar = 0x3e
        let data: NSData = NSData(bytes: &value, length: 1)
    }
    
    /** 位置情報取得成功時 */
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!){
        longitude = newLocation.coordinate.longitude
        latitude = newLocation.coordinate.latitude
        print(latitude)
        self.delegate.lat = "\(latitude)"
        self.delegate.lng = "\(longitude)"
    }
    
    /** 位置情報取得失敗時 */
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("Error")
    }
    
    
    func putGPS(completionHandler: (Int?, NSError?) -> Void ) -> NSURLSessionTask{
        // create the url-request
        let urlString = "http://210.140.162.64:10080/users"
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        // set the method(HTTP-POST)
        request.HTTPMethod = "PUT"
        // set the header(s)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // set the request-body(JSON)
        var name = NSUserDefaults.standardUserDefaults().stringForKey("name")
        let params: [String: AnyObject] = [
            "user": "\(name!)",
            "lat":"\(latitude)",
            "lng":"\(longitude)",
            "bc_id":"1"
            
        ]
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
    
    func postNG(completionHandler: (Int?, NSError?) -> Void ) -> NSURLSessionTask{
        // create the url-request
        let urlString = "http://210.140.162.64:10080/check"
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        
        // set the method(HTTP-POST)
        request.HTTPMethod = "POST"
        // set the header(s)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // set the request-body(JSON)
        var name = NSUserDefaults.standardUserDefaults().stringForKey("name")
        let params: [String: AnyObject] = [
            "bc_id":"1"
            
        ]
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
    
}

