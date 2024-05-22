//
//  File.swift
//  
//
//  Created by rzq on 2024/2/17.
//

import Foundation
import SwiftUI
import SpriteKit

let _level1InputSeqGen: (Int)->[Bool] = {
    t in
    return [true]

}
let _level1OutputSeqGen: (Int)->[Bool] = {
    t in
    return [true]
}



let _level2InputSeqGen: (Int)->[Bool] = {
    t in
    if t % 6 < 3{
        return [true, false, false, true]
    }
    else{
        return [false, true, true, false]
    }
    
}

let _level2OutputSeqGen: (Int)->[Bool] = {
    t in
    if t % 6 < 3{
        return [true, false, false, true]
    }
    else{
        return [false, true, true, false]
    }
}



let _level3InputSeqGen: (Int)->[Bool] = {
    
    t in
    if t % 2 == 0 {
        return [true]
    }
    return [false]

            
}

let _level3OutputSeqGen: (Int)->[Bool] = {
    t in
    return [true]
}


// 播放速度因子
let SPEED_FACTOR = 0.05

// 初始界面
let START_MACHINE_STATE = "startMenu"

// 显示锚点
let SHOW_ANCHOR = false


// 状态机关卡
let LEVELS_STR_LIST = [
    "level0",
    "level1",
    "level2",
    "level3"
]

//    [
//     "level1":
//         [
//          tick 0
//            (inputs: [输入1， 输入2， 输入3], outputs:[输出1]),
//          tick 1
//            (inputs: [输入1， 输入2， 输入3], outputs:[输出1]),
//            ...
//
//         ],
//
//     "level2": ...
//    ]

let LEVELS_INPUT_OUTPUT_MAPPING: [String :
                            [
                                (inputs: [Bool], outputs: [Bool])
                            ]
                          ] = 
[
    // playground
    "level0": [
        
    ],
    // 第一关

    "level1": (0..<10).map {
        t in
        (inputs: _level1InputSeqGen(t), outputs: _level1OutputSeqGen(t))
    },
    
    // 第二关
        
    "level2": (0..<20).map {
        t in
        (inputs: _level2InputSeqGen(t), outputs:_level2OutputSeqGen(t))
    },
    
    // 第三关
        
    "level3": (0..<20).map {
        t in
        (inputs: _level3InputSeqGen(t), outputs:_level3OutputSeqGen(t))
    }
    
]

// 关卡预设的网格规格
let LEVELS_GRID_SCALE: [String: (width:Int, height:Int)] =
[
    "level1": (width:7, height:5),
    "level2": (width:10, height:8),
    "level3": (width:13, height:9),
    "level0": (width:13, height:9)
]

