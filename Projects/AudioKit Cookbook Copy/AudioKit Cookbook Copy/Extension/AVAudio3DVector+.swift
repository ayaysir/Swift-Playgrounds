//
//  AVAudio3DVector+.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 4/29/25.
//

import SceneKit

// Helpers to get Camera Up and Forward
extension SCNNode {
  /**
   The Camera forward orientation vector as vector_float3.
   */
  var forwardVector: vector_float3 {
    {
      return vector_float3(self.transform.m31,
                           self.transform.m32,
                           self.transform.m33)
    }()
  }
  
  /**
   The Camera up orientation vector as vector_float3.
   */
  var upVector: vector_float3 {
    {
      return vector_float3(self.transform.m21,
                           self.transform.m22,
                           self.transform.m23)
    }()
  }
}
