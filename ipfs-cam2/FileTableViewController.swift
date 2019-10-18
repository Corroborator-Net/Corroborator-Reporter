//
//  FileTableViewController.swift
//  ipfs-cam2
//
//  Created by Ian Philips on 9/28/19.
//  Copyright © 2019 Ian Philips. All rights reserved.
//

import UIKit

class FileTableViewController: UITableViewController, OfflineImageHandler {

    var helloWorldTimer:Timer?
    let uploadFileTitle:String = "uploading..."
    var currentFileToUploadIndex:Int = 0
    var offlineDictionary:[String] = []
    var currentlyUploading = false
    
    public func RefreshCellRowsWithFileNames(){
    
        // check if unsynced files
        offlineDictionary = UserDefaults.standard.stringArray(forKey: "offlineQueue") ?? [String]()
        if (offlineDictionary.count==0){
            print("no files to upload")
            return
        }
        
        // populate rows with file names
        for i in 0...offlineDictionary.count-1 {
            let cell =  tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? FileTableViewCell
            cell?.AddFileData(fileName: offlineDictionary[i])
        
        }

    }
    
    
    @objc public func ReloadUnsyncedFilesAndStartUpload (){
        
        // only upload files while user is watching so the alerts don't interrupt other views
        if self.viewIfLoaded?.window == nil {
            // viewController is not visible
            return
        }
        
        // not connected? don't do anything else
        if !Reachability.isConnectedToNetwork()
        {
            return
        }
        
        
        // check if unsynced files
        offlineDictionary = UserDefaults.standard.stringArray(forKey: "offlineQueue") ?? [String]()
        if (offlineDictionary.count==0){
            print("no files to upload")
            return
        }
        
        if (currentlyUploading){
            print("currently uploading")
            return
        }


        let currentFileToUpload = offlineDictionary.last!
        currentFileToUploadIndex = offlineDictionary.count-1
        // show user we're uploading file
        let cell =  tableView.cellForRow(at: IndexPath(row: offlineDictionary.count-1, section: 0)) as? FileTableViewCell
        cell?.FileLabel!.text = uploadFileTitle
        let image = self.load(fileName: currentFileToUpload)!.jpegData(compressionQuality: Constants.quality)
        ImageSaver.uploadToIPFS(image: image!, fileName:currentFileToUpload, VC: self, FileFinishedHandler: self)
        // for now we're uploading images serially for simplicity's sake
        currentlyUploading=true
    }
    
    
    public func OnFileUploadError(){
        currentlyUploading=false
        // restart upload process
        ReloadUnsyncedFilesAndStartUpload()
    }
    
    // Restarts file upload and removes uploaded file
    public func OnFileUploadFinish(image:Data?, fileName: String){

        let cell =  tableView.cellForRow(at: IndexPath(row: currentFileToUploadIndex, section: 0)) as? FileTableViewCell
        cell?.FileLabel!.text=""

        // remove file from dictionary
        var newOfflineDictionary = offlineDictionary
        newOfflineDictionary.remove(at: currentFileToUploadIndex)
        UserDefaults.standard.set(newOfflineDictionary,forKey: "offlineQueue")
        
        // delete old file so we can re-save to have exact same file
        FileTableViewController.remove(fileName: fileName)
        // we have to re-save here to make sure the file uploaded to pinata is the same as the one in the app directory
        ImageSaver.saveToDocuments(image: image!, fileName: fileName)
        
        currentlyUploading=false
        
        // start upoad process over again
        ReloadUnsyncedFilesAndStartUpload()
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
    
    
    private func load(fileName: String) -> UIImage? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = documentsDirectory!.appendingPathComponent(fileName)
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
    
    override func viewDidLoad() {
        self.tableView.register(FileTableViewCell.self, forCellReuseIdentifier: "fileCell")
        tableView.delegate=self
        tableView.dataSource=self
        super.viewDidLoad()
        
        helloWorldTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(OfflineImageHandler.ReloadUnsyncedFilesAndStartUpload), userInfo: nil, repeats: true)
        
        // check if unsynced files
        offlineDictionary = UserDefaults.standard.stringArray(forKey: "offlineQueue") ?? [String]()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }

//
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath) as! FileTableViewCell
        cell.ClearFileData()

        if (indexPath.row < offlineDictionary.count){
            cell.AddFileData(fileName: offlineDictionary[indexPath.row])
        }
        
        return cell
    }


}

@objc protocol OfflineImageHandler{
    func OnFileUploadFinish(image:Data?, fileName: String);
    func ReloadUnsyncedFilesAndStartUpload ();
    func OnFileUploadError();

}
