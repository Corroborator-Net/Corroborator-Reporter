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
    var vc:FileTableViewController?

    public func InitGeolocation(){
        CameraViewController.locationManager = CLLocationManager()
        CameraViewController.locationManager!.delegate = self;
        CameraViewController.locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        CameraViewController.locationManager!.requestAlwaysAuthorization()
        CameraViewController.locationManager!.requestWhenInUseAuthorization()
        CameraViewController.locationManager!.startUpdatingLocation()
    }
    
    var cameraView: TWCameraView?
    let imageSaver:ImageSaver = ImageSaver()
    static var threadId:String = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        InitGeolocation()

        // Set the Textile delegate to self so we can make use of events such nodeStarted
        vc = FileTableViewController()
        
        cameraView = TWCameraView()
        cameraView!.translatesAutoresizingMaskIntoConstraints = false
        cameraView!.backgroundColor = UIColor.clear
        cameraView!.delegate = imageSaver
        self.view.addSubview(cameraView!)
        let margins = view.layoutMarginsGuide
        
        // constraints TODO: center the camera view horizontally
        cameraView!.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 5).isActive = true
        cameraView!.topAnchor.constraint(equalTo: margins.topAnchor, constant: 8).isActive = true
        cameraView!.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0).isActive = true
//        cameraView!.widthAnchor.constraint(equalToConstant: 200).isActive = true
        cameraView!.heightAnchor.constraint(equalToConstant: 500).isActive = true
        cameraView!.startPreview(requestPermissionIfNeeded: true)
        // Do any additional setup after loading the view.
        
    }
    
   
    
    
    @IBAction func TakePictureButtonPress(_ sender: Any) {
        cameraView!.capturePhoto()
    }
    
    
    @IBAction func OfflineQueueButtonPressed(_ sender: Any) {
        navigationController?.show(vc!, sender: self)
        let seconds = 0.1
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.vc!.RefreshCellRowsWithFileNames()
            }
        
    }
    
    

    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
 
    }
    

}


