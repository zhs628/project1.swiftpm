//
//  SwiftUIView.swift
//  project1
//
//  Created by rzq on 2024/2/24.
//

import SwiftUI

// 横屏下X轴参考线位置
private let LANDSCAPE_X_PROPOTION: [Float] =
    [
        0.001, // 0
        0.021, // 1
        0.218, // 2
    ]
// 横屏下Y轴参考线位置
private let LANDSCAPE_Y_PROPOTION: [Float] =
    [
        0.001, // 0
        0.098, // 1 title水平中线
        0.195,  // 2 信息面板title上界， 进度条上界， 模块面板title上界

    ]
// 是否显示参考线
private let SHOW_GRID_LINE: Bool = Bool(truncating: 0)
// ***********************************


private var PORTRAIT_SCREEN_WIDTH: CGFloat = UIScreen.main.bounds.width
private var PORTRAIT_SCREEN_HEIGHT: CGFloat = UIScreen.main.bounds.height
private var LANDSCAPE_SCREEN_WIDTH: CGFloat = UIScreen.main.bounds.width
private var LANDSCAPE_SCREEN_HEIGHT: CGFloat = UIScreen.main.bounds.height


private var LANDSCAPE_X_COORDINATES: [CGFloat] =
    LANDSCAPE_X_PROPOTION.map{ CGFloat($0) * LANDSCAPE_SCREEN_WIDTH }

private var LANDSCAPE_Y_COORDINATES: [CGFloat] =
    LANDSCAPE_Y_PROPOTION.map{ CGFloat($0) * LANDSCAPE_SCREEN_HEIGHT }


struct SelectLevelView: View {
    @State var offsetY: CGFloat = -LANDSCAPE_SCREEN_WIDTH
    let images = ["select_level_1_pic", "select_level_2_pic", "select_level_3_pic"]
    @State var selectIndex: Int = 0
    
    @State var isSelected: Bool = false
    @State var animationProgress: Float = 0
    
    @EnvironmentObject private var gameStateMachine: GameStateMachine
    
    
    func selectingLevelName() -> String {
        return "level\(self.selectIndex+1)"
    }
    

    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack() {
                if geometry.size.width < geometry.size.height {
                    ZStack{}
                        .frame(width: PORTRAIT_SCREEN_WIDTH, height: PORTRAIT_SCREEN_HEIGHT)
                        .background(Image("spin_ipad_background")
                            .resizable() // 使图片可伸缩
                            .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                            .scaledToFill()
                        )
                } else {
                    ZStack{
                        
                        ZStack(alignment:.center) {
                            
                            if self.selectIndex > 0 {
                                Image("select_level_left_arrow")
                                    .resizable() // 使图片可伸缩
                                    .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                                    .frame(width: 0.1*LANDSCAPE_SCREEN_WIDTH)
                                    .offset(x: -0.5*LANDSCAPE_SCREEN_WIDTH + 0.1*LANDSCAPE_SCREEN_WIDTH)
                            }
                        
                            TabView(selection: $selectIndex) {
                                ForEach(0..<images.count, id: \.self) { index in
                                    
                                    Image(images[index])
                                        .resizable() // 使图片可伸缩
                                        .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                                        .onTapGesture {
                                            withAnimation(.easeOut(duration: 0.5)){
                                                self.animationProgress = 1
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    self.gameStateMachine.currentStatue = self.selectingLevelName()
                                                }
//                                                self.isAnimationEnd = true
                                            }
                                        }
                                    
                                }
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            
                            .frame(
                                width: LANDSCAPE_SCREEN_WIDTH*0.72,
                                height: LANDSCAPE_SCREEN_HEIGHT*0.5
                            )
                            
                            if self.selectIndex < self.images.count-1 {
                                Image("select_level_right_arrow")
                                    .resizable() // 使图片可伸缩
                                    .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                                    .frame(width: 0.1*LANDSCAPE_SCREEN_WIDTH)
                                    .offset(x: 0.5*LANDSCAPE_SCREEN_WIDTH - 0.1*LANDSCAPE_SCREEN_WIDTH)
                            }

                            
                        }
                        .offset(y: 0.06*LANDSCAPE_SCREEN_HEIGHT)
                        
                        

                        
                        // exit按钮
                        ExitButton(
                            center_x: (LANDSCAPE_X_COORDINATES[2] - LANDSCAPE_X_COORDINATES[1])*0.5 + LANDSCAPE_X_COORDINATES[1],
                            center_y: LANDSCAPE_Y_COORDINATES[1],
                            width: (LANDSCAPE_X_COORDINATES[2] - LANDSCAPE_X_COORDINATES[1])*0.5
                        )
                        
                        Rectangle()
                            .frame(width: LANDSCAPE_SCREEN_WIDTH, height: LANDSCAPE_SCREEN_HEIGHT)
                            .background(Color.black)
                            .opacity(Double(self.animationProgress))
                        
                        
                    }
                    .frame(width: LANDSCAPE_SCREEN_WIDTH, height: LANDSCAPE_SCREEN_HEIGHT)
                    .background(
                        Image("select_level_background")
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








#Preview {
    SelectLevelView()
}


