//
//  CameraViewController.swift
//  ipfs-cam2
//
//  Created by Ian Philips on 9/27/19.
//  Copyright © 2019 Ian Philips. All rights reserved.
//

import UIKit
//import Textile
//var Textile:Textile?
import CoreLocation

class CameraViewController: UIViewController, CLLocationManagerDelegate {
    
    static var locationManager:CLLocationManager?
//    var vc:FileTableViewController?

    public func InitGeolocation(){
        CameraViewController.locationManager = CLLocationManager()
        CameraViewController.locationManager!.delegate = self;
        CameraViewController.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        CameraViewController.locationManager!.requestAlwaysAuthorization()
        CameraViewController.locationManager!.requestWhenInUseAuthorization()
        CameraViewController.locationManager!.startUpdatingLocation()
    }
    
    var cameraView: TWCameraView?
    let imageSaver:ImageHandler = ImageHandler()
    static var threadId:String = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        InitGeolocation()

        // Set the Textile delegate to self so we can make use of events such nodeStarted
//        vc = FileTableViewController()
        let height:CGFloat = 515
        cameraView = TWCameraView(frame: CGRect(x: 0, y: 0, width: height/1.5, height: height))
        cameraView!.translatesAutoresizingMaskIntoConstraints = false
        cameraView!.backgroundColor = UIColor.clear
        cameraView!.delegate = imageSaver
        self.view.addSubview(cameraView!)
        cameraView!.heightAnchor.constraint(equalToConstant: height).isActive = true
        cameraView!.widthAnchor.constraint(equalToConstant: height/1.5).isActive = true
        cameraView!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        cameraView!.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        let midX = self.view.frame.size.width/2
        let camImage = UIImage(named: "circle")
        let button = UIButton(frame: CGRect(x: midX-30, y: height, width: 60, height: 60))
        button.setImage(camImage, for: .normal)
        button.addTarget(self, action:  #selector(TakePictureButtonPress(_:)), for: .touchUpInside)
        self.view.addSubview(button)
        cameraView!.translatesAutoresizingMaskIntoConstraints = false
        cameraView!.startPreview(requestPermissionIfNeeded: true)
        // Do any additional setup after loading the view.
        
    }
    
   
    
    @objc func TakePictureButtonPress(_ sender: UIButton) {
        cameraView!.capturePhoto()
    }
    

    
    

    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
 
    }
    

}


