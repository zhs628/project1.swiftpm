//
//  File.swift
//  
//
//  Created by rzq on 2024/2/13.
//

import Foundation
import SwiftUI
import SpriteKit


class ComponentOutputPart: Hashable {
    // 输出接口ComponentOutputPart是组件Component的组成部分，
    // 其实例的创建、存在、和销毁完全由组件的控制和上下文决定
    var ownerComponent: Component?
    var nextInput: ComponentInputPart?
    
    static func == (lhs: ComponentOutputPart, rhs: ComponentOutputPart) -> Bool {
        // 提供两个 ComponentOutputPart 实例相等的逻辑。我们直接比较地址
        return lhs === rhs
    }
    
    // 实现哈希值方法
    func hash(into hasher: inout Hasher) {
        let point = Unmanaged<AnyObject>.passUnretained(self as AnyObject).toOpaque()
        hasher.combine(point)
    }
    
    required init(ownerComponent: Component? = nil) {
        self.ownerComponent = ownerComponent
    }
    
    func onOutput(isActiveSignal: Bool) {
        nextInput?.onInput(isActiveSignal: isActiveSignal)
    }
}

class ComponentInputPart: Hashable {
    // 输入接口ComponentInputPart是组件Component的组成部分，
    // 其实例的创建、存在、和销毁完全由组件的控制和上下文决定
    var ownerComponent: Component?
    var lastOutput: ComponentOutputPart?
    var calledCount: Int = 0
    var isActive: Bool = false
    let maxCallCount: Int = 10
    
    static func == (lhs: ComponentInputPart, rhs: ComponentInputPart) -> Bool {
        // 提供两个 ComponentInputPart 实例相等的逻辑。我们直接比较地址
        return lhs === rhs
    }
    
    // 实现哈希值方法
    func hash(into hasher: inout Hasher) {
        let point = Unmanaged<AnyObject>.passUnretained(self as AnyObject).toOpaque()
        hasher.combine(point)
    }
    
    required init(ownerComponent: Component? = nil) {
        self.ownerComponent = ownerComponent
    }
    
    func onInput(isActiveSignal: Bool) {
        if calledCount >= maxCallCount {
            ownerComponent?.onRepeatInput(isActiveSignal: isActiveSignal, notifyingInput: self)
        } else {
            calledCount += 1
            self.isActive = isActiveSignal
            ownerComponent?.onInput(isActiveSignal: isActiveSignal, notifyingInput: self)
        }
    }
}

class SignalPathNode: CustomStringConvertible {
    var description: String {
        get {

            let a = self.nextSignalPathNodes.enumerated().filter{$0.element != nil}
            var b: [String] = []
            
            for (i, s) in a {
                var outletDesc = ""
                if let outletComponent = s!.ownerComponent! as? PowerOutlet {
                    outletDesc = outletComponent.isActive == outletComponent.exceptedSignal ? "✅":"❌"
                }
                b.append("\(".\(Sides(rawValue: i)!):".padding(toLength: 8, withPad: " ", startingAt: 0)) \("\(s!.ownerComponent!.posDescription) \(self.isActived ? "🟡" : "⚪️") \(self.isRepeatActived ? "🔄" : "") \(outletDesc)\n\t\(s!.description.replacingOccurrences(of: "\n", with: "\n\t"))")")
            }

            let res = "\(b.joined(separator: "\n"))"

            return res


        }
    }
    
    var ownerComponent: Component?
    
    // 它们必须在后续被赋值， 假如没有赋值将引起报错
    var isActived: Bool! = nil
    var isRepeatActived: Bool! = nil

    var nextSignalPathNodes: [SignalPathNode?]
    var maxDepth: Int {
        get {
            
            var queue: [(node: SignalPathNode, depth: Int)] = [(self, 0)]
            var _maxDepth: Int = 0
            // 利用队列作为存储当前计算状态的媒介
            while !queue.isEmpty {
                let (node, currentDepth) = queue.removeFirst()
                
                if currentDepth > _maxDepth {
                    _maxDepth = currentDepth
                }
                
                for child in node.nextSignalPathNodes {
                    if let childNode = child {
                        queue.append((childNode, currentDepth + 1))
                    }
                }
            }
            return _maxDepth
        }
    } // 最大深度属性，每当调用修改方法时重新计算
    
    init(ownerComponent: Component?){
        self.ownerComponent = ownerComponent
        self.nextSignalPathNodes = [nil,nil,nil,nil]
    }
    
