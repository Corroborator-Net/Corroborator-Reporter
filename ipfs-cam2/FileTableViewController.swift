//
//  FileTableViewController.swift
//  ipfs-cam2
//
//  Created by Ian Philips on 9/28/19.
//  Copyright © 2019 Ian Philips. All rights reserved.
//

import UIKit

class FileTableViewController: UITableViewController {

    public func PrepareCells(){
//        tableView.beginUpdates()
//        tableView.insertRows(at: [IndexPath(row: 10, section: 0)], with: .automatic)
//        tableView.endUpdates()
    }
    
    public func ReloadDictionary (){
        

        
        let offlineDictionary = UserDefaults.standard.stringArray(forKey: "offlineQueue") ?? [String]()
        if (offlineDictionary.count==0){
            print("empty")
            return
        }


        for i in 0...offlineDictionary.count-1 {
            let cell =  tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? FileTableViewCell
            if (cell!.FileLabel == nil){
                let label = UILabel(frame: CGRect(x: 20, y: 20, width: 150, height: 20))
                cell?.FileLabel = label
                cell?.addSubview(label)
            }
            cell?.FileLabel!.text = "Unsynced File " + String(i)
            
        
        }

        // not connected? don't do anything else
        if !Reachability.isConnectedToNetwork()
        {
            return
        }
        
       
        var newOfflineDictionary = offlineDictionary

        for (index, filePath) in offlineDictionary.enumerated().reversed() {
            newOfflineDictionary.remove(at: index)
            UserDefaults.standard.set(newOfflineDictionary,forKey: "offlineQueue")

            if (filePath.contains("/")){
                continue
            }
            let image = self.load(fileName: filePath)!.jpegData(compressionQuality: 100)
            ImageSaver.uploadToIPFS(image: image!, VC: self)
        }
        for i in 0...offlineDictionary.count-1 {
            let cell =  tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? FileTableViewCell
            cell?.FileLabel!.text=""
            
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
        return 14
    }

//
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath) as! FileTableViewCell
        // Configure the cell...
        let index = indexPath.row
        if ( index == 13){
            let seconds = 0.1
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.ReloadDictionary()
            }

        }
        return cell
    }
//

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
