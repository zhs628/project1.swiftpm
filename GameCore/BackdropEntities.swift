//
//  File.swift
//  
//
//  Created by rzq on 2024/2/24.
//

import Foundation
import SpriteKit


class BackdropEntity {
    var initTextureIndex: Int = 0
    
    var detectPos: [(x:Int,y:Int)] = []
    
    var attachX: Int? = nil
    var attachY: Int? = nil
    
    // 偏移多少个正方形边长
    var squareOffsetX: Double = 0
    var squareOffsetY: Double = 0
    
    let scene: FloatingScene
    let projectCore: ProjectCore
    
    var imageNameList: [(name:String, anchorRatio:(x:Double,y:Double))] = []
    
    var skNode: SKSpriteNode!
    var anchorNode: SKShapeNode? = nil
        
    var relativeX: Double {
        get {
            return self.skNode.position.x/self.scene.width
        }
        set(val) {
            self.skNode.position.x = val*self.scene.width
        }
    }
    var relativeY: Double {
        get {
            return self.skNode.position.y/self.scene.height
        }
        set(val) {
            self.skNode.position.y = val*self.scene.height
        }
    }
    
    var relativeWidth: Double {
        get {
            return self.skNode.size.width/self.scene.width
        }
        set(val) {
            self.skNode.size.width = val*self.scene.width
        }
    }
    var relativeHeight: Double {
        get {
            return self.skNode.size.height/self.scene.height
        }
        set(val) {
            self.skNode.size.height = val*self.scene.height
        }
    }
    
    var relativeAnchorX: Double {
        get {
            return self.skNode.anchorPoint.x/self.scene.width
        }
        set(val) {
            self.skNode.anchorPoint.x = val*self.scene.width
            if self.anchorNode != nil {
                self.anchorNode!.position.x = val*self.scene.width
            }
            
        }
    }
    var relativeAnchorY: Double {
        get {
            return self.skNode.anchorPoint.y/self.scene.height
        }
        set(val) {
            self.skNode.anchorPoint.y = val*self.scene.height
            if self.anchorNode != nil {
                self.anchorNode!.position.y = val*self.scene.height
            }
            
        }
    }
    
    
    required init(scene:FloatingScene, projectCore: ProjectCore) {
        self.scene = scene
        self.projectCore = projectCore
        self.skNode = SKSpriteNode()
        
        self.scene.addChild(skNode)
        
        self.childInit()
        
    }
    
    func initToTickStart() {
        return
    }
    func tickEnd() {
        return
    }
    
    func childInit() {
        return
    }
    
    static func makeEntity(scene: FloatingScene, projectCore: ProjectCore, entityClass:BackdropEntity.Type, detectPos:[(x:Int,y:Int)]) -> BackdropEntity {
        let e = entityClass.init(scene: scene, projectCore: projectCore)
        e.changeTexture(imageIndex: e.initTextureIndex)
        e.detectPos = detectPos
        return e
    }

    func changeTexture(imageIndex: Int) {
        guard imageIndex >= 0 && imageIndex < self.imageNameList.count else {
            return
        }

        let (textureName, anchor) = self.imageNameList[imageIndex]

                // 修改锚点为新的值
        self.skNode.anchorPoint = CGPoint(
            x: CGFloat(anchor.x),
            y: CGFloat(anchor.y)
        )


        
        // 修改纹理
        let newTexture = SKTexture(imageNamed: textureName)
        self.skNode.texture = newTexture
        
        
        // 显示锚点
        if SHOW_ANCHOR {
            let anchorPointCircle = SKShapeNode(circleOfRadius: 5)
            anchorPointCircle.fillColor = SKColor.red
            anchorPointCircle.position = self.skNode.anchorPoint
            self.skNode.addChild(anchorPointCircle)
            if self.anchorNode != nil {
                self.anchorNode!.removeFromParent()
            }
            self.anchorNode = anchorPointCircle
        }
    }
    
    func getCGPosition() -> CGPoint {
        return self.skNode.position
    }
    
    func setCGPosition(x:CGFloat,y:CGFloat) {
        self.skNode.position = CGPoint(x: x,y: y)
    }
    
    
    // 将node按锚点移动至网格的位于（x，y）的方格的左下角，传入offset设置偏移量
    func attachToBlock(x:Int, y:Int, offsetX:CGFloat=0, offsetY:CGFloat=0) {
        
        var (destX, destY) = self.scene.gridFrame.getFloatPos(x: x, y: y)
        destX += offsetX
        destY += offsetY
        
        self.setCGPosition(x: destX, y: destY)
        
        self.attachX = x
        self.attachY = y
        
    }
    
    func setScale(width:CGFloat, height:CGFloat) {
        self.skNode.size = CGSize(width: width, height: height)
    }
    
    func delete() {
        self.skNode.removeFromParent()
    }
    
    func onPowerOutletAnimating(isActiveList:[Bool?]) {
        return
    }
    
    
}


class Blob: BackdropEntity {
    
    override func childInit() {
        
        self.imageNameList = [
            (name:"blob_not_light", anchorRatio:(x:0.3,y:0.01)),
            (name:"blob_light", anchorRatio:(x:0.3,y:0.01))
        ]
        // 必须指定size
        self.relativeHeight = 0.3
        self.skNode.size.width = self.skNode.size.height*0.8
        self.skNode.alpha = 0.5
        
        self.squareOffsetX = 0
        self.squareOffsetY = 0.5
        self.initTextureIndex = 0
    }
    
    override func onPowerOutletAnimating(isActiveList:[Bool?]) {
        if let isActive = isActiveList[0] {
            if isActive {
                self.changeTexture(imageIndex: 1)
            } else {
                self.changeTexture(imageIndex: 0)
            }
        }
    }
    
    
}


