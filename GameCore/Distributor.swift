//
//  File.swift
//  
//
//  Created by rzq on 2024/2/6.
//

import Foundation


class Distributor: Component {

    override func defineParts() {
        // 上:出 右:出 下:出 左:入
        inputPartList = [
            nil,
            nil,
            nil,
            ComponentInputPart(ownerComponent: self)
        ]
        outputPartList = [ComponentOutputPart(ownerComponent: self), ComponentOutputPart(ownerComponent: self), ComponentOutputPart(ownerComponent: self), nil]
        imageName = "component_Distributor"
        activedImageName = "component_Distributor_actived"
        selectedImageName = "component_Distributor_selected"
        
        presentation1ImageName = "component_Distributor_presentation1"
        presentation2ImageName = "component_Distributor_presentation2"
        
        descForTopPic = "The distributor will output the levels input from the one end simultaneously at three output ends."
        descForPresentation1 = "Low voltage input"
        descForPresentation2 = "High voltage input"
    }

    override func getOutputPartsActivation(inputPartsActivation: [Bool]) -> ([Bool] , Bool) {
        var outputPartsActivation: [Bool]
        if inputPartsActivation.contains(true) {
            outputPartsActivation = [true, true, true, false]
        } else {
            outputPartsActivation =  [false, false, false, false]
        }
        return (outputPartsActivation, outputPartsActivation.contains(true))
    }

}
