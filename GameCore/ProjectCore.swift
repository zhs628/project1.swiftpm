//
//  File.swift
//  
//
//  Created by rzq on 2024/2/14.
//

import Foundation
import SwiftUI
import SpriteKit


class ProjectCore: CustomStringConvertible {
    // 所有组件的管理者，所有组件的创建，存在，和销毁完全由本类决定
    // 向外部提供创建组件，销毁组件，查看组件状态的接口
    // 向外部提供启动组件组成的电路的接口
    
    // 当前关卡
    var currentLevel: String
    
    var _t: Int = -1
    // 当前时间刻
    var t: Int {
        get {
            return self._t
        }
        set(val) {
            self.scene.progressBarObj.updatePercent(percent: Float(self._t)/Float(LEVELS_INPUT_OUTPUT_MAPPING[self.currentLevel]!.count))
            self._t = val
        }
    }
    
    // 存储元件的容器
    var componentList: [Component] = []
    
    // 和场景之间维持互相引用
    var scene: FloatingScene
    
    // 信号传播路径树的根节点数组
    var signalPathNodes: [SignalPathNode] = []
    
    
    
    // 信号传播路径树数组的最大深度
    var maxDepth: Int {
        get {
            return self.signalPathNodes.map{$0.maxDepth}.max() ?? -1
        }
    }
    // 表示在编辑模式下在工作台中所选中的 component
    var _selectedComponent: Component? = nil
    var selectedComponent: Component? {
        get {
            return self._selectedComponent
        }
        set(val) {
            // 设置上一次选中元件的 nodeHasSelected = false
            if let lastSelectedNode = self._selectedComponent {
                lastSelectedNode.nodeHasSelected = false
            }
            
            // 当本次选中和上一次选中的元件是同一个，那么取消选中状态
            if (val == self._selectedComponent) {
                self._selectedComponent = nil
                return
            }
            
            // 如果的确有选中元件，而不是nil, 那么设置它的 nodeHasSelected = true, 同时设置selectId
            if let selectedComponent = val {
                selectedComponent.nodeHasSelected = true
                
                // 防止玩家放置固定元件的同类元件
                if !selectedComponent.isFixed {
                    self.scene.selectedId.selectRightPannelComponent(componentType: type(of: selectedComponent))

                }
                
                // 左边的信息面板设置为工作台选择的元件
                self.scene.selectedId.leftPannelSelectedId = type(of: selectedComponent)
                
                

            }
            
            
            
            
            self._selectedComponent = val
        }
    }
    
    var description: String {
        get {
            var strList:[String] = []
            //         (x: 1, y: 1, rotate: 0, isMirror: false, componentClass: PowerSource.self),
            for component in componentList {
                strList.append(
                    "(x: \(component.x), y: \(component.y), rotate: \(component.rotate), isMirror: \(component.isMirror), componentClass: \(component.getClassName()).self)"
                )
            }
            return strList.joined(separator: ",\n")
            
        }
    }
    
    
    
    init(scene:FloatingScene, currentLevel:String) {
        self.scene = scene
        self.currentLevel = currentLevel
    }
    
    // 初始化所有元件的运行时状态（包括isActive和nodePostition）
    func _initComponentsRunTimeState() {
        
        for component in componentList {
            component.initRunTimeState()
        }
        
    }
    
    func _initComponentsTick0State() {
        for component in componentList {
            component.initTick0State()
        }
    }

    // 将所有状态初始化至 0tick
    func initToTick0() {
        // 初始化时间刻
        self.t = 0
        // 初始化所有元件的运行时状态
        self._initComponentsRunTimeState()
        self._initComponentsTick0State()
        
    }
    
    // 从当前存储的时间刻度 t 开始运行 1tick
    // returns: Int
    //      0,1:  本tick推导完毕
    //        1:  推导到最后一个tick
    //       -1:  输出不匹配
    //       -2:  当前tick存在循环引用
    //       -3:  输出没有全都连接到电源
    
