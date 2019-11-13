//
//  FileTableViewCell.swift
//  ipfs-cam2
//
//  Created by Ian Philips on 9/28/19.
//  Copyright © 2019 Ian Philips. All rights reserved.
//

import UIKit

class FileTableViewCell: UITableViewCell {
//var FileLabel: UILabel?
    @IBOutlet weak var ThumbnailView: UIImageView!
    @IBOutlet weak var StatusLabel: UILabel!
    @IBOutlet weak var FileLabel: UILabel!
    
    public func AddFileData(file:CorroDataFile){
        FileLabel.text = file.FileName
        StatusLabel.text = "Pending"
        StatusLabel.textColor = UIColor.red

        if (file.Synced){
           MarkAsSynced()
        }
        
        ThumbnailView.image = file.GetThumbnailImage()

    }
    
    public func MarkAsUploading(){
        StatusLabel.text = "uploading..."

    }
    
    public func MarkAsSynced(){
        StatusLabel.text = "Reported"
        StatusLabel.textColor = UIColor.green
    }
    
    public func ClearFileData(){
        FileLabel.text = ""
        StatusLabel.text = ""
        ThumbnailView.image = nil

    }
    
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        // Configure the view for the selected state
//    }

}