    func setComponent(connectedComponent: Component, side:Sides) {
        self.nextSignalPathNodes[side.rawValue] = SignalPathNode(ownerComponent: connectedComponent)
    }
    
    func getNextNode(side: Sides) -> SignalPathNode? {
        return self.nextSignalPathNodes[side.rawValue]
    }
    
    func getNode(nodePos: SignalPathNodePosition) -> SignalPathNode? {
        var nowNode: SignalPathNode? = self
        for side in nodePos.positionsSequence {
            nowNode = nowNode?.getNextNode(side: side)
        }
        return nowNode
    }
    
    func getNodesWithDepth(depth: Int) -> [SignalPathNode] {
        var nodes: [SignalPathNode] = []
        var queue: [(node: SignalPathNode, depth: Int)] = [(self, 0)]
        
        // 利用基于队列的深度优先遍历实现层次遍历--当遍历深度达到 depth 时，将该节点加入 nodes ,当遍历完成后返回 nodes
        while !queue.isEmpty {
            let (node, currentDepth) = queue.removeFirst()
            
            if currentDepth == depth {
                nodes.append(node)
            }
            
            if currentDepth < depth {
                let nextDepth = currentDepth + 1
                
                for child in node.nextSignalPathNodes {
                    if let childNode = child {
                        queue.append((childNode, nextDepth))
                    }
                }
            }
        }
        
        return nodes
    }
    
    // map 方法，应用一个转换闭包到整个信号路径中的每个节点
    func map<T>(_ transform: (SignalPathNode) -> T) -> [T] {
        var result: [T] = []
        // getNodesWithDepth(depth:) 遍历了整个信号路径的节点，最大深度是 maxDepth
        for depth in 0...maxDepth {
            let nodesAtCurrentDepth = getNodesWithDepth(depth: depth)
            // 对当前深度的每个节点应用转换闭包
            result.append(contentsOf: nodesAtCurrentDepth.map(transform))
        }
        return result
    }
    
    // filter 方法
    func filter(_ filterBy: (SignalPathNode) -> Bool) -> [SignalPathNode] {
        var result: [SignalPathNode] = []
        // getNodesWithDepth(depth:) 遍历了整个信号路径的节点，最大深度是 maxDepth
        for depth in 0...maxDepth {
            let nodesAtCurrentDepth = getNodesWithDepth(depth: depth)
            for node in nodesAtCurrentDepth {
                if filterBy(node) {
                    result.append(node)
                }
            }

        }
        return result
    }
    

}

class SignalPathNodePosition {
    var positionsSequence:[Sides] = []
    var powerSourceIndex: Int
    
    init(powerSourceIndex: Int) {
        self.powerSourceIndex = powerSourceIndex
    }
    
    func getPos(depth: Int) -> Sides {
        return self.positionsSequence[depth]
    }
    
    func getDepth() -> Int {
        return self.positionsSequence.count
    }
    
    func copy() -> SignalPathNodePosition {
        let newPos = SignalPathNodePosition(powerSourceIndex: self.powerSourceIndex)
        newPos.positionsSequence = self.positionsSequence
        return newPos
    }
    
    func toLast() -> SignalPathNodePosition {
        if !self.positionsSequence.isEmpty {
            self.positionsSequence.removeLast()
        }
        return self
    }
    
    func toDirection(side:Sides) -> SignalPathNodePosition {
        self.positionsSequence.append(side)
        return self
    }
    
    func newLast() -> SignalPathNodePosition {
        let newPos = self.copy()
        return newPos.toLast()
    }
    
    func newDirection(side:Sides) -> SignalPathNodePosition {
        let newPos = self.copy()
        return newPos.toDirection(side:side)
    }
}




enum Sides: Int {
    case up = 0, right = 1, down = 2, left = 3
}



