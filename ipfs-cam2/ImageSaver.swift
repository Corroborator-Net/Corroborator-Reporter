//
//  ImageSaver.swift
//  ipfs-cam2
//
//  Created by Ian Philips on 9/27/19.
//  Copyright © 2019 Ian Philips. All rights reserved.
//

import Foundation
import UIKit

import Alamofire
import SwiftyJSON
import CoreLocation
class ImageSaver: NSObject, TWCameraViewDelegate{
    

    
    var imageHash:String = ""
    func cameraViewDidFailToCaptureImage(error: Error, cameraView: TWCameraView) {
        print(error)
    }
    
    func cameraViewDidCaptureImage(image: UIImage, cameraView: TWCameraView) {

        let imageData = image.jpegData(compressionQuality: Constants.quality)!
        let jpeg = addImageMetadata(imageData: imageData)!
        
        
        let jpegImage = UIImage.init(data: jpeg)!
        
        self.saveToLibrary(image: jpegImage)
        
        let fileName = generateFileName()
        // if connected, upload to network
        if Reachability.isConnectedToNetwork()
        {
            // save to docs so we have an image with matching CID on the mobile device
            ImageSaver.saveToDocuments(image: jpeg, fileName: fileName)
            ImageSaver.uploadToIPFS(image: jpeg, fileName: fileName, VC: nil, FileFinishedHandler: nil)
        }
        else{
            ImageSaver.saveToDocuments(image: jpeg, fileName: fileName)
            AddPictureToDocumentsToUploadLater(fileName: fileName)
        }
        

//        let path = URL.urlInDocumentsDirectory(with: fileName).path
//        let imageFromFile = UIImage(contentsOfFile: path)!
        //self.saveAsCID(image: jpegImage, path: "")
    }
    
    func addImageMetadata(imageData: Data) -> Data? {
        let imageMetadataDictionary = NSMutableDictionary()

        // add GPS metadata
        let metadataGPS = (CameraViewController.locationManager?.location!.exifMetadata())!
        imageMetadataDictionary[(kCGImagePropertyGPSDictionary as String)] = metadataGPS
        
        // add our own data
        let arbitraryData = NSMutableDictionary()

        // add department info
        var userComment = "Department: Los Angeles Police Department, "
            + "Device model: " + modelIdentifier() + ", "
        

        // add a an image purpose (set by user in settings)
        if (SettingsVC.CurrentPhotoPurpose != ""){
             userComment += "Purpose: " + SettingsVC.CurrentPhotoPurpose
        }
        // set the comment
        arbitraryData[(kCGImagePropertyExifUserComment as String)] = userComment

        // add in the device ID
        arbitraryData[(kCGImagePropertyExifCameraOwnerName)] =        UIDevice.current.identifierForVendor?.uuidString

        // load arbitrary data into our final metadata dictionary
        imageMetadataDictionary[(kCGImagePropertyExifDictionary as String)] = arbitraryData
    
        
        if let source = CGImageSourceCreateWithData(imageData as CFData, nil) {
            if let uti = CGImageSourceGetType(source) {
                let destinationData = NSMutableData()
                if let destination = CGImageDestinationCreateWithData(destinationData, uti, 1, nil) {
                    CGImageDestinationAddImageFromSource(destination, source, 0, imageMetadataDictionary as CFDictionary)
                    if CGImageDestinationFinalize(destination) == false {
                        return nil
                    }
                    return destinationData as Data
                }
            }
        }
        return nil
    }
    
