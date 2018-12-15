//
//  SPKit
//
//  Copyright (c) 2017 linhay - https://  github.com/linhay
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

import UIKit

#if canImport(UIKit)
import CoreMedia

public extension UIImage{
  /// from CMSampleBuffer
  ///
  /// must import CoreMedia
  /// from: https://stackoverflow.com/questions/15726761/make-an-uiimage-from-a-cmsamplebuffer
  ///
  /// - Parameter sampleBuffer: CMSampleBuffer
  public convenience init?(sampleBuffer: CMSampleBuffer) {
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
    // Get the number of bytes per row for the pixel buffer
    let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
    // Get the number of bytes per row for the pixel buffer
    let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
    // Get the pixel buffer width and height
    let width = CVPixelBufferGetWidth(imageBuffer)
    let height = CVPixelBufferGetHeight(imageBuffer)
    // Create a device-dependent RGB color space
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    // Create a bitmap graphics context with the sample buffer data
    var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue
    bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
    
    //let bitmapInfo: UInt32 = CGBitmapInfo.alphaInfoMask.rawValue
    // Create a Quartz image from the pixel data in the bitmap graphics context
    guard let context = CGContext(data: baseAddress,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,
                                  bytesPerRow: bytesPerRow,
                                  space: colorSpace,
                                  bitmapInfo: bitmapInfo),
      let quartzImage = context.makeImage() else { return nil }
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly)
    // Create an image object from the Quartz image
    self.init(cgImage: quartzImage)
  }
  
}

#endif

// MARK: - 初始化
public extension UIImage{
  
  /// 图像处理: 裁圆
  ///
  /// - Parameter round: 需处理的图片/图片名称
  /// - Returns: 新图
  public convenience init?(round name: String) {
    let img = UIImage(named: name)?.sp.roundImg
    guard let cgImg = img?.cgImage else { return nil }
    self.init(cgImage: cgImg)
  }
  
  /// 获取指定颜色的图片
  ///
  /// - Parameters:
  ///   - color: UIColor
  ///   - size: 图片大小
  public convenience init?(color: UIColor,
                           size: CGSize = CGSize(width: 1, height: 1)) {
    if size.width <= 0 || size.height <= 0 { return nil }
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }
    context.setFillColor(color.cgColor)
    context.fill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    guard let cgImg = image?.cgImage else { return nil }
    self.init(cgImage: cgImg)
  }
  
}


// MARK: - UIImage
public extension SPExtension where Base: UIImage{
  
  /// 图片尺寸: Bytes
  public var sizeAsBytes: Int
  { return base.jpegData(compressionQuality: 1)?.count ?? 0 }
  
  /// 图片尺寸: KB
  public var sizeAsKB: Int {
    let sizeAsBytes = self.sizeAsBytes
    return sizeAsBytes != 0 ? sizeAsBytes / 1024: 0 }
  
  /// 图片尺寸: MB
  public var sizeAsMB: Int {
    let sizeAsKB = self.sizeAsKB
    return sizeAsBytes != 0 ? sizeAsKB / 1024: 0 }
  
  /// 获取 base64 字符串
  ///
  /// - Parameter quality: 图片质量 用于JPEG, 默认为 1
  /// - Returns: base64String
  public func base64String(quality: CGFloat = 1.0) -> String? {
    if let data = base.jpegData(compressionQuality: quality) {
      return data.base64EncodedString()
    }
    
    if let data = base.pngData() {
      return data.base64EncodedString()
    }
    
    return nil
  }
  
}

// MARK: - UIImage
public extension SPExtension where Base: UIImage{
  /// 返回一张没有被渲染图片
  public var original: UIImage { return base.withRenderingMode(.alwaysOriginal) }
  
  /// 返回圆形图片
  public var roundImg: UIImage {
    return base.sp.round(radius: base.size.height * 0.5,
                         corners: .allCorners,
                         borderWidth: 0,
                         borderColor: nil,
                         borderLineJoin: .miter)
  }
  
}

// MARK: - UIImage 图片处理
public extension SPExtension where Base: UIImage{
  
  /// 裁剪对应区域
  ///
  /// - Parameter bound: 裁剪区域
  /// - Returns: 新图
  public func crop(bound: CGRect) -> UIImage {
    guard bound.minX >= base.size.width,bound.minY >= base.size.height else { return base }
    let scaledBounds = CGRect(x: bound.origin.x * base.scale,
                              y: bound.origin.y * base.scale,
                              width: bound.size.width * base.scale,
                              height: bound.size.height * base.scale)
    guard let cgImage = base.cgImage?.cropping(to: scaledBounds) else { return base }
    return UIImage(cgImage: cgImage, scale: base.scale, orientation: .up)
  }
  