// 关卡预设的元件
let LEVELS_FIXED_COMPONENTS: [String:
    [
        (x:Int, y:Int, rotate:Int, isMirror:Bool, componentClass:Component.Type)
    ]
]
= [
    // playground
    "level0": [],
    // 第一关
    "level1": [
        (x: 1, y: 3, rotate: 0, isMirror: false, componentClass: PowerSource.self),
        
        (x: 3, y: 3, rotate: 90, isMirror: false, componentClass: Wire.self),
        
        (x: 3, y: 1, rotate: 0, isMirror: false, componentClass: Wire.self),

        
        (x: 5, y: 1, rotate: 0, isMirror: false, componentClass: PowerOutlet.self)
    ],
    
    // 第二关
    "level2": [
        (x: 8, y: 3, rotate: 0, isMirror: false, componentClass: Wire.self),
        (x: 4, y: 1, rotate: 270, isMirror: false, componentClass: Wire.self),
        (x: 4, y: 5, rotate: 270, isMirror: false, componentClass: Wire.self),
        (x: 5, y: 1, rotate: 270, isMirror: false, componentClass: Wire.self),
        (x: 5, y: 5, rotate: 270, isMirror: false, componentClass: Wire.self),
        (x: 8, y: 2, rotate: 0, isMirror: false, componentClass: Wire.self),
        (x: 1, y: 2, rotate: 0, isMirror: false, componentClass: Wire.self),
        (x: 2, y: 3, rotate: 0, isMirror: false, componentClass: Wire.self),
        (x: 3, y: 3, rotate: 0, isMirror: false, componentClass: Wire.self),
        (x: 4, y: 3, rotate: 90, isMirror: false, componentClass: Bridge.self),
        (x: 4, y: 4, rotate: 270, isMirror: false, componentClass: Wire.self),
        (x: 0, y: 3, rotate: 0, isMirror: false, componentClass: PowerSource.self),
        (x: 0, y: 2, rotate: 0, isMirror: false, componentClass: PowerSource.self),
        (x: 9, y: 3, rotate: 0, isMirror: false, componentClass: PowerOutlet.self),
        (x: 9, y: 2, rotate: 0, isMirror: false, componentClass: PowerOutlet.self),
        (x: 4, y: 0, rotate: 0, isMirror: false, componentClass: PowerSource.self),
        (x: 5, y: 0, rotate: 0, isMirror: false, componentClass: PowerSource.self),
        (x: 4, y: 6, rotate: 0, isMirror: false, componentClass: PowerOutlet.self),
        (x: 5, y: 6, rotate: 0, isMirror: false, componentClass: PowerOutlet.self)

 
    ],
        
    // 第三关
    "level3": [
        (x: 5, y: 7, rotate: 0, isMirror: false, componentClass: PowerSource.self),
     (x: 6, y: 1, rotate: 0, isMirror: false, componentClass: PowerOutlet.self),
     (x: 5, y: 4, rotate: 90, isMirror: false, componentClass: Distributor.self),
     (x: 5, y: 3, rotate: 90, isMirror: false, componentClass: Delayer.self),
     (x: 5, y: 1, rotate: 0, isMirror: false, componentClass: Wire.self),
     (x: 4, y: 2, rotate: 0, isMirror: false, componentClass: Wire.self)

    ],

]

// 关卡预设的背景
//let LEVELS_BACKDROP_ENTITIES: [String: [(relativeX: Double, relativeY: Double, relativeWidth: Double, relativeHeight: Double, entityClass: BackdropEntity.Type)]
//] = [
//    "level0":[],
//    "level":[
//        (relativeX: 0.2, relativeY: 0.5, relativeWidth: 0.3, relativeHeight: 0.4, entityClass: BackdropEntity.self)
//    ],
//    "leve2":[
//
//    ],
//    "leve3":[
//
//    ]
//
//]

// 背景依附的元件坐标
let ATTACHED_COMPONENT_POSITIONS:[String:[(x:Int,y:Int)]] = [
    "level0":[],
    "level1":[
        (x:6, y:1)
    ],
    "level2":[
        (x:9,y:3),
        (x:5,y:6)
    ],
    "level3":[
        (x:6,y:7),
        (x:6,y:1)
    ]
]
// 背景检测的元件坐标
let DETECTED_COMPONENT_POSITIONS:[String:[[(x:Int,y:Int)]]] = [
    "level0":[],
    "level1":[
        [(x:5, y:1)]
    ],
    "level2":[
        [(x:4,y:6),(x:5,y:6)],
        [(x:9,y:2),(x:9,y:3)]
    ],
    "level3":[
        [(x:5,y:7)],
        [(x:6,y:1)]
    ]
]

// 背景实体类型列表
let BACKDROP_ENTITIES_LIST: [String:[BackdropEntity.Type]] = [
    "level0":[],
    "level1":[
        Blob.self
    ],
    "level2":[
        PortraitTrafficLight.self,
        LandScapeTrafficLight.self
        
    ],
    "level3":[
        LandScapeTrafficLightOneInput.self,
        CarBackground.self
    ]
]

// 背景图片列表
let BACKGROUND_PIC_LIST: [String: String?] = [
    "level0": nil,
    "level1": nil,
    "level2": "level2_background_pic",
    "level3": "level2_background_pic"
]


//let PANNEL_COLOR = Color(red: 0.85, green: 0.85, blue: 0.85)

let PANNEL_COLOR = Color.white
let PROGRESS_BAR_BACKGROUND_COLOR = Color(red: 0.83, green: 0.94, blue: 0.96)



