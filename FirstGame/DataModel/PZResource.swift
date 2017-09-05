//
//  Resource.swift
//  FirstGame
//
//  Created by Gennaro Frazzingaro on 8/7/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import Foundation
import CoreImage

public class PZResource: NSObject {
    let _url: URL?
    let _image: CIImage?
    
    public var label: PZLabel?
    
    init(url: URL, label: PZLabel? = nil) {
        self._url = url
        self._image = nil
        self.label = label
    }
    
    init(image: CIImage, label: PZLabel? = nil) {
        self._url = nil
        self._image = image
        self.label = label
    }
    
    var image: CIImage? {
        if let image = self._image {
            return image
        } else if let url = self._url {
            return CIImage(contentsOf: url)
        } else {
            return nil
        }
    }
}
