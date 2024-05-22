import SwiftUI
import SpriteKit

// ***********************************
// 竖屏下X轴参考线位置
private let PORTRAIT_X_PROPOTION: [Float] =
    [
        0.001, // 0
        0.021, // 1
     2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0,  // 占位，补充长度到 9
        0.5  // 10
    ]
// 竖屏下Y轴参考线位置
private let PORTRAIT_Y_PROPOTION: [Float] =
    [
        0.001, // 0
        0.04, // 1
        0.08,  // 2
    3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0,  // 占位，补充长度到 9
        0.5,  // 10
    11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0,  // 占位，补充长度到 19
        0.9  // 20
    ]


// 横屏下X轴参考线位置
private let LANDSCAPE_X_PROPOTION: [Float] =
    [
        0.001, // 0
        0.021, // 1
        0.218, // 2
        0.241, // 3
       4.0, 5.0, 6.0, 7.0, 8.0, 9.0,  // 占位，补充长度到 9
        0.5,  // 10
    11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0,  // 占位，补充长度到 19
        0.759, // 20
        0.781, // 21
        0.980  // 22
    ]
// 横屏下Y轴参考线位置
private let LANDSCAPE_Y_PROPOTION: [Float] =
    [
        0.001, // 0
        0.098, // 1 title水平中线
        0.195,  // 2 信息面板title上界， 进度条上界， 模块面板title上界
        0.247, // 3 信息面板title下界， 模块面板title下界
        0.260, // 4 中央背景板上界
    5.0, 6.0, 7.0, 8.0, 9.0,  // 占位，补充长度到 9
        0.5,  // 10
    11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 17.0, 18.0, 19.0,  // 占位，补充长度到 19
        0.715, // 20 元件面板下界
        0.727, // 21 工具面板上界
        0.755, // 22 中央背景板下界
        0.782, // 23 控制面板上界， 工具面板title下界
            24.0, 25.0, 26.0, 27.0, 28.0, // 占位，补充长度到 28
        0.909,  // 29 信息面板下界， 控制面板下界
        0.927   // 30 工具面板下界
    ]
// 是否显示参考线
private let SHOW_GRID_LINE: Bool = Bool(truncating: 0)
// ***********************************


private var PORTRAIT_SCREEN_WIDTH: CGFloat = UIScreen.main.bounds.width
private var PORTRAIT_SCREEN_HEIGHT: CGFloat = UIScreen.main.bounds.height
private var LANDSCAPE_SCREEN_WIDTH: CGFloat = UIScreen.main.bounds.width
private var LANDSCAPE_SCREEN_HEIGHT: CGFloat = UIScreen.main.bounds.height

private var PORTRAIT_X_COORDINATES: [CGFloat] =
    PORTRAIT_X_PROPOTION.map{ CGFloat($0) * PORTRAIT_SCREEN_WIDTH }

private var PORTRAIT_Y_COORDINATES: [CGFloat] =
    PORTRAIT_Y_PROPOTION.map{ CGFloat($0) * PORTRAIT_SCREEN_HEIGHT }

private var LANDSCAPE_X_COORDINATES: [CGFloat] =
    LANDSCAPE_X_PROPOTION.map{ CGFloat($0) * LANDSCAPE_SCREEN_WIDTH }

private var LANDSCAPE_Y_COORDINATES: [CGFloat] =
    LANDSCAPE_Y_PROPOTION.map{ CGFloat($0) * LANDSCAPE_SCREEN_HEIGHT }

var COMPONENT_SCALE = (LANDSCAPE_X_COORDINATES[22]-LANDSCAPE_X_COORDINATES[21]) * 0.2


