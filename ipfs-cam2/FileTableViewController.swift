//
//  FileTableViewController.swift
//  ipfs-cam2
//
//  Created by Ian Philips on 9/28/19.
//  Copyright © 2019 Ian Philips. All rights reserved.
//

import UIKit

class FileTableViewController: UITableViewController, ImageFileHandler {

    var helloWorldTimer:Timer?
    let uploadFileTitle:String = "uploading..."
//    var currentFileToUploadIndex:Int = 0
    var offlineFileList:[CorroDataFile] = []
    var syncedFileList:[CorroDataFile] = []
    var currentlyUploading = false
    var fileToRow:Dictionary<String,Int> = [String:Int]()
    
  
    public func RefreshCellRowsWithFileNames(){
        // check if unsynced files
        offlineFileList = DataManager.GetUnSyncedFiles()
        syncedFileList = DataManager.GetSyncedFiles()
        let lastIndex = PopulateRows(startAt: 0, files: offlineFileList)
        PopulateRows(startAt: lastIndex + 1, files: syncedFileList)

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
        
        if (DataManager.CurrentlyUploading.contains(where:
            {
                (corroDataFile) -> Bool in
                return corroDataFile.FileName == currentFileToUpload.FileName
        })){
            print("currently uploading")
            return
        }
        
        let currentFileToUploadIndex = offlineFileList.count-1
        // show user we're uploading file
        let cell =  tableView.cellForRow(at: IndexPath(row: currentFileToUploadIndex, section: 0)) as! FileTableViewCell
        cell.MarkAsUploading()
        
        let image = ImageHandler.load(fileName: currentFileToUpload.FileName)!
        ImageHandler.uploadToIPFS(image: image, file:currentFileToUpload, VC: self)
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
        if let index = fileToRow.firstIndex(where:
        {
            (key, val) -> Bool in
                return key == file.FileName
        }){
            let syncedFileIndex = fileToRow.remove(at: index).value
            let cell =  tableView.cellForRow(at: IndexPath(row: syncedFileIndex, section: 0)) as? FileTableViewCell
            cell?.MarkAsSynced()
        }
        
        
        currentlyUploading=false
        let numRows = tableView.numberOfRows(inSection: 0)
        if ( numRows < TotalFileList()){
            var indexPaths:[IndexPath] = []
            let diff = TotalFileList() - numRows
            // add another row to the bottom to offset the newly synced file
            for i in 0...diff-1 {
                indexPaths.append(IndexPath(row: numRows+i, section: 0))
            }
            tableView.beginUpdates()
            tableView.insertRows(at: indexPaths, with: .automatic)
            tableView.endUpdates()
            
        }
        var syncedFile = file
        syncedFile.Synced = true
        syncedFileList.insert(syncedFile, at: 0)
        // start upoad process over again for next file in dict
        ReloadUnsyncedFilesAndStartUpload()
    }
    

    private func PopulateRows(startAt:Int, files:[CorroDataFile]) -> Int{
        if (files.count==0){
            return startAt - 1
        }
        // populate rows with file names
        for i in 0...files.count-1 {
            let rowNum = startAt + i
            let cell =  tableView.cellForRow(at: IndexPath(row: rowNum, section: 0)) as? FileTableViewCell
            let file = files[i]
            fileToRow[file.FileName] = rowNum
            cell?.AddFileData(file: file)
        }
        return startAt + files.count - 1
    }
    
    

    
    
    override func viewDidLoad() {
//        self.tableView.register(FileTableViewCell.self, forCellReuseIdentifier: "fileCell")
        tableView.delegate=self
        tableView.dataSource=self
        super.viewDidLoad()
        tableView.estimatedRowHeight = 60.0 // Adjust Primary table height
//        tableView.rowHeight = UITableView.automaticDimension
        helloWorldTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.ReloadUnsyncedFilesAndStartUpload), userInfo: nil, repeats: true)
        
        DataManager.fileUploadDelegate.append(self)
        // check if unsynced files
        offlineFileList = DataManager.GetUnSyncedFiles()
    }

    override func viewWillAppear(_ animated: Bool) {
        let seconds = 0.05
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.RefreshCellRowsWithFileNames()
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var extraSpaceForNewImages = 0
        if (syncedFileList.count<=0){
            syncedFileList = DataManager.GetSyncedFiles()
            offlineFileList = DataManager.GetUnSyncedFiles()
        }
        if (syncedFileList.count<=0){
            extraSpaceForNewImages = 14
        }
        let rows =  TotalFileList() + extraSpaceForNewImages
//        print(rows)
        return rows
    }
    
    private func TotalFileList()->Int{
        return syncedFileList.count + offlineFileList.count
    }

//
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath) as! FileTableViewCell
        cell.ClearFileData()

        if (indexPath.row < offlineFileList.count){
            let file = offlineFileList[indexPath.row]
            fileToRow[file.FileName] = indexPath.row
            cell.AddFileData(file: file)
        }
            
        else if(indexPath.row < TotalFileList()){
            let file = syncedFileList[indexPath.row - offlineFileList.count]
            fileToRow[file.FileName] = indexPath.row
            cell.AddFileData(file: file)
        }
        
        return cell
    }

  

}
//@objc
protocol ImageFileHandler{
    func OnFileUploadFinish(file:CorroDataFile);
    func OnFileUploadError();
}
//@objc extension OfflineImageHandler{
//    func ReloadUnsyncedFilesAndStartUpload ();
//}
