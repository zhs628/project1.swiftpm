//
//  File.swift
//  
//
//  Created by rzq on 2024/2/25.
//

import Foundation
import SpriteKit

class BackgroundManager {

    var levelStr: String = ""
    
    var projectCore: ProjectCore! = nil
    var scene: FloatingScene! = nil
    var backgrounds: [BackdropEntity] = []

    
    required init(projectCore:ProjectCore, scene:FloatingScene) {
        
        self.projectCore = projectCore
        self.scene = scene
        
    }
    
    func initToTickStart() {
        for entity in self.backgrounds {
            entity.initToTickStart()
        }
    }
    
    func tickEnd() {
        for entity in self.backgrounds {
            entity.tickEnd()
        }
    }
    
    func setup() {
        return
    }

    
    func deleteBackgrounds() {
        for background in self.backgrounds {
            background.delete()
        }
        self.backgrounds = []
    }
    
    func initEntities() {
        self.deleteBackgrounds()
        var enties:[BackdropEntity] = []
        
        for (index, entyType) in BACKDROP_ENTITIES_LIST[self.levelStr]!.enumerated() {

            let enty = BackdropEntity.makeEntity(scene: self.scene, projectCore: self.projectCore, entityClass: entyType, detectPos: DETECTED_COMPONENT_POSITIONS[self.levelStr]![index])
            enties.append(enty)
        }

        
        for (index, (x,y)) in ATTACHED_COMPONENT_POSITIONS[self.levelStr]!.enumerated() {
            
            let square = self.scene.gridFrame.selectSquare(x: x, y: y)!
            
            enties[index].attachToBlock(x: x, y: y, offsetX: square.sideLength*enties[index].squareOffsetX, offsetY:square.sideLength*enties[index].squareOffsetY)
        }
        
        self.backgrounds = enties
    }
    
    
    static func makeManager(projectCore:ProjectCore, scene:FloatingScene, managerLevelStr:String) -> BackgroundManager? {
        
        if managerLevelStr.contains("level"){
            let m =  BackgroundManager(projectCore: projectCore, scene: scene)
            m.levelStr = managerLevelStr
            return m
        }
        else {
            return nil
        }
    }

        
        
    
    
}