struct WorkBenchView: View {
    @EnvironmentObject private var popupWindowMsg: PopupWindowMsg
    @EnvironmentObject var progress: ProgressObject
    @EnvironmentObject private var levelPassedWindowObject: LevelPassedWindowObject

    
    var body: some View {
        
        ZStack() {
            GeometryReader { geometry in
                
                ZStack() {
                    if geometry.size.width < geometry.size.height {
                        // 页面内容: 竖屏
                        ZStack(){
                            
                        }
                        .frame(width: PORTRAIT_SCREEN_WIDTH, height: PORTRAIT_SCREEN_HEIGHT)
                        .background(Image("spin_ipad_background")
                            .resizable() // 使图片可伸缩
                            .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                                )
                        
                        // 竖屏参考线
                        GridLinesView(
                            xProportion: PORTRAIT_X_PROPOTION,
                            yProportion: PORTRAIT_Y_PROPOTION,
                            isShow: SHOW_GRID_LINE,
                            screenWidth: PORTRAIT_SCREEN_WIDTH,
                            screenHeight: PORTRAIT_SCREEN_HEIGHT)
                    } else {
                        // 页面内容: 横屏
                        ZStack(){
                            // 关卡 title
                            WorkBenchTitle(
                                center_x: LANDSCAPE_X_COORDINATES[10],
                                center_y: LANDSCAPE_Y_COORDINATES[1],
                                height: (LANDSCAPE_Y_COORDINATES[1]-LANDSCAPE_Y_COORDINATES[0]) * 0.8
                            )
                            
                            // exit按钮
                            ExitButton(
                                center_x: (LANDSCAPE_X_COORDINATES[2] - LANDSCAPE_X_COORDINATES[1])*0.5 + LANDSCAPE_X_COORDINATES[1],
                                center_y: LANDSCAPE_Y_COORDINATES[1],
                                width: (LANDSCAPE_X_COORDINATES[2] - LANDSCAPE_X_COORDINATES[1])*0.5
                            )

                            // 信息面板
                            InformationPanel(
                                x: LANDSCAPE_X_COORDINATES[1],
                                y: LANDSCAPE_Y_COORDINATES[2],
                                width: LANDSCAPE_X_COORDINATES[2]-LANDSCAPE_X_COORDINATES[1],
                                height: LANDSCAPE_Y_COORDINATES[29]-LANDSCAPE_Y_COORDINATES[2],
                                titleHeight: LANDSCAPE_Y_COORDINATES[3] - LANDSCAPE_Y_COORDINATES[2]
                            )
                            
                            // 组件面板
                            ComponentsPanel(
                                x: LANDSCAPE_X_COORDINATES[21],
                                y: LANDSCAPE_Y_COORDINATES[2],
                                width: LANDSCAPE_X_COORDINATES[22]-LANDSCAPE_X_COORDINATES[21],
                                height: LANDSCAPE_Y_COORDINATES[20]-LANDSCAPE_Y_COORDINATES[2],
                                titleHeight: LANDSCAPE_Y_COORDINATES[3] - LANDSCAPE_Y_COORDINATES[2]
                            )
                            
                            // 工具面板
                            ToolsPanel(
                                x: LANDSCAPE_X_COORDINATES[21],
                                y: LANDSCAPE_Y_COORDINATES[21],
                                width: LANDSCAPE_X_COORDINATES[22]-LANDSCAPE_X_COORDINATES[21],
                                height: LANDSCAPE_Y_COORDINATES[30]-LANDSCAPE_Y_COORDINATES[21],
                                titleHeight: LANDSCAPE_Y_COORDINATES[23] - LANDSCAPE_Y_COORDINATES[21]
                            )
                            
                            // 控制面板
                            ControlPanel(
                                x: LANDSCAPE_X_COORDINATES[3],
                                y: LANDSCAPE_Y_COORDINATES[23],
                                width: LANDSCAPE_X_COORDINATES[20]-LANDSCAPE_X_COORDINATES[3],
                                height: LANDSCAPE_Y_COORDINATES[29]-LANDSCAPE_Y_COORDINATES[23]
                            )
                            

                            // 中央游戏场景
                            FloatingSceneView(
                                x: LANDSCAPE_X_COORDINATES[3],
                                y: LANDSCAPE_Y_COORDINATES[4],
                                width: LANDSCAPE_X_COORDINATES[20]-LANDSCAPE_X_COORDINATES[3],
                                height: LANDSCAPE_Y_COORDINATES[22]-LANDSCAPE_Y_COORDINATES[4]
                            )
                            
                            // 进度条
                            ProgressBar(x: LANDSCAPE_X_COORDINATES[3],
                                        y: LANDSCAPE_Y_COORDINATES[2],
                                        width: LANDSCAPE_X_COORDINATES[20]-LANDSCAPE_X_COORDINATES[3],
                                        height: LANDSCAPE_Y_COORDINATES[3]-LANDSCAPE_Y_COORDINATES[2])
                            
                            // 提示弹窗
                            if popupWindowMsg.messageTuple != nil {
                                HintWindow()
                            }
                            
                            //过关弹窗
                            if levelPassedWindowObject.isShowing {
                                LevelPassedWindow()
                            }
                            
                        }
                        .frame(width: LANDSCAPE_SCREEN_WIDTH, height: LANDSCAPE_SCREEN_HEIGHT)
                        .background(Image("level_background")
                            .resizable() // 使图片可伸缩
                            .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                            .scaledToFill()
                                )
                            

                        
                        // 横屏参考线
                        GridLinesView(
                            xProportion: LANDSCAPE_X_PROPOTION,
                            yProportion: LANDSCAPE_Y_PROPOTION,
                            isShow: SHOW_GRID_LINE,
                            screenWidth: LANDSCAPE_SCREEN_WIDTH,
                            screenHeight: LANDSCAPE_SCREEN_HEIGHT)

                    }


                }
                
            }.ignoresSafeArea()
        }

        



    }
}