    func startTicket() -> Int {
        
        
        // -----初始化所有元件的运行时状态
        self._initComponentsRunTimeState()
        
        
        // ------初始化信号传播路径树的根节点
        self.signalPathNodes = []
        
        // ------如果tick到达最大深度，设置t=-1，并返回
        if self.currentLevel == "level0" {
            self.t = 999
        }
            
        if self.t == LEVELS_INPUT_OUTPUT_MAPPING[self.currentLevel]!.count {
            self.t = -1
            self._initComponentsTick0State()
            return 1
        }
        
        if self.t == -1 {
            return 0
        }
        //      本关卡在t时刻的电源激活状态的指令以及期望的输出
        let level_input_output_mapping_list: (inputs: [Bool], outputs: [Bool]) = LEVELS_INPUT_OUTPUT_MAPPING[self.currentLevel]![self.t]
        
        // ------关卡输出设置期望的信号
        for (powerOutletIndex, powerOutlet) in self.getPowerOutletList().enumerated() {
            // 拿到当前遍历到的关卡输出的期望输入
            let powerOutletActivation = level_input_output_mapping_list.outputs[powerOutletIndex]
            if self.currentLevel == "level0" {
                powerOutlet.exceptedSignal = true
                continue
            }
            powerOutlet.exceptedSignal = powerOutletActivation
        }
        
        // ------信号传播的入口，激活电源, 同时构建信号传播路径树
        for (powerSourceIndex, powerSource) in self.getPowerSourceList().enumerated() {
            // 拿到当前遍历到的电源的激活指令
            var powerSourceActivation = level_input_output_mapping_list.inputs[powerSourceIndex]
            if self.currentLevel == "level0" {
                powerSourceActivation = true
            }
            // 为每一个电源创建 SignalPathNode
            let spNode = SignalPathNode(ownerComponent: powerSource)
            spNode.isActived = powerSourceActivation
            spNode.isRepeatActived = false
            self.signalPathNodes.append(spNode)
            powerSource.signalNodePositions.append(SignalPathNodePosition(powerSourceIndex: powerSourceIndex))
            
            // 激活电源
            powerSource.onStart(isActivate: powerSourceActivation)
        }
        
        for (delayerIndex, delayer) in self.getDelayerList().enumerated() {
            // 拿到当前遍历到的电源的激活指令
            let delayerActivation = delayer.lastTickStorage
            // 为每一个delayer创建 SignalPathNode
            let spNode = SignalPathNode(ownerComponent: delayer)
            spNode.isActived = delayerActivation
            spNode.isRepeatActived = false
            self.signalPathNodes.append(spNode)
            delayer.signalNodePositions.append(SignalPathNodePosition(powerSourceIndex: delayerIndex + self.getPowerSourceList().count))
            
            // 激活电源
            delayer.onStart(isActivate: delayerActivation)
        }
        
        // -----对所有的 Delayer 进行当前tick的存储状态结算
        for delayer in self.getDelayerList() {
            delayer.lastTickStorage = delayer.nowTickStorage
            delayer.nowTickStorage = false
        }
        
        // -----完成所有信号的传播后，进行输出元件的结算
        var tickPassed = true
        var hasRepeated = false
        for (powerOutletIndex, powerOutlet) in self.getPowerOutletList().enumerated() {
            // 拿到当前遍历到的关卡输出的期望输入
            let powerOutletActivation = level_input_output_mapping_list.outputs[powerOutletIndex]

            // 假如找到不符合的，那么让当前 tick 失败
            if self.currentLevel == "level0" {
                break
            }
            if !(powerOutletActivation == powerOutlet.isActive) {
                tickPassed = false
            }
        }
        
        // -----确认输出元件是否全部连接到电源
        let powerOutletSet = Set(self.getPowerOutletList())
        let connectedPowerOutletSet = 
            Set(
                self.signalPathNodes.map {
                    rootNode in
                    rootNode.filter {
                        node in
                        if node.ownerComponent is PowerOutlet {
                            return true
                        }
                        return false
                    }
                    .map {
                        node in
                        let powerOutlet = node.ownerComponent as! PowerOutlet
                        return powerOutlet
                    }
                }
                .lazy.flatMap { $0 }
            )
        let isAllConnected = powerOutletSet == connectedPowerOutletSet
        tickPassed = isAllConnected && tickPassed
        
        
        // -----寻找是否存在循环引用的元件
        let repeatedActivedList:[Bool] = self.signalPathNodes.map {
            rootNode in
            rootNode.map {
                node in
                return node.isRepeatActived
            }
        }
        .lazy.flatMap { $0 }
        
        let containsTrue = repeatedActivedList.contains(true)
        if containsTrue {
            tickPassed = false
            hasRepeated = true
        }
        
        print("\nProjectCore:\n\tt:\t\(self.t)\n\t方法:\tstartTicket\n\t信号传播路径树:\n\t\t\(self.signalPathNodes.enumerated().map{"\($0): \($1.ownerComponent!.posDescription)\n\t\t\t\($1.description.replacingOccurrences(of: "\n", with: "\n\t\t\t"))"}.joined(separator: "\n\t\t"))")
        
        // 最终审判，决定是否通过当前的tick以及状态码
        if tickPassed {
            self.t += 1
            return 0
        } else {
            self.t = -1
            if hasRepeated {
                self._initComponentsTick0State()
                return -2
            }
            if !isAllConnected {
                self._initComponentsTick0State()
                return -3
            }
            self._initComponentsTick0State()
            return -1
        }
        

    }
    