class Component: Equatable, Hashable, CustomStringConvertible {
    // 所有组件的基类，实现了大部分的组件行为
    // 向外部提供的方法：
    //      init
    //      onInput
    //      onRepeatInput
    //      getOutputPart
    //      getInputPart
    //      getInputPartsActivation
    //      getOutputPartsActivation
    //      disconnect
    // 向子类提供的抽象方法：
    //      defineParts
    //      getOutputPartsActivation
    //
    //
    //
    // 关于电路推导的过程：
    //      首先projectCore从所有的元件中找出PowerSource(继承自基类Component)，在 ProjectCore.startTicket 遍历所有的电源，并调用它们的 PowerSource.onStart 作用是遍历自己的四条边上的 ComponentOutputPart 调用其 ComponentOutputPart.onOutput 并设定这些输出端口全部是激活状态来调用和本输出端口对象绑定的来自附近其他元件的 ComponentInputPart 的方法 ComponentInputPart.onInput 这将触发和该输出端口绑定的所属元件 Component 的方法 Component.onInput 那么该元件将根据当前绑定的所有 ComponentInputPart 的激活状态决定即将调用的 ComponentOutputPart.onOutput 将会是激活还是未激活, 然后遍历本元件的所有 ComponentOutputPart 并调用其 ComponentOutputPart.onOutput 这将导致其附近的其他元件的输入端口的 ComponentInputPart.onInput 被调用。。。  当这一递归彻底完成后，再遍历关卡的所有输出元件所存储的 ComponentInputPart 的激活状态，依此判定该tick是否满足关卡通过的条件
    
    // 这一整个调用的过程是一个递归，它将在一瞬间完成整个电路的推导，递归的终止条件（或者说剪枝条件是：
    //      1.当前的元件没有任何输出端口。（这是正常情况下的剪枝，可能是一个关卡的输出元件）
    //      2.当前元件的输出端口没有绑定其他元件的输入端口  （这是正常情况下的剪枝）
    //      3.当前输入端口在当前tick内被激活的总数超过100次。（此时说明电路发生了一个循环引用，那么对后面的部分强行剪枝）
    //      4.PowerSource.startTicket遍历完电路中所有的电源PowerSource  （入口栈帧的退出条件）
    //
    // 以下是函数调用示意图：
    // PowerSource.startTicket --> PowerSource.onStart（递归入口） -（通知拥有的输出端口）-> ComponentOutputPart.onOutput -（通知自己的订阅者输入端口）-> ComponentInputPart.onInput -（通知自己的属主元件）-> Component.onInput --> ComponentOutputPart.onOutput --> ComponentInputPart.onInput --> Component.onInput .....
    //
    // 我打算使用四叉树来存储电路信号的传播过程：
    //  [           调用电源(1,0)
    //      [           调用导线(1,0)
    //          [           调用导线(2,0)
    //              nil,
    //              nil,
    //              nil,
    //              nil
    //          ]
    //          nil，
    //          nil，
    //          nil
    //      ],
    //      nil,
    //      nil,
    //      [           调用导线(1,1)
    //          [           调用导线(1,2)
    //              nil,
    //              nil,
    //              nil,
    //              nil
    //          ]
    //          nil，
    //          nil，
    //          nil
    //      ],
    //  ]
    //
    //
    //
    // 并使用一个数组来表示某个节点的位置：
    // [right, right, up]
    
    // 动画放映时的回调函数
    var onAnimating: (Bool) -> Void = {isActive in }
    // 是否不可移动
    var isFixed: Bool
    
    var projectCore: ProjectCore!
    var signalNodePositions: [SignalPathNodePosition] = []
    var x: Int
    var y: Int
    var rotate: Int = 0
    var isMirror: Bool = false
    var inputPartList: [ComponentInputPart?] = [ComponentInputPart?](repeating: nil, count: 4)
    var outputPartList: [ComponentOutputPart?] = [ComponentOutputPart?](repeating: nil, count: 4)
    var isActive: Bool = false
    var scene: FloatingScene!
    var _imageName: String! = nil
    var _activedImageName: String! = nil
    var _selectedImageName: String! = nil
    var imageName: String! {
        get {
            return self._imageName
        }
        set(val) {
            self._imageName = val
        }
    }
    var activedImageName: String! {
        get {
            return self._activedImageName
        }
        set(val) {
            self._activedImageName = val
        }
    }
    var selectedImageName: String! {
        get {
            return self._selectedImageName
        }
        set(val) {
            self._selectedImageName = val
        }
    }
    var presentation1ImageName: String! = nil
    var presentation2ImageName: String! = nil
    
