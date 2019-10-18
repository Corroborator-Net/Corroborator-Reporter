//
//  FileTableViewCell.swift
//  ipfs-cam2
//
//  Created by Ian Philips on 9/28/19.
//  Copyright © 2019 Ian Philips. All rights reserved.
//

import UIKit

class FileTableViewCell: UITableViewCell {
var FileLabel: UILabel?
    
    
    public func AddFileData(fileName:String){
        if (FileLabel == nil)
        {
            let label = UILabel(frame: CGRect(x: 20, y: 20, width: 300, height: 20))
            FileLabel = label
            addSubview(label)
        }
        FileLabel!.text = fileName
    }
    
    public func ClearFileData(){
        if (FileLabel != nil)
        {
            FileLabel!.text = ""
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
