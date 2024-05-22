import SwiftUI


private var screen_width: CGFloat = UIScreen.main.bounds.height
private var screen_height: CGFloat = UIScreen.main.bounds.width


struct ContentView: View {
    @EnvironmentObject private var gameStateMachine: GameStateMachine

    var body: some View {
        ZStack() {
            if gameStateMachine.currentStatue.contains("level") {
                // 工作台
                WorkBenchView()
            }
            if gameStateMachine.currentStatue == "selectLevel" {
                // 选关
                SelectLevelView()
            }
            if gameStateMachine.currentStatue == "startMenu" {
                // 开始页面
                StartMenuView()
            }


        }

  }
}

