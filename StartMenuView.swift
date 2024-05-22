//
//  StartMenuView.swift
//  project1
//
//  Created by rzq on 2024/2/24.
//

import SwiftUI

private var PORTRAIT_SCREEN_WIDTH: CGFloat = UIScreen.main.bounds.width
private var PORTRAIT_SCREEN_HEIGHT: CGFloat = UIScreen.main.bounds.height
private var LANDSCAPE_SCREEN_WIDTH: CGFloat = UIScreen.main.bounds.width
private var LANDSCAPE_SCREEN_HEIGHT: CGFloat = UIScreen.main.bounds.height

struct StartMenuView: View {
    var body: some View {
        GeometryReader { geometry in
            
            ZStack() {
                if geometry.size.width < geometry.size.height {
                    ZStack{
                    }
                        .frame(width: PORTRAIT_SCREEN_WIDTH, height: PORTRAIT_SCREEN_HEIGHT)
                        .background(Image("spin_ipad_background")
                            .resizable() // 使图片可伸缩
                            .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                            .scaledToFill()
                                )
                        
                } else {
                    ZStack{
                        PlayButton(
                            center_x: 0.5*LANDSCAPE_SCREEN_WIDTH,
                            center_y: 0.7*LANDSCAPE_SCREEN_HEIGHT,
                            width: 0.2*LANDSCAPE_SCREEN_WIDTH
                        )
                    }
                        .frame(width: LANDSCAPE_SCREEN_WIDTH, height: LANDSCAPE_SCREEN_HEIGHT)
                        .background(Image("start_menu_background")
                            .resizable() // 使图片可伸缩
                            .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
                            .scaledToFill()
                                )
                        
                }
            }
            
        }.ignoresSafeArea()

 
    }
}

struct PlayButton: View {
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
                    self.selectedId.endPressPlayButton = true
                    self.gameStateMachine.play()
                }
        
        return ZStack {

            Image(!self.isPressing ? "play_button_pic" : "pressing_play_button_pic")
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




#Preview {
    StartMenuView()
}
