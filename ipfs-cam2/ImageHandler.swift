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

class ImageHandler: NSObject, TWCameraViewDelegate{
    
    var imageHash:String = ""
    func cameraViewDidFailToCaptureImage(error: Error, cameraView: TWCameraView) {
        print(error)
    }
    
    
    func cameraViewDidCaptureImage(image: UIImage, cameraView: TWCameraView) {

        let imageData = image.jpegData(compressionQuality: Constants.quality)!
        let jpeg = addImageMetadata(imageData: imageData)!
        let jpegImage = UIImage.init(data: jpeg)!
        
        // if we're not deleting local photos, save it to the user's photo roll
        if (!SettingsVC.DeleteLocalPhotos){
            self.saveToPhotoRoll(image: jpegImage)
        }
        
        if (SettingsVC.DeleteLocalPhotos){
            print("TODO: when we set up a local node, let's delete the file upon CID generation")
        }
        
        let( fileName, date) = generateFileName()
        // TODO: don't do this when we have a local node
        ImageHandler.saveToDocuments(image: jpeg, fileName: fileName)
        
        let newSavedFile = CorroDataFile(
            ThumbnailData: CorroDataFile.ProduceThumbnail(image: jpegImage),
            FileName: fileName,
            Synced:false,
            DateTaken:date,
            CID: nil)

        // mark file as unsynced in our file database
        DataManager.AddFileToSyncLater(file: newSavedFile)

        // start the upload and save it to the currently uploading cache
        if Reachability.isConnectedToNetwork()
        {
            if (!SettingsVC.UploadToAuditorNode){
                print("TODO: when we integrate local node, don't upload to IPFS")
            }
            
            // if the user quits the app with this cache full of files, our local DB
            // will know they're still unsynced and will sync them on restart
            DataManager.CurrentlyUploading.append(newSavedFile.FileName)
            ImageHandler.uploadToIPFS(image: jpeg,
                                      file: newSavedFile,
                                      VC: nil)
        }
        
    }
    
    func addImageMetadata(imageData: Data) -> Data? {
        let imageMetadataDictionary = NSMutableDictionary()

        // add GPS metadata
        let metadataGPS = (CameraViewController.locationManager?.location!.exifMetadata())!
        imageMetadataDictionary[(kCGImagePropertyGPSDictionary as String)] = metadataGPS
        
        // add our own data
        let arbitraryData = NSMutableDictionary()

        let commentData = ExifComment(
            device_id: UIDevice.current.identifierForVendor!.uuidString, department: "Los Angeles Police Deparment", purpose: SettingsVC.CurrentPhotoPurpose, device_model: modelIdentifier(), user_name: "Ian P", investigation_id:SettingsVC.CurrentInvestigationID);
        
        let jsonData = try! JSONEncoder().encode(commentData)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        
        // set the comment
        arbitraryData[(kCGImagePropertyExifUserComment as String)] = jsonString

        // add in the device ID
//        arbitraryData[(kCGImagePropertyExifCameraOwnerName)] =        UIDevice.current.identifierForVendor?.uuidString

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
    
    
    func generateFileName() -> (String, Date){
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
        return (fileName + ".jpg", date)
    }
    
    

    
    public static func uploadToIPFS(image:Data,
                                    file:CorroDataFile,
                                    VC:UIViewController?
                                    ){
        
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(image,
                                     withName: "file",
                                     fileName: file.FileName,
                                     mimeType: "image/jpeg")
        },
                         to: Constants.AddPinURL,
                         headers: Constants.PinataHeaders,
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
                                            DataManager.OnFileUploadError();
                                        
                                            return
                                    }

 
                                    // 2
                                    let json =  JSON(value)
                                    let cid = json["IpfsHash"].stringValue
                                    
                                    var fileWithCID = file
                                    fileWithCID.CID = cid
                                    
                                    print("Content uploaded with ID: \(cid)")
                                    
                                    if (VC != nil){
                                        ImageHandler.ShowUploadedNotification(VC: VC!, CID: cid)
                                    }
                                    
                                    DataManager.OnFileUploadFinish(file: fileWithCID)
                                
                                    BlockchainManager.UploadCIDToEthereum(CID: cid, sourceMetadata: image)
                                    
                                }
                            case .failure(let encodingError):
                                print(encodingError)
                            }
                            
        })
    }
    
    
    
    static func remove(fileName: String){
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let fileURL = documentsDirectory!.appendingPathComponent(fileName)
            do{
                try FileManager.default.removeItem(at: fileURL)
            } catch{
                print("Error deleting image : \(error)")
    
            }
        }
    

    public static func load(fileName: String) -> Data? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = documentsDirectory!.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return imageData
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    

    
    static func ShowUploadedNotification(VC:UIViewController, CID:String){
        let prefix = "https://gateway.pinata.cloud/ipfs/"
        let ethereumAddress = "0xF939C4aDb36E9F3eE7Ee4Eca10B9A058ad018885"
        let alert = UIAlertController(title: "Success", message: "Image at: "+prefix+CID + " and on Ethereum blockchain contract address: " + ethereumAddress, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Show me", style: UIAlertAction.Style.default, handler: { (uiAlert) in ImageHandler.OpenWebpage(urlString: prefix+CID)}
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
    
    
    func saveToPhotoRoll(image:UIImage){
        
       
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
