//
//  ContentView.swift
//  AddingVirtualObjects
//
//  Created by Mohammad Azam on 2/13/24.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

enum EntityName {
    case earth
    case cube
}

extension EntityName {
    var name: String {
        switch self {
            case .earth:
                return "Earth"
            case .cube:
                return "Cube"
        }
    }
}

class Coordinator {
    
    var arView: ARView?
    private var timer: Timer?
    
    private func rotateEntity(_ entity: ModelEntity) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
            // rotate the entity
            entity.transform.rotation *= simd_quatf(angle: 0.01, axis: [0, 1, 0])
        })
    }
    
    @objc func tapped(_ recognizer: UITapGestureRecognizer) {
        
        guard let arView = arView else { return }
        
        let location = recognizer.location(in: arView)
        if let entity = arView.entity(at: location) as? ModelEntity {
            
            if entity.name == EntityName.earth.name {
                rotateEntity(entity)
            } else {
                entity.model?.materials = [SimpleMaterial(color: .orange, isMetallic: true)]
            }
           
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tapped)))
        
        // create the box mesh
        let boxMesh = MeshResource.generateBox(size: 0.3, cornerRadius: 0.003)
        // create the box entity
        let box = ModelEntity(mesh: boxMesh, materials: [SimpleMaterial(color: .purple, isMetallic: true)])
        box.name = EntityName.cube.name
        // make sure that the box can have shapes so it can be interacted with
        box.generateCollisionShapes(recursive: true)
      
        // sphere
        let sphereMesh = MeshResource.generateSphere(radius: 0.3)
        // sphere material
        var sphereMaterial = SimpleMaterial()
        let texture = try? TextureResource.load(named: "earth.jpeg")
        if let texture {
            sphereMaterial.color = .init(texture: .init(texture))
        }
        
        // create the sphere entity
        let sphere = ModelEntity(mesh: sphereMesh, materials: [sphereMaterial])
        sphere.name = EntityName.earth.name
        sphere.position.y = 0.5
        sphere.generateCollisionShapes(recursive: true)
        
        // create the anchor
        let anchor = AnchorEntity(plane: .horizontal)
        // add box to the anchor
        anchor.addChild(box)
        // add sphere to the anchor
        anchor.addChild(sphere)
        
        // add anchor to the scene
        arView.scene.addAnchor(anchor)
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
