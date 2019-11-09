//
// Generate EXIF GPS metadata
// Swift 3
// Exif Version 2.2.0.0 supports decimal degrees

import Foundation
import CoreLocation
import ImageIO
import CoreImage
import UIKit


extension CLLocation {
    
    func exifMetadata(heading: CLHeading? = nil) -> NSMutableDictionary {
        
        let GPSMetadata = NSMutableDictionary()
        let altitudeRef = Int(self.altitude < 0.0 ? 1 : 0)
        let latitudeRef = self.coordinate.latitude < 0.0 ? "S" : "N"
        let longitudeRef = self.coordinate.longitude < 0.0 ? "W" : "E"
        
        // GPS metadata
        GPSMetadata[(kCGImagePropertyGPSLatitude as String)] = abs(self.coordinate.latitude)
        GPSMetadata[(kCGImagePropertyGPSLongitude as String)] = abs(self.coordinate.longitude)
        GPSMetadata[(kCGImagePropertyGPSLatitudeRef as String)] = latitudeRef
        GPSMetadata[(kCGImagePropertyGPSLongitudeRef as String)] = longitudeRef
        GPSMetadata[(kCGImagePropertyGPSAltitude as String)] = Int(abs(self.altitude))
        GPSMetadata[(kCGImagePropertyGPSAltitudeRef as String)] = altitudeRef
        GPSMetadata[(kCGImagePropertyGPSTimeStamp as String)] = self.timestamp.isoTime()
        GPSMetadata[(kCGImagePropertyGPSDateStamp as String)] = self.timestamp.isoDate()
        GPSMetadata[(kCGImagePropertyGPSVersion as String)] = "2.2.0.0"
        
        if let heading = heading {
            GPSMetadata[(kCGImagePropertyGPSImgDirection as String)] = heading.trueHeading
            GPSMetadata[(kCGImagePropertyGPSImgDirectionRef as String)] = "T"
        }
        
        return GPSMetadata
    }
}

extension Date {
    
    func isoDate() -> String {
        let f = DateFormatter()
        f.timeZone = TimeZone(abbreviation: "UTC")
        f.dateFormat = "yyyy:MM:dd"
        return f.string(from: self)
    }
    
    func isoTime() -> String {
        let f = DateFormatter()
        f.timeZone = TimeZone(abbreviation: "UTC")
        f.dateFormat = "HH:mm:ss.SSSSSS"
        return f.string(from: self)
    }
}

extension UIImage {
    
    func resizeImage(_ dimension: CGFloat, opaque: Bool, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage
        
        let size = self.size
        let aspectRatio =  size.width/size.height
        
        switch contentMode {
        case .scaleAspectFit:
            if aspectRatio > 1 {                            // Landscape image
                width = dimension
                height = dimension / aspectRatio
            } else {                                        // Portrait image
                height = dimension
                width = dimension * aspectRatio
            }
            
        default:
            fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
        }
        
        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = opaque
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
            newImage = renderer.image {
                (context) in
                self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        return newImage
    }
}
