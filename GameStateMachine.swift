//
//  File.swift
//  project1
//
//  Created by rzq on 2024/1/29.
//

import Foundation


class GameStateMachine: ObservableObject {
    // 整个游戏的状态机
    var selectedId: SelectedId? = nil
    @Published var currentStatue: String
    var _currentLevelStateMachine: LevelStateMachine
    var currentLevelStateMachine: LevelStateMachine {
        get {
            self._currentLevelStateMachine.selectedId = selectedId
            return _currentLevelStateMachine
        }
        set(val){
             self._currentLevelStateMachine = val
        }
    }
    //
    // "level1"              <->
    //    v
    // "level2"              <->  "selectLevel" <-> "startMenu"
    //    v
    // "level3"              <->
    //
    // "level0"(playground)  <->
    

    
    init() {
        self.currentStatue = START_MACHINE_STATE
        self._currentLevelStateMachine = LevelStateMachine(nil)
        self._currentLevelStateMachine.owner = self
    }
    
    func getLevel() -> Int? {
        let str = self.currentStatue
        guard str.hasPrefix("level") else {
            return nil
        }
        
        let numbers = str.dropFirst(5).split(whereSeparator: { !$0.isNumber })
        guard let levelNumber = numbers.first, let level = Int(levelNumber) else {
            return nil
        }
        
        return level
    }

    private func setLevel(_ level_num: Int) {
        self.currentLevelStateMachine = LevelStateMachine(self)
        self.currentLevelStateMachine.selectedId = self.selectedId
        
    }
    

    
    func selectLevel(_ level_num:Int) {
        if (level_num == 1) {
            self.setLevel(1)
            self.currentStatue = "level1"
            return
        }
        if (level_num == 2) {
            self.setLevel(3)
            self.currentStatue = "level2"
            return
        }
        if (level_num == 3) {
            self.setLevel(3)
            self.currentStatue = "level3"
            return
        }
        if (level_num == 0) {
            self.setLevel(0)
            self.currentStatue = "level0"
            return
        }
    }
    
    func nextLevel() {
        if (self.getLevel() == 1) {
            self.setLevel(2)
            self.currentStatue = "level2"
            return
        }
        if (self.getLevel() == 2) {
            self.setLevel(3)
            self.currentStatue = "level3"
            return
        }
       
    }
    
    func exit() {
        if self.currentStatue == "selectLevel" {
            self.currentStatue = "startMenu"
        }
        if self.currentStatue.starts(with: "level") {
            self.currentStatue = "selectLevel"
        }
        
    }
    
    func play() {
        if self.currentStatue == "startMenu" {
            self.currentStatue = "selectLevel"
        }
    }
    
}

class LevelStateMachine {
    // 关卡的状态机
    var selectedId: SelectedId! = nil
    var owner: GameStateMachine! = nil
    var _currentStatue: String = "editing"
    var currentStatue: String {
        get {
            return _currentStatue
        }
        set(val){
            
            _currentStatue = val
            
            if (val != "editing") {
                self.selectedId.rightPannelSelectedId = nil
            }
        }
    }
    // _currentStatue:
    // "editing" <-> "running"
    //      ^           ^
    //      |           |
    //      v           v
    //        "pausing"
    
    init(_ owner: GameStateMachine?) {
        self.owner = owner
    }
}
