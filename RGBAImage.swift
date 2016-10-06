// cited from ios Intro

import UIKit

public struct Pixel {
    public var value: UInt32
    
    public var red: UInt8 {
        get {
            return UInt8(value & 0xFF)
        }
        set {
            value = UInt32(newValue) | (value & 0xFFFFFF00)
        }
    }
    
    public var green: UInt8 {
        get {
            return UInt8((value >> 8) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF)
        }
    }
    
    public var blue: UInt8 {
        get {
            return UInt8((value >> 16) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF)
        }
    }
    
    public var alpha: UInt8 {
        get {
            return UInt8((value >> 24) & 0xFF)
        }
        set {
            value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF)
        }
    }
}


// change "struct RGBAImage" from swift2 to swift3
public struct RGBAImage {
    public var pixels: [Pixel]
    
    public var width: Int
    public var height: Int
    public var size: Int {
        if self.width == 0 || self.height == 0 {
            return 0
        }
        return  width * height
}
    public init?(image: UIImage) {
        //        guard let cgImage = image.CGImage else { return nil }
        guard let cgImage = image.cgImage else { return nil }
        
        
        // Redraw image for correct pixel format
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        //        var bitmapInfo: UInt32 = CGBitmapInfo.ByteOrder32Big.rawValue
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        
        //        bitmapInfo |= CGImageAlphaInfo.PremultipliedLast.rawValue & CGBitmapInfo.AlphaInfoMask.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        
        width = Int(image.size.width)
        height = Int(image.size.height)
        let bytesPerRow = width * 4
        
        //        let imageData = UnsafeMutablePointer<Pixel>.alloc(width * height)
        let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        
        
        //        guard let imageContext = CGBitmapContextCreate(imageData, width, height, 8, bytesPerRow, colorSpace, bitmapInfo) else { return nil }
        guard let imageContext = CGContext(data: imageData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
        
        //        CGContextDrawImage(imageContext, CGRect(origin: CGPointZero, size: image.size), cgImage)
        //        context.draw(image!.cgImage!, in: CGRect(x: 0.0,y: 0.0,width: image!.size.width,height: image!.size.height))
        imageContext.draw(cgImage, in: CGRect(x: 0.0, y: 0.0, width: image.size.width, height: image.size.height))
        
        let bufferPointer = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
        pixels = Array(bufferPointer)
        
        //        imageData.destroy()
        //        imageData.dealloc(width * height)
        imageData.deinitialize()
        imageData.deallocate(capacity: width * height)
        
    }
    
    public func toUIImage() -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        //        var bitmapInfo: UInt32 = CGBitmapInfo.ByteOrder32Big.rawValue
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        //        bitmapInfo |= CGImageAlphaInfo.PremultipliedLast.rawValue & CGBitmapInfo.AlphaInfoMask.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        
        let bytesPerRow = width * 4
        
        //        let imageDataReference = UnsafeMutablePointer<Pixel>(pixels)
        let imageDataReference = UnsafeMutablePointer<Pixel>(mutating: pixels)
        
        defer {
            //            imageDataReference.destroy()
            imageDataReference.deinitialize()
        }
        //        let imageContext = CGBitmapContextCreateWithData(imageDataReference, width, height, 8, bytesPerRow, colorSpace, bitmapInfo, nil, nil)
        let imageContext = CGContext(data: imageDataReference, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)
        
        //        guard let cgImage = CGBitmapContextCreateImage(imageContext) else {return nil}
        guard let cgImage = imageContext!.makeImage() else {return nil}
        
        let image = UIImage(cgImage: cgImage)
        
        return image
    }
}
