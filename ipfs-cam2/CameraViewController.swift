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
    
//
//    func nodeStarted() {
//        // grab our local thread id once node starts
//        let threadId = UserDefaults.standard.string(forKey: "threadID4") ?? ""
//        if (threadId == ""){
//            createThread()
//        }
//        else{
//            CameraViewController.threadId = threadId
//        }
//    }
//
    
//    func createThread(){
//        var error: NSError?
//        let schema = AddThreadConfig_Schema()
//        schema.preset = AddThreadConfig_Schema_Preset.blob
////        let jsonSchema = "{ name: testSchema, pin: true, plaintext: true, mill: /blob }"
////        let jsonData = jsonSchema.data(using: .utf8)!
////        let customSchema = try! AddThreadConfig_Schema(data: jsonData)
////        print(customSchema.json)
//        
//        let config = AddThreadConfig()
//        config.key = "unique2"
//        config.name = "TEST2"
//        config.type = Thread_Type.open
//        config.sharing = Thread_Sharing.shared
//        
//        
//        config.schema = schema
//       
//        let thread = Textile.instance().threads.add(config, error: &error)
//        if ((error) != nil) {
//                print("error adding thread")
//            print(error?.localizedDescription)
//        
//        }
//        else{
//            CameraViewController.threadId = thread.id_p
//            // Success!
//            UserDefaults.standard.set(thread.id_p, forKey: "threadID4")
//        }
//
//    }
//    


    override func viewDidLoad() {
        super.viewDidLoad()
        InitGeolocation()


        // Set the Textile delegate to self so we can make use of events such nodeStarted
        vc = FileTableViewController()
        vc?.PrepareCells()
        
        cameraView = TWCameraView()
        cameraView!.translatesAutoresizingMaskIntoConstraints = false
        cameraView!.backgroundColor = UIColor.clear
        cameraView!.delegate = imageSaver
        self.view.addSubview(cameraView!)
        let margins = view.layoutMarginsGuide
        
        // constraints
        cameraView!.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 0).isActive = true
        cameraView!.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0).isActive = true
        cameraView!.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 5).isActive = true
//        cameraView!.widthAnchor.constraint(equalToConstant: 200).isActive = true
        cameraView!.heightAnchor.constraint(equalToConstant: 500).isActive = true
        cameraView!.startPreview(requestPermissionIfNeeded: true)
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func TakePictureButtonPress(_ sender: Any) {
        cameraView!.capturePhoto()
    }
    
    var vc:FileTableViewController?
    @IBAction func GetPictureButtonPress(_ sender: Any) {
        navigationController?.show(vc!, sender: self)        
    }
    
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
 
    }
    

}
