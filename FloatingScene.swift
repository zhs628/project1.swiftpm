//
//  File.swift
//  project1
//
//  Created by rzq on 2024/1/29.
//

import Foundation
import SpriteKit



class FloatingScene: SKScene {
    
    static var shared: FloatingScene? = nil
    
    // 背景管理器
    var _backgroundManager: BackgroundManager? = nil
    var backgroundManager: BackgroundManager {
        get {
            if self._backgroundManager == nil {
                self._backgroundManager = BackgroundManager.makeManager(projectCore: self.projectCore, scene: self, managerLevelStr: self.gameStateMachine.currentStatue)
                return self._backgroundManager!
            }
            else if self._backgroundManager!.levelStr != self.gameStateMachine.currentStatue {
                self._backgroundManager!.deleteBackgrounds()
                self._backgroundManager = BackgroundManager.makeManager(projectCore: self.projectCore, scene: self, managerLevelStr: self.gameStateMachine.currentStatue)
                return self._backgroundManager!
            }
            else {
                return self._backgroundManager!
            }
        }
    }
    // 场景的尺寸
    var width: CGFloat! = nil
    var height: CGFloat! = nil
    // 游戏场景view
    var skView: SKView! = nil
    // 过关弹窗
    var levelPassedWindowObject: LevelPassedWindowObject!
    // 进度条
    var progressBarObj: ProgressObject!
    // 提示弹窗
    var popupWindowMsg: PopupWindowMsg!
    // 每一个场景都需要管理一个ProjectCore， 它的生命周期在场景内
    var projectCore: ProjectCore!
    // 属于swiftui这边的环境变量，整个游戏的状态机
    var gameStateMachine: GameStateMachine!
    // 用于对场景区域进行划分和计算的纯逻辑网格
    var gridFrame: GridFrame!
    // 用于承载网格中灰色背景块的node
    var gridNode: SKNode!
    // 属于swiftui这边的环境变量，用于和swiftui进行状态上的共享，方法是在update内不断监测selectId的变化来进行及时的响应
    var selectedId: SelectedId!
    
    // 网格的格子规模
    var gridWidth:Int {
        get {
            LEVELS_GRID_SCALE[self.gameStateMachine.currentStatue]!.width
        }
    }
    var gridHeight:Int {
        get {
            LEVELS_GRID_SCALE[self.gameStateMachine.currentStatue]!.height
        }
    }
    // 背景网格的 显示/隐藏 状态管理
    var hideGrid: Bool {
        get{
            return gridNode.isHidden
        }
        set(val){
            
            
            // 仅当发生变化时才播放动画
            if (val == self.gridNode.isHidden) {
                return
            }
            
            // 切换到显示网格
            if (val == false) {
                self.gridNode.alpha = 0
                gridNode.run(SKAction.fadeIn(withDuration: 0.1))
            }
            self.gridNode.isHidden = val
        }
    }
    // 运行时的动画更新器
    lazy var runningUpdater: RecurringActionUpdater<Int>! = nil
    // 运行时动画播放速度因子(0, inf), 越小越快
    var speedFactor: [Double] = [SPEED_FACTOR]  // 只含有一个元素的数组，用于函数间共享对象

    // 用于寄存上一次运行的信号传播路径树
    var signalPathRecord: [SignalPathNode]! = nil
    
    // 寄存上一次电路推导的结果
    var lastTickStatue: Int = 0
    
    // 用于寄存动画结束后的结算权限
    var hasSettledThisDepth: Bool = false
    
    var hasReachedMaxDepth: Bool = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //获取当前点击的点的坐标
        let touchs = touches as NSSet
        let touch : AnyObject = touchs.anyObject() as AnyObject
        let locationPoint = touch.location(in: self)
        let selectPosition = gridFrame.getIntPos(x: locationPoint.x, y: locationPoint.y)
        let selectedClass = self.selectedId.rightPannelSelectedId
        print("--------------------------")
        print("位置:\t\t\(locationPoint)")
        print("格子:\t\t\(selectPosition)")
        print("模块面板选中的模块:\t\(selectedClass)")
        
