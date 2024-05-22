import SwiftUI
import Combine


// 字体
public struct MyFont {
    public static func registerFonts() {
        registerFont(bundle: Bundle.main , fontName: "WendyOne-Regular", fontExtension: ".ttf") //change according to your ext.
    }

    fileprivate static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) {
        
        guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension),
              let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(fontDataProvider) else {
            fatalError("Couldn't create font from data")
        }
        
        var error: Unmanaged<CFError>?
        
        CTFontManagerRegisterGraphicsFont(font, &error)
    }
}



class SelectedId: ObservableObject {
    @Published var rightPannelSelectedId:Component.Type! = nil
    @Published var leftPannelSelectedId:Component.Type! = nil
    
    @Published var pressingStartButton:Bool = false
    @Published var pressingEndButton:Bool = false
    @Published var pressingRerunButton:Bool = false
    
    @Published var pressingRemoveButton:Bool = false
    @Published var pressingSpinButton:Bool = false
    @Published var pressingMirrorButton:Bool = false
    
    @Published var endPressExitButton:Bool = false
    @Published var endPressPlayButton:Bool = false
    
    func selectRightPannelComponent(componentType: Component.Type?) {
        self.rightPannelSelectedId = componentType
        self.leftPannelSelectedId = componentType
    }

}

class PopupWindowMsg: ObservableObject {
    @Published var messageTuple: (message:String, msgType:String)? = nil
    
    // msgType: "error", "warning", "info"
    func showWindow(message: String, msgType: String) {
        self.messageTuple = (message:message, msgType:msgType)
    }
}

class ProgressObject: ObservableObject {
    @Published var percentage: Float = 0
    
    func updatePercent(percent: Float) {
        self.percentage = percent >= 0 ? percent : 0
        self.percentage = self.percentage <= 1 ? percent : 1
    }
}

class LevelPassedWindowObject: ObservableObject {
    @Published var isShowing: Bool = false
    
    func showWindow() {
        self.isShowing = true
    }
    
    func notShowWindow() {
        self.isShowing = false
    }
}


@main
struct MyApp: App {
//    @StateObject private var projectCore = ProjectCore()
    @StateObject private var selectedId = SelectedId()
    @StateObject private var gameStateMachine = GameStateMachine()
    @StateObject private var popupWindowMsg = PopupWindowMsg()
    @StateObject private var progressObject = ProgressObject()
    @StateObject private var levelPassedWindowObject = LevelPassedWindowObject()
    init() {
            MyFont.registerFonts()
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameStateMachine)
                .environmentObject(selectedId)
                .environmentObject(popupWindowMsg)
                .environmentObject(progressObject)
                .environmentObject(levelPassedWindowObject)
                .onAppear {
                    gameStateMachine.selectedId = selectedId
                }
        }

    }
}