    var descForTopPic: String = ""
    var descForPresentation1: String = ""
    var descForPresentation2: String = ""
    
    
    var maskNode: SKSpriteNode! = nil
    var skNode: SKSpriteNode! = nil
    var _nodeSelected: Bool = false // 表示在编辑模式中，本元件的node是否被选中
    var nodeHasSelected: Bool {  // 当该值发生改变时，播放动画
        get {
            return self._nodeSelected
        }
        set (val) {
            
            if val == self._nodeSelected {
                return
            }
            
            if (val == true) {
                // 使得蒙版显现，制造出场景变暗的效果, 现在蒙版在最上层
                self.showMask()
                // 使得本元件 node 置于蒙版之上
                self.scene.bringNodeToTop(self.skNode)
                
                // 使创建元件放大的动画
                let scaleAction = self._getScaleAction(to: 1.5, duration: 0.3)

                // 创建纹理变换的动画
                let textureNames = [ self.selectedImageName]
                let textures = textureNames.map { SKTexture(imageNamed: $0!) }
                let textureAction = SKAction.animate(with: textures, timePerFrame: 0.3 )
                let textureActionSequence = SKAction.sequence([textureAction])
                let actionGroup = SKAction.group([textureActionSequence, scaleAction])
                
                self.skNode.run(actionGroup)
                
            } else {
                // 让蒙版隐藏
                self.initMask()
                // 使创建元件缩小的动画
                let scaleAction = self._getScaleAction(to: 1.0, duration: 0.3)

                // 创建纹理变换的动画
                let textureNames = [self.imageName]
                let textures = textureNames.map { SKTexture(imageNamed: $0!) }
                let textureAction = SKAction.animate(with: textures, timePerFrame: 0.3 )
                let textureActionSequence = SKAction.sequence([textureAction])
                let actionGroup = SKAction.group([textureActionSequence, scaleAction])
                
                self.skNode.run(actionGroup)
            }
            
            self._nodeSelected = val
        }
        
    }
    var description: String {
        get {
            let outerConnects = self.outputPartList
                .map {$0?.nextInput?.ownerComponent}
                .filter {$0 != nil}
                .map {$0!}
                .map {"\t\t\t\($0.getClassName().padding(toLength: 15, withPad: " ", startingAt: 0)):\t位置:\t(\($0.x), \($0.y))"}
            
            return "\t\(self.getClassName().padding(toLength: 15, withPad: " ", startingAt: 0)):\t位置: (\(x), \(y))\t激活: \(isActive)\t角度: \(rotate)\t镜像: \(isMirror)\t\n\t\t输出到: \n" + "\(outerConnects.joined(separator: "\n"))"
        }
    }
    var posDescription: String {
        get {

            return "\(self.getClassName()) (\(x), \(y))"
        }
    }
    static func makeComponent(componentType: Component.Type,x: Int, y: Int, rotate: Int, isMirror: Bool, neighborComponentList: [Component], projectCore:ProjectCore, scene:FloatingScene, isFixed:Bool=false, onAnimating: @escaping (Bool) -> Void = {_ in}) -> Component {
        
        let component = componentType.init(x: x, y: y, neighborComponentList: neighborComponentList, projectCore: projectCore, scene: scene, isFixed:isFixed, onAnimating:onAnimating)
        component.initNode()
        for _ in 0..<(rotate/90) {
            component.spin90()
        }
        if component.isMirror {
            component.mirrorX()
        }
        return component
        
    }
    
    static func == (lhs: Component, rhs: Component) -> Bool {
        // 提供两个 Component 实例相等的逻辑。我们直接比较地址
        return lhs === rhs
    }
    
    // 实现哈希值方法
    func hash(into hasher: inout Hasher) {
        let point = Unmanaged<AnyObject>.passUnretained(self as AnyObject).toOpaque()
        hasher.combine(point)
    }

    // 能够获取类型名字
    func getClassName() -> String {
        return String(describing: type(of: self)).components(separatedBy: ".").last ?? ""
    }

    required init(x: Int, y: Int, neighborComponentList: [Component], projectCore:ProjectCore?, scene:FloatingScene?, isFixed:Bool=false, onAnimating: @escaping (Bool) -> Void = {_ in}) {
        self.x = x
        self.y = y
        self.isFixed = isFixed
        self.onAnimating = onAnimating
        
        self.projectCore = nil
        if let _projectCore = projectCore {
            self.projectCore = _projectCore
        }
        
        self.scene = nil
        if let _scene = scene {
            self.scene = _scene
        }
        
        initInternal()
        
        if projectCore != nil {
            initExternal(neighborComponentList: neighborComponentList)
        }
        
    }
    
