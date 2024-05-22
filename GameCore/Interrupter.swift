//
//  File.swift
//  
//
//  Created by rzq on 2024/2/13.
//

import Foundation


class Interrupter: Component {
    /*
    上下两端连通，但当左右两端接收到高电平信号，会让上端强制输出低电平
    */
    override func defineParts() {
        // 上:入 右:出 下:入 左:入
        inputPartList = [
            ComponentInputPart(ownerComponent: self),
            nil,
            ComponentInputPart(ownerComponent: self),
            ComponentInputPart(ownerComponent: self)
        ]
        outputPartList = [nil, ComponentOutputPart(ownerComponent: self), nil, nil]
        imageName = "component_Interrupter"
        activedImageName = "component_Interrupter_actived"
        selectedImageName = "component_Interrupter_selected"
        
        presentation1ImageName = "component_Interrupter_presentation1"
        presentation2ImageName = "component_Interrupter_presentation2"
        
        descForTopPic = "The Interrupter will attempt to interrupt the current from the main input port when either input of the two sides is at a high logic level."
        descForPresentation1 = "The deputy input port is at a low level, and it won't block the current from the main input port."
        descForPresentation2 = "The deputy input port is at a high level, which will block the current from the main input port."
    }

    override func getOutputPartsActivation(inputPartsActivation: [Bool]) -> ([Bool] , Bool) {
        let outputPartsActivation = [false, inputPartsActivation[3] && !inputPartsActivation[0] && !inputPartsActivation[2], false, false]
        return (outputPartsActivation, outputPartsActivation.contains(true))
    }
}
