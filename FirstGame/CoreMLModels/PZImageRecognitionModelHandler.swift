//
//  ModelHandler.swift
//  FirstGame
//
//  Created by Gennaro Frazzingaro on 8/7/17.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import CoreML
import Vision

let kPZSqueezeModelConfidenceThreshold: Float = 0.3

enum PZModelError: CustomNSError, LocalizedError {
    case generic(String)
    
    public static var errorDomain: String {
        return Bundle.main.bundleIdentifier ?? ""
    }
    
    public var errorCode: Int {
        switch self {
        case .generic: return 100
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .generic(let s): return s
        }
    }
    
    public var errorUserInfo: [String : Any] {
        return ["localizedDescription": self.errorDescription ?? ""]
    }
}

class PZImageRecongnitionModelHandler: NSObject {
    
    private let predictionSerialQueue = DispatchQueue(
        label: "com.puzzles.ImageRecongnitionModelHandler.prediction.serial",
        qos: .userInteractive
    )

    func predict(image: PZResource, completion: @escaping (PZLabel?, Error?) -> ()) {
        
        guard let ciImage = image.image else {
            let error = PZModelError.generic("Resource unavailable")
            completion(nil, error)
            return
        }
        
        do {
            //
            // Create Vision wrapper on the CoreML model
            //
            let model = try VNCoreMLModel(for: SqueezeNet().model)
            
            //
            // Initialize request and result handler
            //
            let request = VNCoreMLRequest(model: model) {
                request, _err in
                
                var result: PZLabel? = nil
                var error: Error? = nil
                
                if let err = _err {
                    error = err
                } else if let results = request.results as? [VNClassificationObservation],
                    let topResult = results.first {
                    if topResult.confidence > kPZSqueezeModelConfidenceThreshold {
                        result = PZLabel(identifier: topResult.identifier)
                    }
                } else {
                    error = PZModelError.generic("unexpected result type from VNCoreMLRequest")
                }
                
                completion(result, error)
            }
            
            //
            // Do the prediction
            //
            let handler = VNImageRequestHandler(ciImage: ciImage)
            self.predictionSerialQueue.async {
                do { try handler.perform([request]) }
                catch { completion(nil, error) }
            }
            
        } catch {
            completion(nil, error)
        }
    }
    
}