    // 显示某一层次的电路动画
    // returns: Int
    //      0: 正常
    //     -1: 关卡输出不符合预期
    //     -2: 重复激活
    func showStatute(depthForSignalPathNode: Int) -> Int {
        let speedFactor = self.scene.speedFactor[0]/0.2
        
        
        let signalPathNodesOnDepth = self.signalPathNodes.map{$0.getNodesWithDepth(depth: depthForSignalPathNode)}.flatMap{$0}
        
        var statue = 0
        // 播放当前层的动画
        for spNode in signalPathNodesOnDepth {
            let component = spNode.ownerComponent!
            
            // 被激活时的动画
            if component.isActive {
                component.skNode.run(component.getActivedAction(speedFactor: speedFactor))
            } else {
                // 不被激活时的动画
                component.skNode.run(component.getDeactivedAction(speedFactor: speedFactor))
            }
            
            // 重复输入类型的报错动画
            if spNode.isRepeatActived == true {
                component.skNode.run(component.getErrorAction(speedFactor: speedFactor))
                self.scene.popupWindowMsg.showWindow(message: "error: Multiple activations of the component in the same time slice, consider breaking the cyclic dependency.", msgType: "error")
                statue = -2
            }
            
            // 关卡输出错误的报错动画
            if let outletComponent = component as? PowerOutlet {
                if outletComponent.isActive != outletComponent.exceptedSignal {
                    outletComponent.skNode.run(component.getErrorAction(speedFactor: speedFactor))
                    self.scene.popupWindowMsg.showWindow(message: "error: The power layout component received unexpected input.", msgType: "error")
                    statue = -1
                }
            }
        }
        return statue
    }
    
    // 调整元件node至带播放状态
    func initShowStatute() {
        
        for component in self.componentList {
            let node = component.skNode!
            node.removeAllActions()
            
            let textureName = component.imageName!
            let texture = [SKTexture(imageNamed: textureName)]
            let textureAction = SKAction.animate(with: texture, timePerFrame: 0)
            
            let scaleAction = component._getScaleAction(to: 1, duration: 0.3)
            
            node.run(SKAction.group([scaleAction, textureAction]))
        }
    }
    
    
    
    
    