    func modelIdentifier() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    
    func generateFileName() -> String{
        let date = Date()
        let calendar = Calendar.current
        let hour = String(calendar.component(.hour, from: date))
        let minutes = String(calendar.component(.minute, from: date))
        let seconds = String(calendar.component(.second, from: date))
        let milliseconds = String( calendar.component(.nanosecond, from: date)/10000000)
        let day = String(calendar.component(.day, from: date))
        let month = String(calendar.component(.month, from: date))
        let year = String(calendar.component(.year, from: date))
        let fileName = String(month + "-" + day + "-" + year + "_" + hour + ":" + minutes + ":" + seconds + ":" + milliseconds) 
        return fileName + ".jpg"
    }
    
    
    func AddPictureToDocumentsToUploadLater(fileName:String){
        var filesToUpload = UserDefaults.standard.stringArray(forKey: "offlineQueue") ?? [String]()
        filesToUpload.append(fileName)
        UserDefaults.standard.set(filesToUpload,forKey: "offlineQueue")
    }
    
    
    public static func uploadToIPFS(image:Data, fileName:String, VC:UIViewController?, FileFinishedHandler:OfflineImageHandler?){
        let fullUrl = "https://api.pinata.cloud/pinning/pinFileToIPFS"
        
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(image,
                                     withName: "file",
                                     fileName: fileName,
                                     mimeType: "image/jpeg")
        },
                         to: fullUrl,
                         headers: ["pinata_api_key": "1e194bceca95c082feec",
                            "pinata_secret_api_key":"4e6608680a18727d292df23f12d50520ed7346884831bdbbe577d441727ab359"],
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.uploadProgress { progress in
                                }
                                upload.validate()
                                upload.responseJSON { response in
                                    guard response.result.isSuccess,
                                        let value = response.result.value else {
                                            print("Error while uploading file: \(String(describing: response.result.error))")
                                            if (FileFinishedHandler != nil){
                                                FileFinishedHandler?.OnFileUploadError();
                                            }
                                            return
                                    }

 
                                    // 2
                                    let json =  JSON(value)
                                    let cid = json["IpfsHash"].stringValue
                                    print("Content uploaded with ID: \(cid)")
                                    if (VC != nil){
                                        ImageSaver.ShowUploadedNotification(VC: VC!, CID: cid)
                                    }
                                    
                                    if (FileFinishedHandler != nil){
                                        FileFinishedHandler?.OnFileUploadFinish(image: image, fileName: fileName)
                                    }
                                    UploadCIDToEthereum(CID: cid)
                                    
                                    //3
//                                    completion(nil, nil)
                                }
                            case .failure(let encodingError):
                                print(encodingError)
                            }
                            
        })
    }
    
    
    static func stringFromCurrentDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy HH:mm" //yyyy
        return formatter.string(from: date)
    }
    
    
    static func UploadCIDToEthereum(CID:String){
        let locValue:CLLocationCoordinate2D = (CameraViewController.locationManager?.location!.coordinate)!
        let records : [String] = [CID, stringFromCurrentDate(), "lat:\(locValue.latitude), long:\(locValue.longitude)"]
        let parameters: Parameters = [ "tableId" : "4cc77154-536c-42ab-8f1d-53a1231d6667", "record" :  records]
        let urlString = "https://api.atra.io/prod/v1/dtables/records"
        let headers: HTTPHeaders = ["x-api-key": "vdssu05AWO6yAG4ojL4Sv6I9RkAGCak19hBhTVpm"]
        let url = URL.init(string: urlString)
        Alamofire.request(url!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result
            {
            case .success(let json):
                print(json)
            case .failure(let error):
                print(error.localizedDescription)

            }
        }
    }
    
    

    
    static func ShowUploadedNotification(VC:UIViewController, CID:String){
        let prefix = "https://gateway.pinata.cloud/ipfs/"
        let ethereumAddress = "0xF939C4aDb36E9F3eE7Ee4Eca10B9A058ad018885"
        let alert = UIAlertController(title: "Success", message: "Image at: "+prefix+CID + " and on Ethereum blockchain contract address: " + ethereumAddress, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Show me", style: UIAlertAction.Style.default, handler: { (uiAlert) in ImageSaver.OpenWebpage(urlString: prefix+CID)}
        ))
        VC.present(alert, animated: true, completion: nil)
    }
    
    static func OpenWebpage(urlString:String){
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            print("error saving")
            //            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            print("saved to library")
            //            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    
    
    static func saveToDocuments(image: Data, fileName: String) {
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
            
        }
        
        do {
            try image.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }
        
    }
    

    
//    public func saveAsCID(image:UIImage?, path:String){
//        var error:NSError?
//let threadInfo =        Textile.instance().threads.get(CameraViewController.threadId, error: &error)
//        if (error != nil){
//            print(error!.localizedDescription)
//        }
//        else{
//            print("thread id follows:")
//            print(threadInfo.id_p!)
//        }
//        let jpeg = image!.jpegData(compressionQuality: 100)
////        let jsonData = "{latitude: 48.858093, longitude: 2.294694 }".data(using: .utf8)
////        if let data = jsonData {
////        let dataString = data.base64EncodedString()
//        let dataString = jpeg!.base64EncodedString()
//
////        Textile.instance().cafes.register("https://us-west-dev.textile.cafe", token: "uggU4NcVGFSPchULpa2zG2NRjw2bFzaiJo3BYAgaFyzCUPRLuAgToE3HXPyo", completion:
////            {err in
////                if (err != nil){
////                    print(err.localizedDescription)
////                }
////        })
//
//        //        var error2:NSError?
////        Textile.instance().cafes.session("12D3KooWGN8VAsPHsHeJtoTbbzsGjs2LTmQZ6wFKvuPich1TYmYY", error: &error2).
//
//
////        Textile.instance().files.addFiles(path, threadId: CameraViewController.threadId, caption: "", completion: {block,err in
//        Textile.instance().files.addData(dataString, threadId: CameraViewController.threadId, caption: "", completion:  {block,err in
//            if (block != nil){
//                print("block info follows:")
//                print(block?.target!)
//                print(block?.body!)
//                print(block?.data_p!)
//
//
//                print(block!.id_p!)
//                self.imageHash = block!.id_p
////                let newImage = UIImage.init(data: jpeg!)
////                self.saveToLibrary(image: newImage!, name: self.imageHash)
////                self.tryIPFS(image:jpeg!)
////                self.saveToDocuments(image: image, imageName: self.hash)
//                return
//            }
//
//            print(err.localizedDescription)
//        })
////        }
//    }
    
    
    func saveToLibrary(image:UIImage){
        
       
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
//        UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        
    }
    
//    func tryIPFS(image:Data){
//        do {
////            let api = try IpfsApi.init(host: "http://cab272bf.ngrok.io", port: 80, version: "/ip4/", ssl: false)
////            var api = try IpfsApi( host: "10.0.0.29", port: 5001 )
////            let api = try IpfsApi(addr: "")
////            let api = try IpfsApi.init(host: "10.0.0.29", port: 4001, version: "/ipfs/api/v0/", ssl: false)
//            let api = try IpfsApi(host: "127.0.0.1", port: 4001)
////            let api = IpfsApiClient()
//
////            try api.add(image, completionHandler: {nodes in
////                print(nodes.first!.hash?.string())
////            })
//
//            try api.id() { (idData : JsonType) in
//                guard let id = idData.object?["ID"]?.string else {
//                    return
//                }
//                print("Yay, I've got an id: \(id)")
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
//
//    }
    
    
  
    
    
}

extension URL {
    static var documentsDirectory: URL {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return URL(string: documentsDirectory)!
    }
    
    static func urlInDocumentsDirectory(with filename: String) -> URL {
        return documentsDirectory.appendingPathComponent(filename)
    }
}