class LandScapeTrafficLight: BackdropEntity {
    
    var red: Bool = false
    var green: Bool = false
    
    override func childInit() {

        self.imageNameList = [
            (name:"traffic_light_red_L", anchorRatio:(x:0.5,y:0)),
            (name:"traffic_light_green_L", anchorRatio:(x:0.5,y:0)),
            (name:"traffic_all_light_L", anchorRatio:(x:0.5,y:0)),
            (name:"traffic_not_light_L", anchorRatio:(x:0.5,y:0)),
        ]
        self.relativeHeight = 0.1
        self.skNode.size.width = self.skNode.size.height*2.85
        self.skNode.alpha = 1
        
        self.squareOffsetY = 1
        
        self.initTextureIndex = 3
    }
    
    override func initToTickStart() {
    }
    
    override func onPowerOutletAnimating(isActiveList:[Bool?]) {
        if let isActiveRed = isActiveList[0] {
            if isActiveRed {
                self.red = true
            } else {
                self.red = false
            }
        }
        if let isActiveRed = isActiveList[1] {
            if isActiveRed {
                self.green = true
            } else {
                self.green = false
            }
        }
    }
    
    override func tickEnd() {
        if self.red && !self.green {
            self.changeTexture(imageIndex: 0)
        }
        if !self.red && self.green {
            self.changeTexture(imageIndex: 1)
        }
        if self.red && self.green {
            self.changeTexture(imageIndex: 2)
        }
        if !self.red && !self.green {
            self.changeTexture(imageIndex: 3)
        }
    }
    
}


class PortraitTrafficLight: BackdropEntity {
    
    var red: Bool = false
    var green: Bool = false
    
    override func childInit() {

        self.imageNameList = [
            (name:"traffic_light_green_P", anchorRatio:(x:0,y:0.5)),
            (name:"traffic_light_red_P", anchorRatio:(x:0,y:0.5)),
            (name:"traffic_all_light_P", anchorRatio:(x:0,y:0.5)),
            (name:"traffic_not_light_P", anchorRatio:(x:0,y:0.5)),
        ]
        self.skNode.size.width = 0.1 * self.scene.height
        self.skNode.size.height = self.skNode.size.width*2.85
        self.skNode.alpha = 1
        
        self.squareOffsetX = 1
        
        self.initTextureIndex = 3
    }
    
    override func initToTickStart() {
    }
    
    override func onPowerOutletAnimating(isActiveList:[Bool?]) {
        if let isActiveRed = isActiveList[0] {
            if isActiveRed {
                self.red = true
            } else {
                self.red = false
            }
        }
        if let isActiveRed = isActiveList[1] {
            if isActiveRed {
                self.green = true
            } else {
                self.green = false
            }
        }
    }
    
    override func tickEnd() {
        if self.red && !self.green {
            self.changeTexture(imageIndex: 0)
        }
        if !self.red && self.green {
            self.changeTexture(imageIndex: 1)
        }
        if self.red && self.green {
            self.changeTexture(imageIndex: 2)
        }
        if !self.red && !self.green {
            self.changeTexture(imageIndex: 3)
        }
    }
    
}


class LandScapeTrafficLightOneInput: BackdropEntity {
    
    var red: Bool = false
    var green: Bool = false
    
    override func childInit() {

        self.imageNameList = [
            (name:"one_traffic_light", anchorRatio:(x:0.5,y:0)),
            (name:"one_traffic_not_light", anchorRatio:(x:0.5,y:0))
        ]
        self.relativeHeight = 0.1
        self.skNode.size.width = self.skNode.size.height*2.85
        self.skNode.alpha = 1
        
        self.squareOffsetY = 1.5
        
        self.initTextureIndex = 0
    }
    
    override func initToTickStart() {
    }
    
    override func onPowerOutletAnimating(isActiveList:[Bool?]) {
        if let isActiveRed = isActiveList[0] {
            if isActiveRed {
                self.red = true
                self.green = false
            } else {
                self.red = false
                self.green = true
            }
        }

    }
    
    override func tickEnd() {
        if self.red && !self.green {
            self.changeTexture(imageIndex: 0)
        }
        if !self.red && self.green {
            self.changeTexture(imageIndex: 1)
        }
        
    }
    
}





class CarBackground: BackdropEntity {
    
    override func childInit() {
        
        self.imageNameList = [
            (name:"car_light", anchorRatio:(x:0.3,y:0.01)),
            (name:"car_not_light", anchorRatio:(x:0.3,y:0.01))
        ]
        // 必须指定size
        self.relativeWidth = 0.09
        self.skNode.size.height = self.skNode.size.width*1.35
        self.skNode.alpha = 1
        
        self.squareOffsetX = 1.8
        self.squareOffsetY = 0
        self.initTextureIndex = 1
    }
    
    override func initToTickStart() {
        let sideLen = self.scene.gridFrame.selectSquare(x: 0, y: 0)!.sideLength
        self.attachToBlock(x: 6, y: 1, offsetX: self.squareOffsetX*sideLen, offsetY: self.squareOffsetY)
    }
    
    override func onPowerOutletAnimating(isActiveList:[Bool?]) {
        if let isActive = isActiveList[0] {
            if isActive {
                self.changeTexture(imageIndex: 1)
                
                // 创建一个向上移动的动作，并添加缓动效果
                let moveAction = SKAction.moveBy(x:0, y: self.scene.height*0.015, duration: 0.5)
                
                // 执行向上移动的动作
                self.skNode.run(moveAction)
                
            } else {
                self.changeTexture(imageIndex: 0)
            }
        }
    }
    
    
}
