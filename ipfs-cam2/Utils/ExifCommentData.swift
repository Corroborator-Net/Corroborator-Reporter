//
//  ExifCommentData.swift
//  ipfs-cam2
//
//  Created by Ian Philips on 11/1/19.
//  Copyright © 2019 Ian Philips. All rights reserved.
//

import Foundation

struct ExifComment: Codable{
    var device_id:String
    var department:String
    var purpose:String
    var device_model:String
    var user_name:String
}
