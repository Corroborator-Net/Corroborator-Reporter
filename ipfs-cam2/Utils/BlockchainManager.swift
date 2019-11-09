//
//  BlockchainManager.swift
//  ipfs-cam2
//
//  Created by Ian Philips on 11/6/19.
//  Copyright © 2019 Ian Philips. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON


class BlockchainManager{
    
    static let cryptLib = CryptLib()

    // TODO: source the date and location from our image's metadata and not at time of creation
    public static func UploadCIDToEthereum(CID:String, sourceMetadata:Data){
        
        let (dateTime, location) = BlockchainManager.GetMetadata(image: sourceMetadata)

        let key = Constants.UserKey
        let records : [String] = [Encrypt(plainText: CID, key: key), Encrypt(plainText: dateTime, key: key), Encrypt(plainText: location, key: key)]
    
        
        let parameters: Parameters = [ "tableId" : "b5c44420-799c-4ab9-8c0d-1045106fbd2d", "record" :  records]
        let urlString = "https://api.atra.io/prod/v1/dtables/records"
        let headers: HTTPHeaders = ["x-api-key": "vdssu05AWO6yAG4ojL4Sv6I9RkAGCak19hBhTVpm"]
        let url = URL.init(string: urlString)
        Alamofire.request(url!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result
            {
            case .success(let json):
                print(json)
            case .failure(let error):
                print(error.localizedDescription)
                
            }
        }
    }
    
    public static func GetMetadata(image: Data)-> (String, String){
        let source: CGImageSource = CGImageSourceCreateWithData(((image as! CFMutableData)), nil)!
        let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [AnyHashable: Any]
        let gps = metadata![(kCGImagePropertyGPSDictionary as String)] as! [AnyHashable: Any]
        let datestamp = gps[(kCGImagePropertyGPSDateStamp)] as! String
        let formattedDate = datestamp.replacingOccurrences(of: ":", with: "-") + "T"
        let timestamp = gps[(kCGImagePropertyGPSTimeStamp)] as! String +
            TimeZone.current.offsetFromUTC()
        let formattedDateAndTime = formattedStringFromStringDate(isoDate: formattedDate+timestamp)
        
        let lat = gps[(kCGImagePropertyGPSLatitude as String)] as! NSNumber
        let long = gps[(kCGImagePropertyGPSLongitude as String)] as! NSNumber
        return (formattedDateAndTime, "lat:\(lat), long:\(long)")
    }
    
    
    // returns UTC time
    static func formattedStringFromStringDate(isoDate:String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        let date = dateFormatter.date(from:isoDate)!
        
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.FileNameDateFormat
        return formatter.string(from: date)
    }
    
    
    static func Encrypt(plainText:String, key:String ) -> String{
        
        let cipherText = cryptLib.encryptPlainTextRandomIV(withPlainText: plainText, key: key)
//        print("cipherText \(cipherText! as String)")
        
//        let decryptedString = cryptLib.decryptCipherTextRandomIV(withCipherText: cipherText, key: key)
//        print("decryptedString \(decryptedString! as String)")
        return cipherText!
        
    }
    
}
extension TimeZone {
    
    func offsetFromUTC() -> String
    {
        let localTimeZoneFormatter = DateFormatter()
        localTimeZoneFormatter.timeZone = self
        localTimeZoneFormatter.dateFormat = "Z"
        return localTimeZoneFormatter.string(from: Date())
    }
    
    func offsetInHours() -> String
    {
        
        let hours = secondsFromGMT()/3600
        let minutes = abs(secondsFromGMT()/60) % 60
        let tz_hr = String(format: "%+.2d:%.2d", hours, minutes) // "+hh:mm"
        return tz_hr
    }
}