// 工作台界面的title
struct WorkBenchTitle: View {
    var center_x: CGFloat
    var center_y: CGFloat
    var height: CGFloat
    @EnvironmentObject private var gameStateMachine: GameStateMachine


    var body: some View {
        HStack() {
            // 扳手logo
            ZStack() {
                Image("tool_logo")
                .resizable() // 使图片可伸缩
                .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                .frame(width: height, height: height)
                .rotationEffect(.degrees(-82.15+90))

            }
            .shadow(
                color: Color(red: 0, green: 0, blue: 0, opacity: 0.25), radius: 4, y: 4
            )
            // 关卡标题
            ZStack() {
//                Image("title_string")
//                .resizable() // 使图片可伸缩
//                .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
//                .frame(height: height*0.65)
//                .offset(x:0, y: -height*0.1)
                
                Text(self.gameStateMachine.currentStatue)
                    .font(
                        Font.custom("WendyOne-Regular", size: self.height)
                    .weight(.bold)
                    )
                    .frame(height: self.height)
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .lineLimit(nil)

            }.padding(.horizontal, height*0.3)
            
            // 闹钟logo
            ZStack() {
                Image("clock_logo")
                .resizable() // 使图片可伸缩
                .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                .frame(width: height, height: height)


            }
            .shadow(
                color: Color(red: 0, green: 0, blue: 0, opacity: 0.25), radius: 4, y: 4
            )
            
        }
        .position(x: center_x, y: center_y)
    }
}


// 工作台界面的左侧用于显示模块信息的面板
struct InformationPanel: View {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var titleHeight: CGFloat
    
    var _topPicWidth: CGFloat
     
