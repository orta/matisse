//
//  ResizeTransformation.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import UIKit


/// An `ImageTransformation` to resize an image.
///
@objc(MTSResizeTransformation)
public class ResizeTransformation: NSObject, ImageTransformation {

    private let targetSize: CGSize
    private let contentMode: UIViewContentMode
    private let deviceScale: CGFloat
    private let scaledTargeSize: CGSize


    // MARK: - Initialization

    /// Create a new `ResizeTransformation` with the given target size and content mode.
    ///
    /// - Parameters:
    ///   - targetSize:  The target image size.
    ///   - contentMode: The content mode describing how the image should fit into the target size.
    ///
    public convenience init(targetSize: CGSize, contentMode: UIViewContentMode) {
        self.init(targetSize: targetSize, contentMode: contentMode, deviceScale: UIScreen.mainScreen().scale)
    }

    /// Create a new `ResizeTransformation` with the given target size and content mode.
    ///
    /// - Parameters:
    ///   - targetSize:  The target image size.
    ///   - contentMode: The content mode describing how the image should fit into the target size.
    ///   - deviceScale: The device scale which is applied to the target size.
    ///
    public init(targetSize: CGSize, contentMode: UIViewContentMode, deviceScale: CGFloat) {
        self.targetSize = targetSize
        self.contentMode = contentMode
        self.deviceScale = deviceScale

        self.scaledTargeSize = CGSize(width: (targetSize.width * deviceScale), height: (targetSize.height * deviceScale))
    }


    // MARK: - Transforming the Image

    /// Resizes the image with the configured parameters.
    ///
    /// - Parameters:
    ///   - image: The image to transform
    ///
    /// - Throws:
    ///   If the image cannot be resized.
    ///
    /// - Returns:
    ///   The transformed image.
    ///
    public func transformImage(image: CGImage) throws -> CGImage {
        let bitsPerComponent = CGImageGetBitsPerComponent(image)
        let bytesPerRow = CGImageGetBytesPerRow(image)
        let colorSpace = CGImageGetColorSpace(image)
        let bitmapInfo = CGImageGetBitmapInfo(image)

        let originalSize = CGSize(width: CGImageGetWidth(image), height: CGImageGetHeight(image))

        let context = CGBitmapContextCreate(nil,
            Int(scaledTargeSize.width),
            Int(scaledTargeSize.height),
            bitsPerComponent,
            bytesPerRow,
            colorSpace,
            bitmapInfo.rawValue
        )

        CGContextSetInterpolationQuality(context, .High)
        CGContextDrawImage(context, calculateImageRectWithOriginalSize(originalSize), image)

        if let scaled = CGBitmapContextCreateImage(context) {
            return scaled
        } else {
            throw NSError.matisseCreationError("Could not resize image")
        }
    }

    private func calculateImageRectWithOriginalSize(originalSize: CGSize) -> CGRect {
        switch contentMode {
        case .ScaleToFill:
            return CGRect(origin: CGPointZero, size: scaledTargeSize)

        case .ScaleAspectFill:
            let widthScale = originalSize.width / scaledTargeSize.width
            let heightScale = originalSize.height / scaledTargeSize.height
            let scale = min(widthScale, heightScale)
            let scaledSize = CGSize(width: round(originalSize.width / scale), height: round(originalSize.height / scale))
            return centerRectWithSize(scaledSize, inSize: scaledTargeSize)

        default:
            fatalError("Unsupported contentMode: \(contentMode)")
        }
    }

    private func centerRectWithSize(size: CGSize, inSize targetSize: CGSize) -> CGRect {
        let xOffset = round(targetSize.width - size.width) / 2.0
        let yOffset = round(targetSize.height - size.height) / 2.0
        return CGRect(origin: CGPoint(x: xOffset, y: yOffset), size: size)
    }


    // MARK: - Describing the Transformation

    /// A string describing this transformation.
    ///
    public var descriptor: String {
        return "resize(\(targetSize.width),\(targetSize.height),\(deviceScale),\(contentMode.rawValue))"
    }
}
