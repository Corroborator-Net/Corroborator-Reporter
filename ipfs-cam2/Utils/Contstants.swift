//
//  Contstants.swift
//  ipfs-cam2
//
//  Created by Ian Philips on 10/18/19.
//  Copyright © 2019 Ian Philips. All rights reserved.
//

import Foundation
import CoreGraphics

class Constants:NSObject{
    static let quality:CGFloat = 0.7
    static let FileNameDateFormat = "dd MMM yyyy HH:mm:ss"
    
    static let UserDefaultEncryptionKey = "superSecretKey"
    static let UserEncryptionKeyKey = "UserEncryptionKey"
    static let DeleteLocalPhotosKey = "DeleteLocalPhotos"
    static let UploadToAuditorNodeKey = "UploadToAuditorNode"
    static let CurrentPhotoPurposeKey = "CurrentPhotoPurpose"
    static let CurrentInvestigationIDKey = "CurrentInvestigationID"
    
}