        // 编辑模式
        if (self.gameStateMachine.currentLevelStateMachine.currentStatue == "editing"){
            
            // 选中元件
            if let selectPosition = selectPosition {
                self.projectCore.selectComponent(x: selectPosition.x, y: selectPosition.y)
            } else {
                // 当没有点到格子，传入-1
                self.projectCore.selectComponent(x: -1, y: -1)
            }
            
            // 当不处于选中状态时放置元件
            if (self.projectCore.selectedComponent == nil) {
                // 还需要判断有没有点到格子里
                if let selectPosition = selectPosition {
                    self.projectCore.placeComponent(x: selectPosition.x, y: selectPosition.y, rotate: 0, isMirror: false, componentClass: selectedClass)
                }
            }

        }        
    }
    
    // 将一个node置于顶层
    func bringNodeToTop(_ node: SKNode) {
        guard let parentNode = node.parent else {
            return
        }
        
        node.removeFromParent()
        parentNode.addChild(node)
    }
    
    // 自己定义的场景初始化阶段
    func setup(to view: SKView) {
        
        
        self.skView = view
        
        
        // 初始化场景的 projectCore 并使用状态机存储的值确定当前关卡
        self.projectCore = ProjectCore(scene: self, currentLevel: gameStateMachine.currentStatue)
        
        view.showsPhysics = true
        view.showsNodeCount = true
        view.allowsTransparency = true
        self.backgroundColor = UIColor.white

        // 在这里设置场景
        let cameraNode = SKCameraNode()
            
        cameraNode.position = CGPoint(x: 0,y: 0)
            
        addChild(cameraNode)
        self.camera = cameraNode
        

        let backgroundRectSize = CGSize(width: view.frame.width, height: view.frame.height)
        let background = SKSpriteNode(imageNamed: "edit_area_background")
        background.size = backgroundRectSize
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = -1 // 将背景图放置在所有其他节点的下方
        addChild(background)


        
        // 关卡的初始化
        if (Array(1...10).map{"level" + String($0)}+["level0"]).contains(self.gameStateMachine.currentStatue) {
            self.initLevel()
        }
        
        // 背景
        if let imgName = BACKGROUND_PIC_LIST[self.gameStateMachine.currentStatue]! {
            let backgroundNode = SKSpriteNode(imageNamed:imgName)
            // 将背景节点位置设置为场景的中心

            backgroundNode.size.width = self.width
            backgroundNode.size.height = self.height
            
            backgroundNode.position = CGPoint(x: frame.minX, y: frame.minY)
            
            backgroundNode.alpha = 0.5
            
            // 将背景节点添加到场景的底部层级
            backgroundNode.zPosition = -1
            addChild(backgroundNode)
            
        }

        

        
        print("setup completed!")
        
        

    }

    override func didMove(to view: SKView) {
        self.setup(to: view)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // -----控制按钮的状态响应
        if (selectedId.pressingStartButton || selectedId.pressingRerunButton) {
            
            // 设置状态机为 running
            self.gameStateMachine.currentLevelStateMachine.currentStatue = "running"
            
            self.onStartRun()
            
            // 确保每次点击运行按钮，本段代码只被执行一次
            selectedId.pressingStartButton = false
            selectedId.pressingRerunButton = false
        }
        
        if (selectedId.pressingEndButton) {
            self.projectCore.initShowStatute()
            self.gameStateMachine.currentLevelStateMachine.currentStatue = "editing"
            selectedId.pressingEndButton = false
        }
        
//        if (selectedId.pressingRerunButton) {
//            self.projectCore.initShowStatute()
//            self.gameStateMachine.currentLevelStateMachine.currentStatue = "running"
//            selectedId.pressingRerunButton = false
//        }
        
        // -----编辑按钮的状态响应
        if (selectedId.pressingRemoveButton) {
            if (self.gameStateMachine.currentLevelStateMachine.currentStatue == "editing"){
                if let selectedComponent = self.projectCore.selectedComponent {
                    if !selectedComponent.isFixed {
                        self.projectCore.removeComponent(x: selectedComponent.x, y: selectedComponent.y)
                    }
                    

                    
                }
            }
            selectedId.pressingRemoveButton = false
        }
        
        if (selectedId.pressingSpinButton) {
            if (self.gameStateMachine.currentLevelStateMachine.currentStatue == "editing"){
                if let selectedComponent = self.projectCore.selectedComponent {
                    if !selectedComponent.isFixed {
                        selectedComponent.spin90()
                    }
                    
                }
            }
            selectedId.pressingSpinButton = false
        }
        
        if (selectedId.pressingMirrorButton) {
            if (self.gameStateMachine.currentLevelStateMachine.currentStatue == "editing"){
                if let selectedComponent = self.projectCore.selectedComponent {
                    if !selectedComponent.isFixed {
                        selectedComponent.mirrorX()
                    }
                }
            }
            selectedId.pressingMirrorButton = false
        }
        
        // -----电路的运行管理
        if (self.gameStateMachine.currentLevelStateMachine.currentStatue == "running") {
            self.onRunning()
        }


        
//        if (self.gameStateMachine.currentLevelStateMachine.currentStatue == "pausing") {
//            
//        }

        
        // -----判断是否显示网格
        var _hideGrid = true
        //      选中模块需要显示网格
        if (self.gameStateMachine.currentLevelStateMachine.currentStatue == "editing" && self.selectedId.rightPannelSelectedId != nil) {
            _hideGrid = false
        }
        //      同步最终的hidegrid
        self.hideGrid = _hideGrid
    }
    
    // 切换到电路仿真状态的初始化设置
    func onStartRun() {
        // 设置core的状态至tick0
        self.projectCore.initToTick0()
        self.onTickStart()
        // 设置背景
        self.backgroundManager.initToTickStart()
    }
    
    // 仿真时每一个tick都需要做的事情
    func onRunning() {
        // 禁止工作台元件选中
        if (self.projectCore.selectedComponent != nil) {
            self.projectCore.selectedComponent = nil
        }

        // 执行一步动画
        let (hasActived, _) = self.runningUpdater.tryToExecute()
        
        // 给予本深度的结算权限
        if hasActived {
            self.hasSettledThisDepth = false
        }
        
        // 抵达最大播放深度
        self.hasReachedMaxDepth = self.runningUpdater.executionCount >= self.projectCore.maxDepth-1 || self.hasReachedMaxDepth
        // 必须等到动画结束，不曾结算并抵达最大深度时才可以对本tick进行结算
        let isMinorSettlementAllowed = self.projectCore.animationAllEnd() && !self.hasSettledThisDepth && self.hasReachedMaxDepth
        // 当 lastTickStatue==1或-1，仿真结束
        let isMainSettlementAllowed = isMinorSettlementAllowed && self.lastTickStatue != 0
        

        
        // 动画播放层次末位结算
        if self.hasSettledThisDepth {
            self.hasSettledThisDepth = true
        }
        // 仿真末尾结算
        if isMainSettlementAllowed {
            self.gameStateMachine.currentLevelStateMachine.currentStatue = "editing"
            self.progressBarObj.updatePercent(percent: 0)
            if self.lastTickStatue == 1 {
                self.onLevelPassed()
            }
            if self.lastTickStatue == -3 {
                self.popupWindowMsg.showWindow(message: "error: Each output component of the level needs to be connected to the power source.", msgType: "error")
            }
            return
        }
        
        // tick末尾结算
        if isMinorSettlementAllowed {
            self.backgroundManager.tickEnd()
            self.onTickStart()
        }
    }
    
    func onTickStart() {
        // 将元件的node的状态调整至待播放状态
        self.projectCore.initShowStatute()
        // 重置电路的动画播放器
        self.runningUpdater = RecurringActionUpdater(
            executeTimeInterval:self.speedFactor,
            // 播放某一深度的动画
            action: {executedCount in
                self.projectCore.showStatute(depthForSignalPathNode: executedCount)
            }
        )
        // 对下一tick进行仿真
        self.lastTickStatue = self.projectCore.startTicket()
    }
    
    // 关卡的初始化
    func initLevel() {
        let levelStr = self.gameStateMachine.currentStatue
        self.projectCore.deleteAllComponent()
        if let view = self.skView {
            // 创建用于放置模块的网格框架和网格中的方块
            if self.gridNode != nil {
                self.gridNode.removeFromParent()
            }
            let gridWidth = self.gridWidth // 矩阵宽度
            let gridHeight = self.gridHeight  // 矩阵长度
            let _blockMaxSide = min(view.frame.width, view.frame.height) / CGFloat(max(gridWidth, gridHeight))// 图像边长
            let blockLength = _blockMaxSide * 0.9
            let blockSpacing = _blockMaxSide * 0.1 // 图像间距
            
            
            self.gridFrame = GridFrame(nCols: gridWidth, nRows: gridHeight, sideLength: blockLength, spacing: blockSpacing, centerX: 0, centerY: 0)
            
            self.gridNode = SKNode()
            
            gridFrame.iterateSquares({ squareFrame in
                let imageNode = SKSpriteNode(imageNamed: "block_background")
                imageNode.alpha = 0.5
                imageNode.size = CGSize(width: blockLength, height: blockLength)
                imageNode.position = CGPoint(x: squareFrame.minX+blockLength/2, y: squareFrame.minY+blockLength/2)
                
                gridNode.addChild(imageNode)
            })
            
            addChild(gridNode)
        }
        
        
        self.selectedId.leftPannelSelectedId = nil
        self.selectedId.rightPannelSelectedId = nil
        
        if self.projectCore.componentList.count != 0 {
            self.projectCore.deleteAllComponent()
        }
        
        self.projectCore = ProjectCore(scene: self, currentLevel: self.gameStateMachine.currentStatue)
        
        self.backgroundManager.setup()
        
        self.backgroundManager.initEntities()
        
        for componentDefineTuple in LEVELS_FIXED_COMPONENTS[levelStr]! {
            
            var onAnimating: ((Bool) -> Void)? = nil
            
            for entity in self.backgroundManager.backgrounds {
                
                var isActiveList = Array<Bool?>(repeating: nil, count: entity.detectPos.count)
                
                for (index, (detextX,detectY)) in entity.detectPos.enumerated() {
                    if detextX == componentDefineTuple.x && detectY == componentDefineTuple.y {
                        
                        onAnimating = { isActive in
                            var isActiveList = Array<Bool?>(repeating: nil, count: entity.detectPos.count)
                            isActiveList[index] = isActive
                            entity.onPowerOutletAnimating(isActiveList: isActiveList)
                        }
                        
                    }
                }
                

            }
            
            if let onAnimating = onAnimating {
                self.projectCore.placeComponent(x: componentDefineTuple.x, y: componentDefineTuple.y, rotate: componentDefineTuple.rotate, isMirror: componentDefineTuple.isMirror, componentClass: componentDefineTuple.componentClass, isFixed: true, onAnimating:onAnimating)
            }
            else {
                self.projectCore.placeComponent(x: componentDefineTuple.x, y: componentDefineTuple.y, rotate: componentDefineTuple.rotate, isMirror: componentDefineTuple.isMirror, componentClass: componentDefineTuple.componentClass, isFixed: true)
            }

        }
        
        
    }
    
    // 当过关的那一刻需要做的
    func onLevelPassed() {
        self.levelPassedWindowObject.showWindow()
        self.removeAllChildren()
        
    }
    
    static func reset() {
        if let scene = self.shared {
            scene.removeAllChildren()
            scene.projectCore.deleteAllComponent()
            scene.projectCore._selectedComponent = nil
            scene.gridFrame = nil
            scene.runningUpdater = nil
            scene.lastTickStatue = -1
            scene.hasSettledThisDepth = false
            scene.hasReachedMaxDepth = false
            scene.projectCore = ProjectCore(scene: scene, currentLevel: scene.gameStateMachine.currentStatue)
//            
//            // 关卡的初始化
//            if (Array(1...10).map{"level" + String($0)}+["level0"]).contains(scene.gameStateMachine.currentStatue) {
//                scene.initLevel()
//            }
//            
            self.shared = scene
            
        }

    }

    
    // 工厂方法，返回一个scene实例，用于初始化一个场景，和游戏场景的View对接
    static func makeScene(w:CGFloat,h:CGFloat,selectedId:SelectedId,gameStateMachine:GameStateMachine,popupWindowMsg:PopupWindowMsg,progressBarObj:ProgressObject,levelPassedWindowObject:LevelPassedWindowObject) -> FloatingScene{
        
        if FloatingScene.shared != nil {
            return FloatingScene.shared!
        }
        
        let scene = FloatingScene()
        scene.backgroundColor = .clear
        scene.selectedId = selectedId
        scene.size = CGSize(width: w, height: h)
        scene.gameStateMachine = gameStateMachine
        scene.popupWindowMsg = popupWindowMsg
        scene.progressBarObj = progressBarObj
        scene.levelPassedWindowObject = levelPassedWindowObject
        scene.width = w
        scene.height = h
//        scene.scaleMode = .fill
        FloatingScene.shared = scene
        return scene
    }
}