  /// 图像处理: 裁圆
  /// - Parameters:
  /// - radius: 圆角大小
  /// - corners: 圆角区域
  /// - borderWidth: 描边大小
  /// - borderColor: 描边颜色
  /// - borderLineJoin: 描边类型
  /// - Returns: 新图
  public func round(radius: CGFloat,
                    corners: UIRectCorner = .allCorners,
                    borderWidth: CGFloat = 0,
                    borderColor: UIColor? = nil,
                    borderLineJoin: CGLineJoin = .miter) -> UIImage {
    var corners = corners
    
    if corners != UIRectCorner.allCorners {
      var  tmp: UIRectCorner = UIRectCorner(rawValue: 0)
      if (corners.rawValue & UIRectCorner.topLeft.rawValue) != 0
      { tmp = UIRectCorner(rawValue: tmp.rawValue | UIRectCorner.bottomLeft.rawValue) }
      if (corners.rawValue & UIRectCorner.topLeft.rawValue) != 0
      { tmp = UIRectCorner(rawValue: tmp.rawValue | UIRectCorner.bottomRight.rawValue) }
      if (corners.rawValue & UIRectCorner.bottomLeft.rawValue) != 0
      { tmp = UIRectCorner(rawValue: tmp.rawValue | UIRectCorner.topLeft.rawValue) }
      if (corners.rawValue & UIRectCorner.bottomRight.rawValue) != 0
      { tmp = UIRectCorner(rawValue: tmp.rawValue | UIRectCorner.topRight.rawValue) }
      corners = tmp
    }
    UIGraphicsBeginImageContextWithOptions(base.size, false, base.scale)
    guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
    let rect = CGRect(x: 0, y: 0, width: base.size.width, height: base.size.height)
    context.scaleBy(x: 1, y: -1)
    context.translateBy(x: 0, y: -rect.height)
    let minSize = min(base.size.width, base.size.height)
    
    if borderWidth < minSize * 0.5{
      let path = UIBezierPath(roundedRect: rect.insetBy(dx: borderWidth, dy: borderWidth),
                              byRoundingCorners: corners,
                              cornerRadii: CGSize(width: radius, height: borderWidth))
      
      path.close()
      context.saveGState()
      path.addClip()
      guard let cgImage = base.cgImage else {
        UIGraphicsEndImageContext()
        return UIImage()
      }
      context.draw(cgImage, in: rect)
      context.restoreGState()
    }
    
    if (borderColor != nil && borderWidth < minSize / 2 && borderWidth > 0) {
      let strokeInset = (floor(borderWidth * base.scale) + 0.5) / base.scale
      let strokeRect = rect.insetBy(dx: strokeInset, dy: strokeInset)
      let strokeRadius = radius > base.scale / 2 ? CGFloat(radius - base.scale / 2): 0
      let path = UIBezierPath(roundedRect: strokeRect, byRoundingCorners: corners, cornerRadii: CGSize(width: strokeRadius, height: borderWidth))
      path.close()
      path.lineWidth = borderWidth
      path.lineJoinStyle = borderLineJoin
      borderColor?.setStroke()
      path.stroke()
    }
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image ?? UIImage()
  }
  
  /// 根据宽度获取对应高度
  ///
  /// - Parameter width: 宽度
  /// - Returns: 新高度
  func aspectHeight(with width: CGFloat) -> CGFloat {
    return (width * base.size.height) / base.size.width
  }
  
  /// 根据高度获取对应宽度
  ///
  /// - Parameter height: 高度
  /// - Returns: 宽度
  func aspectWidth(with height: CGFloat) -> CGFloat {
    return (height * base.size.width) / base.size.height
  }
  
  /// 重设图片大小
  ///
  /// - Parameter size: 新的尺寸
  /// - Returns: 新图
  public func reSize(size: CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
    base.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    let reSizeImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return reSizeImage ?? base
  }
  
  /// 根据宽度重设大小
  ///
  /// - Parameter width: 宽度
  /// - Returns: 新图
  public func resize(width: CGFloat) -> UIImage {
    let aspectSize = CGSize(width: width, height: aspectHeight(with: width))
    UIGraphicsBeginImageContext(aspectSize)
    base.draw(in: CGRect(origin: CGPoint.zero, size: aspectSize))
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return img ?? base
  }
  
  /// 根据高度重设大小
  ///
  /// - Parameter height: 高度
  /// - Returns: 新图
  public func resize(height: CGFloat) -> UIImage {
    let aspectSize = CGSize(width: aspectWidth(with: height), height: height)
    UIGraphicsBeginImageContext(aspectSize)
    base.draw(in: CGRect(origin: CGPoint.zero, size: aspectSize))
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return img ?? base
  }
  
}

// MARK: - UIImage 尺寸相关
public extension SPExtension where Base: UIImage{
  
  /// 等比率缩放
  ///
  /// - Parameter multiple: 倍数
  /// - Returns: 新图
  public func scale(multiple: CGFloat)-> UIImage {
    let newSize = CGSize(width: base.size.width * multiple, height: base.size.height * multiple)
    return reSize(size: newSize)
  }
  
  /// 压缩图片
  ///
  /// - Parameter rate: 压缩比率
  /// - Returns: 新图
  public func compress(rate: CGFloat) -> Data? {
    return base.jpegData(compressionQuality: rate)
  }
  
}
