//
//  ContentView.swift
//  AddingVirtualObjects
//
//  Created by Mohammad Azam on 2/13/24.
//

import SwiftUI
import RealityKit
import Combine

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

class Coordinator {
    
    var arView: ARView?
    private var cancellable: AnyCancellable?
    
    @objc func tapped(_ recognizer: UITapGestureRecognizer) {
        
        guard let arView = arView else { return }
        let location = recognizer.location(in: arView)
        
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        if let result = results.first {
            
            cancellable = Entity.loadModelAsync(named: "shoe")
                .sink { completion in
                    switch completion {
                        case .failure(let error):
                            print(error)
                        case .finished:
                            break
                    }
                } receiveValue: { entity in
                    let anchor = AnchorEntity(raycastResult: result)
                    anchor.position.y = 0.5
                    
                    // add collision shapes
                    entity.generateCollisionShapes(recursive: true)
                    // enable physics
                    entity.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)

                    anchor.addChild(entity)
                    arView.scene.addAnchor(anchor)
                }
        }
        
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped)))
        
        // create floor anchor
        let floorAnchor = AnchorEntity(plane: .horizontal)
        
        // create floor mesh
        let floorMesh = MeshResource.generatePlane(width: 0.5, depth: 0.5)
        // create floor entity
        let floor = ModelEntity(mesh: floorMesh, materials: [SimpleMaterial(color: .gray, isMetallic: true)])
        // create collision shapes
        floor.generateCollisionShapes(recursive: true)
        // give floor static physics body
        floor.physicsBody = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .static)
        
        // add floor to the anchor
        floorAnchor.addChild(floor)
        
        // add anchor to the view
        arView.scene.addAnchor(floorAnchor)
        
        context.coordinator.arView = arView
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
}

#Preview {
    ContentView()
}
