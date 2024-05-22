//
//  File.swift
//  
//
//  Created by rzq on 2024/2/13.
//

import Foundation


class Bridge: Component {
    // 上下两端和左右两端各自连通，互不影响
    
    override func defineParts() {
        // 上:出 右:入 下:入 左:出
        inputPartList = [
            nil,
            ComponentInputPart(ownerComponent: self),
            ComponentInputPart(ownerComponent: self),
            nil
        ]
        outputPartList = [ComponentOutputPart(ownerComponent: self), nil, nil, ComponentOutputPart(ownerComponent: self)]
        imageName = "component_Bridge"
        activedImageName = "component_Bridge_actived"
        selectedImageName = "component_Bridge_selected"
        presentation1ImageName = "component_Bridge_presentation1"
        presentation2ImageName = "component_Bridge_presentation2"
        
        descForTopPic = "The bridge will output the voltage levels from the two input terminals to the opposite side at its output terminals."
        descForPresentation1 = ""
        descForPresentation2 = ""
    }

    override func getOutputPartsActivation(inputPartsActivation: [Bool]) -> ([Bool], Bool) {
        let outputPartsActivation = [inputPartsActivation[2],
                                    false,
                                    false,
                                    inputPartsActivation[1]]
        return (outputPartsActivation, outputPartsActivation.contains(true))
    }
    
    
}