    @EnvironmentObject private var selectedId: SelectedId
    
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, titleHeight: CGFloat) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.titleHeight = titleHeight
        
        self._topPicWidth = height / 8
    }
    
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: width, height: height)
                .background(PANNEL_COLOR)
                .cornerRadius(25)
            
            ZStack() {
                RoundedCorners(
                    color: Color(red: 0.16, green: 0.21, blue: 0.31),
                    tl: 30,
                    tr: 30
                )
                .foregroundColor(.clear)
                .frame(width: width, height: titleHeight)
                Image("information_panel_title_string")
                    .resizable() // 使图片可伸缩
                    .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                    .frame(height: titleHeight*0.4)
            }
            
            if let componentType = self.selectedId.leftPannelSelectedId {
                VStack {
                    
                    let exampleComponent: Component = componentType.init(x: 0, y: 0, neighborComponentList: [], projectCore: nil, scene: nil)
                    
                    Spacer()
                    // 顶部的元件大图片
                    Image(exampleComponent.imageName)
                        .resizable() // 使图片可伸缩
                        .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                        .frame(height: self._topPicWidth)
                        .frame(alignment: .center)
                    
                    // 图片下的元件名字
                    Text(String(describing: componentType.self))
                        .font(
                        Font.custom("WendyOne-Regular", size: 24)
                        .weight(.bold)
                        )
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .frame(alignment: .center)
                    Spacer()
                    
                    Text(String(describing: exampleComponent.descForTopPic))
                        .font(
                        Font.custom("WendyOne-Regular", size: 15)
                        .weight(.bold)
                        )
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .frame(width: self.width * 0.9)
                        .frame(alignment: .leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true) // 高度根据文本内容自动确定
                    
                    // 使用说明图1
                    Image(exampleComponent.presentation1ImageName)
                        .resizable() // 使图片可伸缩
                        .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                        .frame(height: self._topPicWidth*1.25)
                        .frame(alignment: .center)
                    
                    Text(String(describing: exampleComponent.descForPresentation1))
                        .font(
                        Font.custom("WendyOne-Regular", size: 10)
                        .weight(.bold)
                        )
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .frame(width: self.width * 0.9)
                        .frame(alignment: .leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true) // 高度根据文本内容自动确定
                    // 使用说明图2
                    Image(exampleComponent.presentation2ImageName)
                        .resizable() // 使图片可伸缩
                        .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                        .frame(height: self._topPicWidth*1.25)
                        .frame(alignment: .center)
                    
                    Text(String(describing: exampleComponent.descForPresentation2))
                        .font(
                        Font.custom("WendyOne-Regular", size: 10)
                        .weight(.bold)
                        )
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                        .frame(width: self.width * 0.9)
                        .frame(alignment: .leading)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true) // 高度根据文本内容自动确定
                    Spacer()
                    
                }
                .frame(width:self.width, height: self.height-self.titleHeight)
                .offset(y:titleHeight)

            }

            
        }
        .position(
            x: x + width/2,
            y: y + height/2
        )
    }
}

// 工作台右侧用于罗列所有模块的面板
struct ComponentsPanel: View {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var titleHeight: CGFloat
    var _space: CGFloat {
        return (self.width - (2*COMPONENT_SCALE))/3
    }

    
    var body: some View {
        ZStack(alignment: .top) {

            Rectangle()
                .foregroundColor(.clear)
                .frame(width: width, height: height)
                .background(PANNEL_COLOR)
                .cornerRadius(25)
            
            ZStack() {
                RoundedCorners(
                    color: Color(red: 0.16, green: 0.21, blue: 0.31),
                    tl: 30,
                    tr: 30
                )
                .foregroundColor(.clear)
                .frame(width: width, height: titleHeight)
                Image("components_panel_title_string")
                    .resizable() // 使图片可伸缩
                    .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                    .frame(height: titleHeight*0.4)
            }
            
            ComponentsPanelContent(
                titleHeight: titleHeight,
                _space: _space
            )


            
        }
        .frame(
            width: width,
            height: height
        )
        .position(
            x: x + width/2,
            y: y + height/2
        )

    }
}

struct ComponentButtonView<T: ComponentViews>: View {
    let makeComponentView: (_ componentView: T.Type) -> T
    let makeBtnAction: (_ componentView: T.Type) -> () -> Void
    var body: some View {
        Button(action: makeBtnAction(T.self)){
            makeComponentView(T.self)
            .frame(width: COMPONENT_SCALE, height: COMPONENT_SCALE)
        }
    }
}


// ComponentsPanelContent基于VStack的内容创建
struct ComponentsPanelContent: View {
    let titleHeight: CGFloat
    let _space: CGFloat
    @EnvironmentObject private var selectedId: SelectedId
    @EnvironmentObject private var gameStateMachine: GameStateMachine
    
