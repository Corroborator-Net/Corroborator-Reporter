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
    var offlineFileList:[CorroDataFile] = []
    var syncedFileList:[CorroDataFile] = []
    var currentlyUploading = false
    
    override func viewWillAppear(_ animated: Bool) {
        let seconds = 0.05
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.RefreshCellRowsWithFileNames()
        }
    }
    
    public func RefreshCellRowsWithFileNames(){
        // check if unsynced files
        offlineFileList = DataManager.GetUnSyncedFiles()
        syncedFileList = DataManager.GetSyncedFiles()
        
        
        let lastIndex = PopulateRows(startAt: 0, files: offlineFileList)
        PopulateRows(startAt: lastIndex + 1, files: syncedFileList)

    }
    
    private func PopulateRows(startAt:Int, files:[CorroDataFile]) -> Int{
        if (files.count==0){
            return startAt - 1
        }
        // populate rows with file names
        for i in 0...files.count-1 {
            let cell =  tableView.cellForRow(at: IndexPath(row: startAt + i, section: 0)) as? FileTableViewCell
            cell?.AddFileData(file: files[i])
        }
        return startAt + files.count - 1
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
        offlineFileList = DataManager.GetUnSyncedFiles()
        if (offlineFileList.count==0){
//            print("no files to upload")
            return
        }
        
        if (currentlyUploading){
            print("currently uploading")
            return
        }


        let currentFileToUpload = offlineFileList.last!
        
        if (DataManager.CurrentlyUploading.contains(currentFileToUpload.FileName)){
            print("currently uploading")
            return
        }
        
        currentFileToUploadIndex = offlineFileList.count-1
        // show user we're uploading file
        let cell =  tableView.cellForRow(at: IndexPath(row: currentFileToUploadIndex, section: 0)) as! FileTableViewCell
        cell.MarkAsUploading()
        
        let image = self.load(fileName: currentFileToUpload.FileName)!
        ImageHandler.uploadToIPFS(image: image, file:currentFileToUpload, UploadToBlockchain:true, VC: self)
        // for now we're uploading images serially for simplicity's sake
        currentlyUploading=true
    }
    
    
    public func OnFileUploadError(){
        currentlyUploading=false
        // restart upload process
        ReloadUnsyncedFilesAndStartUpload()
    }
    
    // Restarts file upload and removes uploaded file
    public func OnFileUploadFinish(file:CorroDataFile){

        let cell =  tableView.cellForRow(at: IndexPath(row: currentFileToUploadIndex, section: 0)) as? FileTableViewCell
        cell?.MarkAsSynced()
        currentlyUploading=false
        
        // start upoad process over again for next file in dict
        ReloadUnsyncedFilesAndStartUpload()
    }
    
    
    
    
    private func load(fileName: String) -> Data? {
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
    
    
    override func viewDidLoad() {
//        self.tableView.register(FileTableViewCell.self, forCellReuseIdentifier: "fileCell")
        tableView.delegate=self
        tableView.dataSource=self
        super.viewDidLoad()
        tableView.estimatedRowHeight = 60.0 // Adjust Primary table height
//        tableView.rowHeight = UITableView.automaticDimension
        helloWorldTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.ReloadUnsyncedFilesAndStartUpload), userInfo: nil, repeats: true)
        
        DataManager.fileUploadDelegate=self
        // check if unsynced files
        offlineFileList = DataManager.GetUnSyncedFiles()
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: fix this
        let offline = DataManager.GetUnSyncedFiles().count
        let syncedFileCount = DataManager.GetSyncedFiles().count
        return offline + syncedFileCount + 10
    }

//
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath) as! FileTableViewCell
        cell.ClearFileData()

        if (indexPath.row < offlineFileList.count){
            cell.AddFileData(file: offlineFileList[indexPath.row])
        }
        else if(indexPath.row < syncedFileList.count){
            cell.AddFileData(file: syncedFileList[indexPath.row])
        }
        
        return cell
    }

    
    //    static func remove(fileName: String){
    //        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    //        let fileURL = documentsDirectory!.appendingPathComponent(fileName)
    //        do{
    //            try FileManager.default.removeItem(at: fileURL)
    //        } catch{
    //            print("Error deleting image : \(error)")
    //
    //        }
    //    }
    //


}
//@objc
protocol OfflineImageHandler{
    func OnFileUploadFinish(file:CorroDataFile);
    func OnFileUploadError();
}
//@objc extension OfflineImageHandler{
//    func ReloadUnsyncedFilesAndStartUpload ();
//}
