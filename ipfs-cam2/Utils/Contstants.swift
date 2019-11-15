//
//  Contstants.swift
//  ipfs-cam2
//
//  Created by Ian Philips on 10/18/19.
//  Copyright © 2019 Ian Philips. All rights reserved.
//

import Foundation
import CoreGraphics
import TrueTime
class Constants:NSObject{
    
    static var NTPClient:TrueTimeClient?
    
    static let quality:CGFloat = 0.7
    static let FileNameDateFormat = "dd MMM yyyy HH:mm:ss"
    
    static let DTableID = "83769362-85c7-4a0f-bd48-28b5606e29a3"
    static let UserNameKey = "UserName"
    static let UserDepartmentKey = "UserDepartment"
    static let UserDefaultEncryptionKey = "superSecretKey"
    static let UserEncryptionKeyKey = "UserEncryptionKey"
    static let DeleteLocalPhotosKey = "DeleteLocalPhotos"
    static let UploadToAuditorNodeKey = "UploadToAuditorNode"
    static let CurrentPhotoPurposeKey = "CurrentPhotoPurpose"
    static let CurrentInvestigationIDKey = "CurrentInvestigationID"
    
    static let AddPinURL = "https://api.pinata.cloud/pinning/pinFileToIPFS"
    static let RemovePinURL = "https://api.pinata.cloud/pinning/removePinFromIPFS"
    static let PinataHeaders = ["pinata_api_key": "1e194bceca95c082feec",
                                "pinata_secret_api_key":"4e6608680a18727d292df23f12d50520ed7346884831bdbbe577d441727ab359"]
    
}