    func makeBtnAction<T: ComponentViews>(componentView:T.Type)->()->Void {
        return {
            let componentType = T.componentType
            if (gameStateMachine.currentLevelStateMachine.currentStatue == "editing") {
                self.selectedId.selectRightPannelComponent(componentType: selectedId.rightPannelSelectedId == componentType ? nil : componentType)
            }

        }
    }
    
    func makeComponentView<T: ComponentViews>(componentView:T.Type) -> T {
        return componentView.init(
            x: 0 + self._space,
            y: self.titleHeight + self._space,
            width: COMPONENT_SCALE,
            height: COMPONENT_SCALE,
            isSelected: (self.selectedId.rightPannelSelectedId == componentView.componentType)
        )
    }
    
    func makeButtonView<T: ComponentViews>(_ componentView:T.Type) -> ComponentButtonView<T> {
        return ComponentButtonView<T>( makeComponentView: makeComponentView, makeBtnAction: makeBtnAction)
    }
    
    var body: some View {
        
        // 以下设定每一个关卡给定的元件种类
        if self.gameStateMachine.currentStatue == "level0" {
            VStack(spacing:_space) {
                HStack(spacing:_space){
                    makeButtonView(PowerSourceView.self)
                    makeButtonView(WireView.self)
                }
                HStack(spacing:_space){
                    makeButtonView(DistributorView.self)
                    makeButtonView(BridgeView.self)
                }
                HStack(spacing:_space){
                    makeButtonView(PowerOutletView.self)
                    makeButtonView(DelayerView.self)
                }
                HStack(spacing:_space){
                    makeButtonView(InterrupterView.self)
                }
            }.offset(x:0, y:titleHeight + _space)
        }
        if self.gameStateMachine.currentStatue == "level1" {
            VStack(spacing:_space) {
                HStack(spacing:_space){
                    makeButtonView(WireView.self)
                }
            }.offset(x:0, y:titleHeight + _space)
        }
        if self.gameStateMachine.currentStatue == "level2" {
            VStack(spacing:_space) {
                HStack(spacing:_space){
                    makeButtonView(WireView.self)
                    makeButtonView(BridgeView.self)
                }
            }.offset(x:0, y:titleHeight + _space)
        }
        if self.gameStateMachine.currentStatue == "level3" {
            VStack(spacing:_space) {
                HStack(spacing:_space){
                    makeButtonView(WireView.self)
                    makeButtonView(BridgeView.self)
                    
                }
                HStack(spacing:_space){
                    makeButtonView(DistributorView.self)
                    makeButtonView(DelayerView.self)
                }
                HStack(spacing:_space){
                    makeButtonView(InterrupterView.self)
                }
            }.offset(x:0, y:titleHeight + _space)
        }

    }
}



// 工作台右下角用于对模块进行旋转，删除等操作的面板
struct ToolsPanel: View {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var titleHeight: CGFloat
    var buttonHeight: CGFloat
    var buttonSepWidth: CGFloat
    
    @EnvironmentObject private var selectedId: SelectedId
    
