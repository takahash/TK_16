
//
//  MapViewController.swift
//  ippuQ_JPHACKS
//
//  Created by 菊池文矩 on 2015/11/28.
//  Copyright © 2015年 れっどいんぱるす. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Darwin


class MapViewController :UIViewController,MKMapViewDelegate{
    @IBOutlet var mapView:MKMapView!
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 緯度・軽度を設定
        let location:CLLocationCoordinate2D
        = CLLocationCoordinate2DMake(atof(appDelegate.lat!),atof(appDelegate.lng!))
        
        mapView.setCenterCoordinate(location,animated:true)
        
        // 縮尺を設定
        var region:MKCoordinateRegion = mapView.region
        region.center = location
        region.span.latitudeDelta = 0.02
        region.span.longitudeDelta = 0.02
        
        mapView.setRegion(region,animated:true)
        
        // 表示タイプを航空写真と地図のハイブリッドに設定
              mapView.mapType = MKMapType.Standard
        //        mapView.mapType = MKMapType.Satellite
        //mapView.mapType = MKMapType.Hybrid
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}