//
//  File.swift
//  
//
//  Created by rzq on 2024/2/14.
//

import Foundation
import SpriteKit

class PowerOutlet: Component {
    /*
    关卡的输出口
    */
    
    var exceptedSignal: Bool! = nil
    

    
    override func defineParts() {
        // 上:入 右:入 下:入 左:入
        inputPartList = [ComponentInputPart(ownerComponent: self), ComponentInputPart(ownerComponent: self), ComponentInputPart(ownerComponent: self), ComponentInputPart(ownerComponent: self)]
        outputPartList = [nil, nil, nil, nil]
        imageName = "component_PowerOutlet"
        activedImageName = "component_PowerOutlet_actived"
        selectedImageName = "component_PowerOutlet_selected"
        
        presentation1ImageName = "component_PowerOutlet_presentation1"
        presentation2ImageName = "component_PowerOutlet_presentation2"
        
        descForTopPic = "For each level, the given power outlet will verify at each time interval whether the received voltage level meets the design requirements."
        descForPresentation1 = "Expect to receive a high-level voltage"
        descForPresentation2 = "Expect to receive a low-level voltage"
    }

    override func getOutputPartsActivation(inputPartsActivation: [Bool]) -> ([Bool] , Bool) {
        let outputPartsActivation = [false, false, false, false]
        return (outputPartsActivation, inputPartsActivation.contains(true) || self.isActive)
    }
    
    override func initRunTimeState() {
        super.initRunTimeState()
        self.exceptedSignal = nil
    }
    

    
}