    init(
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        height: CGFloat,
        titleHeight: CGFloat,
        buttonHeight: CGFloat = -1,
        buttonSepWidth: CGFloat = -1
        
    ) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.titleHeight = titleHeight
        let sep = buttonSepWidth > 0 ? buttonSepWidth : 0.1 * width
        self.buttonSepWidth = sep
        self.buttonHeight = buttonHeight > 0 ? buttonHeight : (width - 3*sep)/3
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: width, height: height)
                .background(PANNEL_COLOR)
                .cornerRadius(25)
            
            VStack(spacing:0){
                ZStack() {
                    RoundedCorners(
                        color: Color(red: 0.16, green: 0.21, blue: 0.31),
                        tl: 30,
                        tr: 30
                    )
                    .foregroundColor(.clear)
                    .frame(width: width, height: titleHeight)
                    
                    Image("edit_panel_title_string")
                        .resizable() // 使图片可伸缩
                        .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                        .frame(height: titleHeight*0.4)
                }
                
                HStack(spacing:buttonSepWidth) {
                    
                    // 删除按钮
                    Button(action: {
                        selectedId.pressingRemoveButton = true
                    }) {
                        ZStack {
                            Image("remove_button_pic")
                                .resizable() // 使图片可伸缩
                                .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                                .frame(height: buttonHeight)

                        }
                    }
                    
                    // 旋转按钮
                    Button(action: {
                        selectedId.pressingSpinButton = true
                    }) {
                        ZStack {

                            Image("spin_button_pic")
                                .resizable() // 使图片可伸缩
                                .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                                .frame(height: buttonHeight)
                            

                        }
                    }

                    
                    // 镜像按钮
                    Button(action: {
                        selectedId.pressingMirrorButton = true
                    }) {
                        ZStack {

                            Image("mirror_button_pic")
                                .resizable() // 使图片可伸缩
                                .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                                .frame(height: buttonHeight)
                        }
                    }

                }
                .frame(width: width, height: height-titleHeight)
            }

            
        }
        .position(
            x: x + width/2,
            y: y + height/2
        )
    }
}

// 工作台下方用于运行/停止仿真的控制面板
struct ControlPanel: View {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    var buttonHeight: CGFloat
    var buttonSepWidth: CGFloat


    @EnvironmentObject private var selectedId: SelectedId

    
    init(
        x: CGFloat,
        y: CGFloat,
        width: CGFloat,
        height: CGFloat,
        buttonHeight: CGFloat = -1,
        buttonSepWidth: CGFloat = -1
        
    ) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.buttonHeight = buttonHeight > 0 ? buttonHeight : 0.755 * height
        self.buttonSepWidth = buttonSepWidth > 0 ? buttonSepWidth : 0.145 * width
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: width, height: height)
                .background(PANNEL_COLOR)
                .cornerRadius(10)
            
            HStack(spacing:buttonSepWidth) {
                
                // 运行按钮
                Button(action: {
                    selectedId.pressingStartButton = true
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: buttonHeight, height: buttonHeight)
                            .background(Color(red: 0.20, green: 0.20, blue: 0.20).opacity(0.30))
                            .cornerRadius(10)
                        
                        Image("run_button_pic")
                            .resizable() // 使图片可伸缩
                            .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                            .frame(height: buttonHeight*0.46)
                            .offset(x:0.03*buttonHeight,y:0)
                    }
                }
                
                // 终止按钮
                Button(action: {
                    selectedId.pressingEndButton = true
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: buttonHeight, height: buttonHeight)
                            .background(Color(red: 0.20, green: 0.20, blue: 0.20).opacity(0.30))
                            .cornerRadius(10)
                        
                        Image("end_button_pic")
                            .resizable() // 使图片可伸缩
                            .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                            .frame(height: buttonHeight*0.41)
                        

                    }
                }

                
                // 重新运行按钮
                Button(action: {
                    selectedId.pressingRerunButton = true
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: buttonHeight, height: buttonHeight)
                            .background(Color(red: 0.20, green: 0.20, blue: 0.20).opacity(0.30))
                            .cornerRadius(10)
                        
                        Image("rerun_button_pic")
                            .resizable() // 使图片可伸缩
                            .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                            .frame(height: buttonHeight*0.58)
                    }
                }

            }
            .frame(width: width, height: height)
            
        }
        .position(
            x: x + width/2,
            y: y + height/2
        )
    }
}

// 工作台中央用于放置编辑电路的地方
struct EditArea: View {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: width, height: height)
                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                .cornerRadius(25)
            
        }
        .position(
            x: x + width/2,
            y: y + height/2
        )
    }
}

// 提示弹窗

