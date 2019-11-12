//
//  FileManager.swift
//  ipfs-cam2
//
//  Created by Ian Philips on 11/8/19.
//  Copyright © 2019 Ian Philips. All rights reserved.
//

import Foundation
import UIKit

class DataManager: NSObject{
    
    public static var CurrentlyUploading:[String] = []
    
    private static let offlineKey:String = "offlineQueue"
    private static let syncedKey:String = "syncedFiles"
    public static var fileUploadDelegate:[ImageFileHandler] = []
    

    static func OnFileUploadFinish(file: CorroDataFile) {
        SetAsSynced(file: file)
        fileUploadDelegate.forEach({(imageFileHandler) -> Void
            in
            imageFileHandler.OnFileUploadFinish(file: file)
        })        
    }
    
    
    static func OnFileUploadError() {
        fileUploadDelegate.forEach({(imageFileHandler) -> Void
            in
            imageFileHandler.OnFileUploadError()
        })
    }
    

    // check if unsynced files
    public static func GetUnSyncedFiles() -> [CorroDataFile]{
        guard let data = UserDefaults.standard.value(forKey:offlineKey) as? Data ?? nil else { return [CorroDataFile]() }
        let files = try? PropertyListDecoder().decode(Array<CorroDataFile>.self, from: data)
        return files!
    }

    
    public static func SetAsSynced(file:CorroDataFile){
        var newOfflineDictionary = GetUnSyncedFiles()
        newOfflineDictionary.remove(at: newOfflineDictionary.firstIndex(where:
            {
                (corroDataFile) -> Bool in
                    return corroDataFile.FileName == file.FileName
        })!)
        
        if let index = CurrentlyUploading.firstIndex(of:file.FileName){
            CurrentlyUploading.remove(at: index)
        }


        
        SaveNewFileList(files: newOfflineDictionary, key:offlineKey)
        
        
        var syncedFile = file
        syncedFile.Synced = true
        var syncedFiles = GetSyncedFiles()
        syncedFiles.append(syncedFile)
        SaveNewFileList(files: syncedFiles, key: syncedKey)
    }
    
    
    public static func AddFileToSyncLater(file: CorroDataFile){
        var filesToUpload = GetUnSyncedFiles()
        filesToUpload.append(file)
        SaveNewFileList(files:filesToUpload, key:offlineKey)
    }
    
    
    private static func SaveNewFileList(files:[CorroDataFile], key:String){
        UserDefaults.standard.set(try? PropertyListEncoder().encode(files), forKey:key)
    }
    
    // TODO: organize by date taken
    public static func GetSyncedFiles() -> [CorroDataFile]{
        guard let data = UserDefaults.standard.value(forKey:syncedKey) as? Data ?? nil else { return [CorroDataFile]() }
        let files = try? PropertyListDecoder().decode(Array<CorroDataFile>.self, from: data)
        return files!.sorted(by: { $0.DateTaken > $1.DateTaken })
    }
    
    
    static func matchFileName(_ file:CorroDataFile, _ fileName:String) -> Bool {
        return file.FileName == fileName
    }

}

struct CorroDataFile:Codable{
    public var ThumbnailData:Data
    public var FileName:String
    public var Synced:Bool
    public var DateTaken:Date

    
    static func ProduceThumbnail(image:UIImage) -> Data{
        return image.resizeImage(100, opaque: true, contentMode: .scaleAspectFit).jpegData(compressionQuality: 0.5)!
    }
    
    public func GetThumbnailImage() -> UIImage{
        return UIImage.init(data: self.ThumbnailData)!
    }
}