    // 初始化本元件的运行时状态至刚刚摆放
    func initRunTimeState() {
        self.signalNodePositions = []
        self.isActive = false
        for inputPart in self.inputPartList {
            if let inputPart = inputPart {
                inputPart.isActive = false
                inputPart.calledCount = 0
            }
        }
    }
    
    func initTick0State() {
        return
    }
    
    // 初始化自己的 SKNode 不过它并不在初始化块内完成
    func initNode() {
        // 首先确保node不会重复生成
        if let sknode = self.skNode {
            sknode.removeFromParent()
        }
        

        
        let scaleInit = SKAction.scale(to: 0, duration: 0)
        let scaleUpAction = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDownAction = SKAction.scale(to: 1, duration: 0.05)
        let alphaInit = SKAction.fadeAlpha(to: 0, duration: 0)
        
        let alphaUpAction = SKAction.fadeAlpha(to: self.isFixed ? 0.8 : 1, duration: 0.15)
        
        let alphaActionSequence = SKAction.sequence([alphaInit, alphaUpAction])
        let scaleActionSequence = SKAction.sequence([scaleInit, scaleUpAction, scaleDownAction])
        
        let actionGroup = SKAction.group([alphaActionSequence, scaleActionSequence])
        
        let imageNode = SKSpriteNode(imageNamed: self.imageName)
        let blockLength = self.scene.gridFrame.sideLength
        let floatPos = self.scene.gridFrame.getFloatPos(x: self.x, y: self.y)
        let squareFrame = self.scene.gridFrame.selectSquare(x: floatPos.x, y: floatPos.y)
        
        let posX = squareFrame!.minX+blockLength/2
        let posY = squareFrame!.minY+blockLength/2
        
        imageNode.size = CGSize(width: blockLength, height: blockLength)
        imageNode.position = CGPoint(x: posX, y: posY)
        
        
        self.scene.addChild(imageNode)
        self.skNode = imageNode

        self.skNode.run(actionGroup)
        
    }
    
    private func initMask() {
        // 首先移除原来的 mask
        self.removeMask()
        // 再加入新的mask
        self.maskNode = SKSpriteNode(color: .black, size: self.scene.size)
        self.maskNode.alpha = 0
        self.scene.addChild(self.maskNode)
    }
    
    private func removeMask(){
        if let maskNode = self.maskNode {
            maskNode.removeFromParent()
        }
    }
    
    private func showMask() {
        // 首先重设 mask，确保它在其他所有 node 的上面
        initMask()
        // 再让 mask 透明度逐渐降低
        //      缓动改变蒙版透明度动作
        let fadeAction = SKAction.fadeAlpha(to: 0.5, duration: 0.2)
        fadeAction.timingMode = .easeInEaseOut
        self.maskNode.run(fadeAction)
    }
    
    func defineParts() {
        // 子类将重写该方法完成自己的初始化
        //    子类应当在此处设置输入输出接口列表
    }
    
    private func initInternal() {
        // 完成对所有内部状态的初始化
        defineParts()
    }
    
    private func pairingNeighborPart(_ neighborComponentList: [Component], _ onPairing: (ComponentInputPart, ComponentOutputPart) -> Void) {
        // 在被放置时调用，完成周围组件和本组件的输入输出接口配对
        for opposite in neighborComponentList {
            var selfSide: Sides?
            var oppositeSide: Sides?
            
            // 根据自己和对方的相对位置确定可能连接的一对输入输出位置
            if self.y == opposite.y && self.x > opposite.x {
                //
                // self -- oppos
                //
                selfSide = .left
                oppositeSide = .right
            }
            if self.y == opposite.y && self.x < opposite.x {
                //
                // opposite -- self
                //
                selfSide = .right
                oppositeSide = .left
            }
            if self.x == opposite.x && self.y > opposite.y {
                //  self
                //   ｜
                //  opposite
                selfSide = .down
                oppositeSide = .up
                    
            }
            if self.x == opposite.x && self.y < opposite.y {
                //  opposite
                //   ｜
                //  self
                selfSide = .up
                oppositeSide = .down
            }
            
            // 当寻找的位置都存在有接口实例，那么开始连接
            if let selfSideUnwrapped = selfSide, let oppositeSideUnwrapped = oppositeSide {
                let selfInputPart = self.getInputPart(side: selfSideUnwrapped)
                let selfOutputPart = self.getOutputPart(side: selfSideUnwrapped)
                let oppositeInputPart = opposite.getInputPart(side: oppositeSideUnwrapped)
                let oppositeOutputPart = opposite.getOutputPart(side: oppositeSideUnwrapped)

                
                // selfInput <--> oppositeOutput
                if let selfInputPart = selfInputPart, let oppositeOutputPart = oppositeOutputPart {
                    onPairing(selfInputPart, oppositeOutputPart)
                }
                
                // selfOutput <--> oppositeInput
                if let selfOutputPart = selfOutputPart, let oppositeInputPart = oppositeInputPart {
                    onPairing(oppositeInputPart, selfOutputPart)
                }
                
                
                
            }
        }
    }
    