    func placeComponent(x: Int, y: Int, rotate: Int, isMirror: Bool, componentClass: Component.Type?, isFixed:Bool = false, onAnimating: @escaping (Bool) -> Void = {_ in}) {
        let returns = self._placeComponent(x: x, y: y, rotate: rotate, isMirror: isMirror, componentClass: componentClass, scene:scene, isFixed:isFixed, onAnimating: onAnimating)
        print("\nProjectCore:\n\t方法:\tplaceComponent\n\t状态:\t\(returns)\n\t\t网格位置:\t(\(x), \(y))\n\t\t元件类型:\t\(componentClass)\n\t\t角度:\t\(rotate)\n\t\t翻转:\t\(isMirror)\n\t已放置元件列表:\n\t\(componentList.map{"\($0)"}.joined(separator: "\n\t"))")
    }
    
    func _placeComponent(x: Int, y: Int, rotate: Int, isMirror: Bool, componentClass: Component.Type?, scene:FloatingScene, isFixed:Bool = false, onAnimating: @escaping (Bool) -> Void = {_ in}) -> Bool {
        
        guard let componentClass = componentClass else {return false}
        if let _ = getComponent(x: x, y: y) {return false}
        
        let component = Component.makeComponent(componentType: componentClass, x: x, y: y, rotate: rotate, isMirror: isMirror, neighborComponentList: getNeighborComponents(x: x, y: y), projectCore: self,  scene:scene, isFixed:isFixed, onAnimating:onAnimating)
        
        componentList.append(component)
        
        
        return true
    }


    func removeComponent(x: Int, y: Int) {
        var removingComponent: Component?
        
        for component in componentList {
            if component.x == x && component.y == y {
                removingComponent = component
                break
            }
        }
        
        if let removingComponent = removingComponent {
            // 当发现需要倍删除的元件时，首先解除和邻居与scene的联系
            removingComponent.delete()
            
            // 最后从 projectCore 中移除
            if let index = componentList.firstIndex(of: removingComponent) {
                componentList.remove(at: index)
                
                
            }
            // 删除寄存
            self.selectedComponent = nil
            
            
            
        }
        


    }
    
    func getComponentsByType<T: Component>() -> [T] {
        var result: [T] = []
        for component in componentList {
            if let specificComponent = component as? T {
                result.append(specificComponent)
            }
        }
        return result
    }
    
    func getPowerOutletList() -> [PowerOutlet] {
//        var result: [PowerOutlet] = []
//        for component in componentList {
//            if let powerOutlet = component as? PowerOutlet {
//                result.append(powerOutlet)
//            }
//        }
//        return result
        return self.getComponentsByType()
    }
    
    func getPowerSourceList() -> [PowerSource] {
//        var result: [PowerSource] = []
//        for component in componentList {
//            if let powerSource = component as? PowerSource {
//                result.append(powerSource)
//            }
//        }
//        return result
        return self.getComponentsByType()
    }
    
    func getDelayerList() -> [Delayer] {
        return self.getComponentsByType()
    }
    

    
    func getComponent(x: Int, y: Int) -> Component? {
        let res =  componentList.first { $0.x == x && $0.y == y }
        return res
    }
    
    func getNeighborComponents(x: Int, y: Int) -> [Component] {
        var neighborhoodList: [Component] = []
        
        for component in componentList {
            let x1 = component.x
            let y1 = component.y
            let x2 = x
            let y2 = y
            let distance = sqrt(pow(Float(x1 - x2), 2) + pow(Float(y1 - y2), 2))
            let isNeighbor = distance > 0.99 && distance < 1.01
            
            if isNeighbor {
                neighborhoodList.append(component)
            }
        }
        
        return neighborhoodList
    }
    
    // 通过坐标选中一个元件并播放动画
    func selectComponent(x: Int, y: Int) {
        self.selectedComponent = self.getComponent(x: x, y: y)
    }
    
    func deleteAllComponent() {
        for component in self.componentList {
            component.delete()
        }
        self.componentList = []
    }
    
    // 判断所有元件的动画是否全部播放完毕
    func animationAllEnd() -> Bool {
        var allEnd = true
        
        for component in self.componentList {
            if component.skNode.hasActions() {
                allEnd = false
            }
        }
        return allEnd
    }
    
}

