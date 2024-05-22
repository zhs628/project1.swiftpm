//
//  File.swift
//  
//
//  Created by rzq on 2024/2/13.
//

import Foundation
import SpriteKit


class PowerSource: Component {
    override func defineParts() {
        // 上:出 右:出 下:出 左:出
        inputPartList = [nil, nil, nil, nil]
        outputPartList = [ComponentOutputPart(ownerComponent: self), ComponentOutputPart(ownerComponent: self), ComponentOutputPart(ownerComponent: self), ComponentOutputPart(ownerComponent: self)]
        imageName = "component_PowerSource"
        activedImageName = "component_PowerSource_actived"
        selectedImageName = "component_PowerSource_selected"
        
        presentation1ImageName = "component_PowerSource_presentation1"
        presentation2ImageName = "component_PowerSource_presentation2"
        
        descForTopPic = "The power given for each level will emit a high or low voltage at every clock tick according to the level settings."
        descForPresentation1 = "Low voltage"
        descForPresentation2 = "High voltage"
    }

    override func getOutputPartsActivation(inputPartsActivation: [Bool]) -> ([Bool], Bool) {
        return ([true, true, true, true], true)
    }

    func onStart(isActivate: Bool) {
        // PowerSource 特有的方法, 在ticket开始时被调用
        isActive = isActivate
        for (index, outputPart) in outputPartList.enumerated() {
            print("\(type(of: self)) (\(x), \(y)) 发出信号 \(index)")
            // 发出信号 -> Sending signal
            outputPart?.onOutput(isActiveSignal: isActive)
        }
    }
}