    private func initExternal(neighborComponentList: [Component]) {
        // 完成对外界的一系列绑定和初始化工作
        pairingNeighborPart(neighborComponentList) { inputPart, outputPart in
            outputPart.nextInput = inputPart
            inputPart.lastOutput = outputPart
        }
    }
    
    private func notifyOutput(outputPart: ComponentOutputPart, isActiveSignal: Bool) {
        // 向绑定的输出接口发送信号
        outputPart.onOutput(isActiveSignal: isActiveSignal)
    }
    
    func onInput(isActiveSignal: Bool, notifyingInput: ComponentInputPart) {
        // 被外部调用，用于告知本模块收到了信号
        let inputPartsActivation = getInputPartsActivation()
        
        if isActiveSignal {
            print("\(getClassName().padding(toLength: 20, withPad: " ", startingAt: 0)) (\(x), \(y)) 镜像\(isMirror) 旋转\(rotate) 激活 \(inputPartsActivation)")
        } else {
            print("\(getClassName().padding(toLength: 20, withPad: " ", startingAt: 0)) (\(x), \(y)) 中断 \(inputPartsActivation)")
        }
        
        guard let (outputPartsActivation, isActive) = getOutputPartsActivation(inputPartsActivation: inputPartsActivation) else {
            return
        }

        self.isActive = isActive
        let lastOutput = notifyingInput.lastOutput!
        let lastComponent = lastOutput.ownerComponent!
        let lastNodePos = lastComponent.signalNodePositions[lastComponent.signalNodePositions.count-1]
        let lastOutputSide = lastComponent.getOutputPartSide(outputPart: lastOutput)!
        let nowNodePos = lastNodePos.newDirection(side: lastOutputSide)
        
        self.signalNodePositions.append(nowNodePos)
        
        let lastNode = self.projectCore.signalPathNodes[lastNodePos.powerSourceIndex].getNode(nodePos: lastNodePos)!
        lastNode.setComponent(connectedComponent: self, side: lastOutputSide)
        let nowNode = lastNode.getNextNode(side: lastOutputSide)!
        // 设置另外的其余属性
        nowNode.isActived = self.isActive


        nowNode.isRepeatActived = false
        
        
        for (index, outputPart) in outputPartList.enumerated() where outputPart != nil {
            notifyOutput(outputPart: outputPart!, isActiveSignal: outputPartsActivation[index])
        }
    }
    
    func onRepeatInput(isActiveSignal: Bool, notifyingInput: ComponentInputPart) {
        // 被外部调用，用于告知本组件可能产生了无休止的循环调用链
        let inputPartsActivation = getInputPartsActivation()
        
        print("\(getClassName().padding(toLength: 20, withPad: " ", startingAt: 0)) (\(x), \(y)) 同一输入端口在1t内被激活过多, 信号传递终止 \(inputPartsActivation)")
        let lastOutput = notifyingInput.lastOutput!
        let lastComponent = lastOutput.ownerComponent!
        let lastNodePos = lastComponent.signalNodePositions[lastComponent.signalNodePositions.count-1]
        let lastOutputSide = lastComponent.getOutputPartSide(outputPart: lastOutput)!
        let nowNodePos = lastNodePos.newDirection(side: lastOutputSide)
        self.signalNodePositions.append(nowNodePos)
        let lastNode = self.projectCore.signalPathNodes[lastNodePos.powerSourceIndex].getNode(nodePos: lastNodePos)!
        lastNode.setComponent(connectedComponent: self, side: lastOutputSide)
        let nowNode = lastNode.getNextNode(side: lastOutputSide)!
        // 设置另外的其余属性
        nowNode.isActived = false
        nowNode.isRepeatActived = true
    }
    
