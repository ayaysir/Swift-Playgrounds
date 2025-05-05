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
      return vector_float3(
        self.transform.m31.osSafeVector,
        self.transform.m32.osSafeVector,
        self.transform.m33.osSafeVector
      )
    }()
  }
  
  /**
   The Camera up orientation vector as vector_float3.
   */
  var upVector: vector_float3 {
    {
      return vector_float3(
        self.transform.m21.osSafeVector,
        self.transform.m22.osSafeVector,
        self.transform.m23.osSafeVector
      )
    }()
  }
}