struct HintWindow: View {
    @EnvironmentObject private var popupWindowMsg: PopupWindowMsg
    @State private var backgroundOpacity = 0.0
    @State private var popupOffset = UIScreen.main.bounds.height
    private var color: Color {
        get {
            if let type = popupWindowMsg.messageTuple?.msgType {
                if type == "error" {
                    return Color.red
                }
                if type == "info" {
                    return Color.blue
                }
                if type == "warning" {
                    return Color.yellow
                }
            }
            return Color.black
        }
    }

    var body: some View {
        if let messageTuple = popupWindowMsg.messageTuple {
            ZStack {
                // 背景透明遮罩层
                Color.black
                    .opacity(backgroundOpacity)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        dismissPopup()
                    }
                    // 添加动画效果应用于背景透明度
                    .animation(.easeInOut(duration: 0.3), value: backgroundOpacity)
                
                // 弹窗提示框
                VStack {

                    Text(messageTuple.message)
                        .font(Font.system(size: LANDSCAPE_SCREEN_HEIGHT * 0.05 * 0.8))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: LANDSCAPE_SCREEN_WIDTH * 0.8)
                        .background(self.color)
                        .cornerRadius(10)
                        // 应用弹窗内容的动画效果
                        .offset(y: popupOffset - LANDSCAPE_SCREEN_HEIGHT * 0.3)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: popupOffset)

                }
            }
            .onAppear {
                // 触发动画
                withAnimation {
                    backgroundOpacity = 0.6
                    popupOffset = 0
                }
            }
        }
    }
    
    private func dismissPopup() {
        if #available(iOS 17.0, *) {
            withAnimation {
                backgroundOpacity = 0
                popupOffset = UIScreen.main.bounds.height
                
            } completion: {
                // 在动画结束时调用其他函数
                popupWindowMsg.messageTuple = nil
            }
        } else {
            // Fallback on earlier versions
            popupWindowMsg.messageTuple = nil
        }
        
    }
}

struct LevelPassedWindow: View {
    @State private var backgroundOpacity = 0.0
    @State private var popupOffset = UIScreen.main.bounds.height
    @EnvironmentObject private var gameStateMachine: GameStateMachine
    @EnvironmentObject private var levelPassedWindowObject: LevelPassedWindowObject


    var body: some View {
        if levelPassedWindowObject.isShowing {
            ZStack {
                // 背景透明遮罩层
                Color.white
                    .opacity(backgroundOpacity)
                    .edgesIgnoringSafeArea(.all)
                    // 添加动画效果应用于背景透明度
                    .animation(.easeInOut(duration: 0.3), value: backgroundOpacity)
                 
                // 弹窗
                ZStack {
                    Image("level_passed_window_background")
                    .resizable() // 使图片可伸缩
                    .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                    .frame(width: LANDSCAPE_SCREEN_WIDTH * 0.5)
                
                    HStack(spacing: LANDSCAPE_SCREEN_WIDTH*0.5*0.2) {
                        // exit按钮
                        Button(action: {
                            self.gameStateMachine.currentStatue = "selectLevel"
                            dismissPopup()
                        }) {
                            Image("exit_button_pic")
                                .resizable() // 使图片可伸缩
                                .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                                .frame(width: LANDSCAPE_SCREEN_WIDTH*0.5*0.2)
                            
                        }
                        
//                        // next按钮
//                        Button(action: {
//                            dismissPopup()
//                        }) {
//                            Image("next_button_pic")
//                                .resizable() // 使图片可伸缩
//                                .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
//                                .frame(width: LANDSCAPE_SCREEN_WIDTH*0.5*0.2)
//
//                        }

                    
                    }.offset(y:LANDSCAPE_SCREEN_WIDTH*0.5*0.2)
                    
                    
                    
                    
                }
                     
                // 应用弹窗内容的动画效果
                .offset(y: popupOffset)
                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: popupOffset)
                
            }
            .onAppear {
                // 触发动画
                withAnimation {
                    backgroundOpacity = 0.4
                    popupOffset = 0
                }
            }
        }
    }
    
    private func dismissPopup() {
        if #available(iOS 17.0, *) {
            withAnimation {
                backgroundOpacity = 0
                popupOffset = UIScreen.main.bounds.height
                
            } completion: {
                // 在动画结束时调用其他函数
                levelPassedWindowObject.notShowWindow()
            }
        } else {
            // Fallback on earlier versions
            levelPassedWindowObject.notShowWindow()
        }
    }
}