    func getInputPartsActivation() -> [Bool] {
        // 获取本组件输入接口的激活状态列表
        let result = self.inputPartList.map { $0?.isActive ?? false }
        return result
    }
    
    func getOutputPartsActivation(inputPartsActivation: [Bool]) -> ([Bool], Bool)? {
        // 该方法将由子类实现，子类将拿到本组件当前的输入接口的激活状态列表，
        //     并实现一个逻辑来给出相应的输出接口的激活列表，以及是否激活本组件的判断
        //     该方法是组件实现自己逻辑的主要区域。
        return ([], false)
    }
    
    func spin90() {
        // 旋转元件
        let neighboors = self.projectCore.getNeighborComponents(x: self.x, y: self.y)
        // 首先匹配旋转前的附近元件的接口，与之解除连接
        self.disconnectComponent(neighborComponentList: neighboors)
        // 然后旋转
        self.rotate += 90
        if (self.rotate == 360) {
            self.rotate = 0
        }
        // 重新连接附近的元件
        self.initExternal(neighborComponentList: neighboors)
        // 然后播放旋转动画
        let rotationAction = SKAction.rotate(byAngle: -.pi/2, duration: 0.3)
        self.skNode.run(rotationAction)
    }
    
    func mirrorX() {
        // 以x轴为旋转轴翻转元件
        let neighboors = self.projectCore.getNeighborComponents(x: self.x, y: self.y)
        // 首先匹配旋转前的附近元件的接口，与之解除连接
        self.disconnectComponent(neighborComponentList: neighboors)
        // 设置角度数值
        self.isMirror.toggle()
        // 重新连接附近的元件
        self.initExternal(neighborComponentList: neighboors)
        // 然后播放动画
        let scaleAction = self._getScaleAction(to: 1.5, duration: 0.3)
        self.skNode.run(scaleAction)
    }
    
    func getOutputPart(side: Sides) -> ComponentOutputPart? {
        // 用于向外部提供本组件某一边上的输出接口
        var list = Array(outputPartList)
        
        if isMirror {
            list.swapAt(1, 3)
        }
        
        let shiftRange = rotate / 90
        let rotatedList = rotateArray(list, by: shiftRange)
        
        return rotatedList[side.rawValue]
    }
    
    func getInputPart(side: Sides) -> ComponentInputPart? {
        // 用于向外部提供本组件某一边上的输入接口
        var list = Array(inputPartList)
        
        if isMirror {
            list.swapAt(1, 3)
        }
        
        let shiftRange = rotate / 90
        let rotatedList = rotateArray(list, by: shiftRange)
        
        return rotatedList[side.rawValue]
    }
    
    func getInputPartSide(inputPart:ComponentInputPart) -> Sides? {
        let index = self.inputPartList.firstIndex(where: { $0 === inputPart })
        if let index = index {
            return Sides(rawValue: index)
        } else {
            return nil
        }
        
    }
    
    func getOutputPartSide(outputPart: ComponentOutputPart) -> Sides? {
        let index = self.outputPartList.firstIndex(where: { $0 === outputPart })
        if let index = index {
            return Sides(rawValue: index)
        } else {
            return nil
        }
    }
    
    func disconnectComponent(neighborComponentList: [Component]) {
        // 在外部删除本组件前，需要先调用本方法来解除周围组件的接口和本组件之间的绑定
        pairingNeighborPart(neighborComponentList) { inputPart, outputPart in
            outputPart.nextInput = nil
            inputPart.lastOutput = nil
        }

    }

