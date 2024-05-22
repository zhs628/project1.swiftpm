//
//  File.swift
//  
//
//  Created by rzq on 2024/2/13.
//

import Foundation


class Wire: Component {
    override func defineParts() {
        // 上:入 右:出 下:入 左:入
        inputPartList = [
            ComponentInputPart(ownerComponent: self),
            nil,
            ComponentInputPart(ownerComponent: self),
            ComponentInputPart(ownerComponent: self)
        ]
        outputPartList = [nil, ComponentOutputPart(ownerComponent: self), nil, nil]
        imageName = "component_Wire"
        activedImageName = "component_Wire_actived"
        selectedImageName = "component_Wire_selected"
        presentation1ImageName = "component_Wire_presentation1"
        presentation2ImageName = "component_Wire_presentation2"
        
        descForTopPic = "Outputs the input voltage level at its unique end."
        descForPresentation1 = "Low voltage input"
        descForPresentation2 = "High voltage input"
    }

    override func getOutputPartsActivation(inputPartsActivation: [Bool]) -> ([Bool] , Bool) {
        
        var outputPartsActivation: [Bool]
        if inputPartsActivation.contains(true) {
            outputPartsActivation = [false, true, false, false]
        } else {
            outputPartsActivation = [false, false, false, false]
        }
        return (outputPartsActivation, outputPartsActivation.contains(true))
        
    }
}