struct ProgressBar: View {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat

    @EnvironmentObject var progress: ProgressObject
    @State private var animatedWidth: CGFloat = 0

    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }

    var body: some View {
        ZStack(alignment: .leading) {

            
            Image("progress_bar_background")
                .resizable() // 使图片可伸缩
                .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                .frame(width: self.width, height: self.height)

                
                

            Rectangle()
                .foregroundColor(.blue)
                .frame(width: self.animatedWidth, height: self.height*0.9)
                .cornerRadius(10)
        }
        .frame(width: self.width, height: self.height)
        .position(
            x: x + width/2,
            y: y + height/2
        )
        .onAppear {
            withAnimation(.interpolatingSpring(mass: 1, stiffness: 100, damping: 10, initialVelocity: 0)) {
                self.animatedWidth = CGFloat(self.progress.percentage) * self.width
                self.animatedWidth = self.animatedWidth >= 0 ? self.animatedWidth : 0
                self.animatedWidth = self.animatedWidth <= self.width ? self.animatedWidth : self.width
            }
        }
        .onChange(of: progress.percentage) { value in
            withAnimation(.interpolatingSpring(mass: 1, stiffness: 100, damping: 10, initialVelocity: 0)) {
                self.animatedWidth = CGFloat(value) * self.width
                self.animatedWidth = self.animatedWidth >= 0 ? self.animatedWidth : 0
                self.animatedWidth = self.animatedWidth <= self.width ? self.animatedWidth : self.width
            }
        }
    }
}


struct ExitButton: View {
    var center_x: CGFloat
    var center_y: CGFloat
    var width: CGFloat

    @EnvironmentObject private var gameStateMachine: GameStateMachine
    @EnvironmentObject private var selectedId: SelectedId
    @State private var isPressing = false
    
    var body: some View {
        
        let gesture =
        LongPressGesture(minimumDuration: 0)
                .onEnded {
                    _ in
                    self.isPressing = true
                }
                .sequenced(before: DragGesture(minimumDistance: 0))
                .onEnded { _ in
                    self.isPressing = false
                    self.selectedId.endPressExitButton = true
                    self.gameStateMachine.exit()
                    FloatingScene.reset()
                }
        return ZStack {

            Image(!self.isPressing ? "exit_button_on_workbench" : "pressing_exit_button_on_workbench")
                .resizable() // 使图片可伸缩
                .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                .frame(width: self.width)
                .position(
                    x: center_x,
                    y: center_y
                )
            
        }.gesture(gesture)

    }
}







// 中央游戏场景，包括场景类的初始化
struct FloatingSceneView: View {
    var x:CGFloat
    var y:CGFloat
    var width: CGFloat
    var height: CGFloat
    @EnvironmentObject private var selectedId: SelectedId
    @EnvironmentObject private var gameStateMachine: GameStateMachine
    @EnvironmentObject private var popupWindowMsg: PopupWindowMsg
    @EnvironmentObject private var progress: ProgressObject
    @EnvironmentObject private var levelPassedWindowObject: LevelPassedWindowObject
    
    weak var scene: FloatingScene? = nil
    

    var body: some View {
        ZStack{
            SpriteView(
                scene: 
                    FloatingScene.makeScene(
                        w: width,
                        h: height,
                        selectedId: self.selectedId,
                        gameStateMachine: self.gameStateMachine,
                        popupWindowMsg: self.popupWindowMsg,
                        progressBarObj: self.progress,
                        levelPassedWindowObject: self.levelPassedWindowObject
                    )
                
            )
            .frame(width: width, height: height)
            .ignoresSafeArea()
            .cornerRadius(30)
            

        }
        .position(
            x: x + width/2,
            y: y + height/2
            )
    }
}