    func disconnectNode() {
        // 解除node和scene的引用关系,并播放动画
        // 播放逐渐缩小直到消失的动画
        let scaleAction = SKAction.scale(to: 2, duration: 0.2)
        scaleAction.timingMode = .easeInEaseOut
        let scaleAction2 = SKAction.scale(to: 0.0, duration: 0.2)
        scaleAction2.timingMode = .easeInEaseOut
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.3)
        let removeAction = SKAction.removeFromParent()
        let sequenceAction = SKAction.sequence([scaleAction, scaleAction2, removeAction])
        self.skNode.run(sequenceAction)
        let sequenceAction2 = SKAction.sequence([fadeOutAction, removeAction])
        if self.maskNode != nil {
            self.maskNode.run(sequenceAction2)
        }
       
    }
    
    func delete() {
        // 彻底删除本组件的流程
        self.disconnectComponent(neighborComponentList: self.projectCore.getNeighborComponents(x: self.x, y: self.y))
        self.disconnectNode()
        
    }
    
    // 获取元件尺寸缩放的动画
    func _getScaleAction(to:CGFloat, duration:TimeInterval) -> SKAction {
        let scaleXAction = SKAction.scaleX(to: self.isMirror ? -to : to, duration: duration)
        let scaleYAction = SKAction.scaleY(to: to, duration: duration)
        scaleXAction.timingMode = .easeInEaseOut
        scaleYAction.timingMode = .easeInEaseOut
        let actionGroup = SKAction.group([scaleXAction, scaleYAction])
        return actionGroup
    }
    
    func getDeactivedAction(speedFactor: Double) -> SKAction {
        // 首先将本node置于顶层
        let component = self
        self.scene.bringNodeToTop(component.skNode)
        // 创建大小变换的动画
        let scaleUpAction = component._getScaleAction(to: 1.5, duration: 0.1 * speedFactor)
        let scaleDelayAction = SKAction.wait(forDuration: 0.2 * speedFactor)
        let scaleDownAction = component._getScaleAction(to: 1, duration: 0.05 * speedFactor)
        let scaleActionSequence = SKAction.sequence([scaleUpAction, scaleDelayAction, scaleDownAction])
        // 创建纹理变换的动画
//            let textureNames = [ component.activedImageName, component.imageName]
        let textureNames = [ component.imageName]
        let textures = textureNames.map { SKTexture(imageNamed: $0!) }
        let textureAction = SKAction.animate(with: textures, timePerFrame: 0.3 * speedFactor)
        let textureActionSequence = SKAction.sequence([textureAction])
        let actionGroup = SKAction.group([textureActionSequence, scaleActionSequence])
        
        // 使用回调函数
        self.onAnimating(false)
        
        
        return actionGroup
        
 
    }
    
    // 获取元件被激活时的动画
    func getActivedAction(speedFactor: Double) -> SKAction {
        // 首先将本node置于顶层
        let component = self
        self.scene.bringNodeToTop(component.skNode)
        
        let scaleUpAction = component._getScaleAction(to: 1.5, duration: 0.1 * speedFactor)
        let scaleDelayAction = SKAction.wait(forDuration: 0.2 * speedFactor)
        let scaleDownAction = component._getScaleAction(to: 1, duration: 0.05 * speedFactor)
        let scaleActionSequence = SKAction.sequence([scaleUpAction, scaleDelayAction, scaleDownAction])
        
        // 创建纹理变换的动画
//            let textureNames = [ component.activedImageName, component.imageName]
        let textureNames = [ component.activedImageName]
        let textures = textureNames.map { SKTexture(imageNamed: $0!) }
        let textureAction = SKAction.animate(with: textures, timePerFrame: 0.3 * speedFactor)
        let textureActionSequence = SKAction.sequence([textureAction])
        let actionGroup = SKAction.group([textureActionSequence, scaleActionSequence])
        
        // 使用回调函数
        self.onAnimating(true)
        
        return actionGroup
    }
    
    // 获取元件报错时的动画
    func getErrorAction(speedFactor: Double) -> SKAction {
        // 首先将本node置于顶层
        let component = self
        self.scene.bringNodeToTop(component.skNode)
        
        // 创建大小变换的动画
        let scaleUpAction = component._getScaleAction(to: 1.5, duration: 0.1 * speedFactor)
        let scaleDelayAction = SKAction.wait(forDuration: 0.2 * speedFactor)
        let scaleDownAction = component._getScaleAction(to: 1, duration: 0.1 * speedFactor)
        var scaleActionSequence2Array: [SKAction] = []

        for _ in 1...5 {
            scaleActionSequence2Array += [scaleUpAction, scaleDelayAction, scaleDownAction]
        }
        let scaleActionSequence2 = SKAction.sequence(scaleActionSequence2Array)
        
        // 创建纹理变换的动画
        let textureAction1 = SKAction.animate(with: [SKTexture(imageNamed: component.selectedImageName)], timePerFrame: 3 * speedFactor)
        let textureAction2 = SKAction.animate(with: [SKTexture(imageNamed: component.imageName)], timePerFrame: 0 * speedFactor)
        let textureActionSequence = SKAction.sequence([textureAction1, textureAction2])
        
        let actionGroup = SKAction.group([textureActionSequence, scaleActionSequence2])
            
        return actionGroup
        
    }


}






