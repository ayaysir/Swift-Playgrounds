//
//  Flow.swift
//  AudioKit Cookbook Copy
//
//  Created by 윤범태 on 6/19/25.
//

import Foundation
import SwiftUI
import Flow

final class FlowConductor: ObservableObject {
  @Published var patch: Patch = .init(nodes: [], wires: [])
  @Published var selection = Set<NodeIndex>()
  @Published var segIndex = 0 {
    didSet {
      if segIndex == 1 {
        randomPatch()
      } else {
        simplePatch()
      }
    }
  }
  
  init() {
    simplePatch()
  }
  
  func simplePatch() {
    let generator = Node(
      name: "generator",
      titleBarColor: .cyan,
      outputs: ["out"]
    )
    let processor = Node(
      name: "processor",
      titleBarColor: .pink,
      outputs: ["out"]
    )
    let mixer = Node(
      name: "mixer",
      titleBarColor: .gray,
      inputs: ["in1", "in2"],
      outputs: ["out"]
    )
    let output = Node(
      name: "output",
      titleBarColor: .teal,
      inputs: ["in"]
    )
    
    let nodes = [
      generator, processor,
      generator, processor,
      mixer, output,
    ]
    
    // ID (nodeIndex, portIndex)
    // 노드 인덱스는 nodes의 인덱스 (0 based)
    // 예 OutputID(2, 0) => 1번 노드의 0번 포트
    let wires = Set(
      [
        Wire(from: OutputID(0, 0), to: InputID(1, 0)), // gen 1 -> proc 1
        Wire(from: OutputID(1, 0), to: InputID(4, 0)), // proc 1 -> mixer
        Wire(from: OutputID(2, 0), to: InputID(3, 0)), // gen 2 -> proc 2
        Wire(from: OutputID(3, 0), to: InputID(4, 1)), // proc 2 -> mixer
        Wire(from: OutputID(4, 0), to: InputID(5, 0)), // mixer -> output
      ]
    )
    
    var patch = Patch(nodes: nodes, wires: wires)
    // 맨 마지막 노드의 위치 (나머지 노드는 이 노드로부터 역산)
    patch.recursiveLayout(nodeIndex: 5, at: CGPoint(x: 800, y: 50))
    
    self.patch = patch
  }

  /// Bit of a stress test to show how Flow performs with more nodes.
  func randomPatch() {
    var randomNodes: [Node] = []
    for n in 0 ..< 50 {
      let randomPoint = CGPoint(
        x: 1000 * Double.random(in: 0 ... 1),
        y: 1000 * Double.random(in: 0 ... 1)
      )
      let titleBarColor = Color(
        red: .random(in: 0.5...1),
        green: .random(in: 0.5...1),
        blue: .random(in: 0.5...1)
      )
      randomNodes.append(
        Node(
          name: "node\(n)",
          position: randomPoint,
          titleBarColor: titleBarColor,
          inputs: ["In"],
          outputs: ["Out"]
        )
      )
    }
    
    var randomWires: Set<Wire> = []
    for n in 0 ..< 50 {
      randomWires.insert(Wire(from: OutputID(n, 0), to: InputID(Int.random(in: 0 ... 49), 0)))
    }
    
    self.patch = Patch(nodes: randomNodes, wires: randomWires)
  }
}

struct FlowView: View {
  @StateObject private var conductor = FlowConductor()
  
  var body: some View {
    VStack(spacing: 0) {
      Picker("Select the Patch", selection: $conductor.segIndex) {
        Text("Simple")
          .tag(0)
        Text("Random")
          .tag(1)
      }
      .pickerStyle(.segmented)
      NodeEditor(
        patch: $conductor.patch,
        selection: $conductor.selection
      )
      .onAppear {
        forceOrientation(to: .landscape)
      }
      .onDisappear {
        forceOrientation(to: .all)
      }
    }
  }
}

#Preview {
  FlowView()
}
