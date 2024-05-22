//
//  File.swift
//  
//
//  Created by rzq on 2024/2/22.
//

import Foundation


class Delayer: Component {
    /*
    输出来自上一tick的输入
    */
    var lastTickStorage: Bool = false  // 上一tick的输入状态存储
    var nowTickStorage: Bool = false  // 当前tick的输入状态存储
    var _electricImageName: String!  // 上一tick有电状态的图片
    var _electricActivedImageName: String!  // 上一tick有电状态的图片
    var _electricSelectedImageName: String!  // 上一tick有电状态的图片
    override var imageName: String! {
        get {
            if self.lastTickStorage || self.nowTickStorage {
                return self._electricImageName
            }
            return self._imageName
        }
        set(val) {
            return self._imageName = val
        }
    }
    override var activedImageName: String! {
        get {
            if self.lastTickStorage || self.nowTickStorage {
                return self._activedImageName
            }
            return self._activedImageName
        }
        set(val) {
            return self._activedImageName = val
        }
    }
    override var selectedImageName: String! {
        get {
            if self.lastTickStorage || self.nowTickStorage {
                return self._selectedImageName
            }
            return self._selectedImageName
        }
        set(val) {
            return self._selectedImageName = val
        }
    }
    
    override func defineParts() {
        // 上:入 右:出 下:入 左:入
        inputPartList = [
            ComponentInputPart(ownerComponent: self),
            nil,
            ComponentInputPart(ownerComponent: self),
            ComponentInputPart(ownerComponent: self)
        ]
        outputPartList = [nil, ComponentOutputPart(ownerComponent: self), nil, nil]
        
        _imageName = "component_Delayer"
        _activedImageName = "component_Delayer_actived"
        _selectedImageName = "component_Delayer_selected"
        
        _electricImageName = "component_Delayer_stored"
        _electricActivedImageName = "component_Delayer_actived_stored"
        _electricSelectedImageName = "component_Delayer_selected_stored"
        
        presentation1ImageName = "component_Delayer_presentation1"
        presentation2ImageName = "component_Delayer_presentation2"
        
        descForTopPic = "The delayer will always delay the input level until the next moment and output it at the output end."
        descForPresentation1 = "Now it receives a high-level voltage"
        descForPresentation2 = "It will output a high level at the next clock cycle."
        
    }

    override func getOutputPartsActivation(inputPartsActivation: [Bool]) -> ([Bool] , Bool)? {
        
        let outputPartsActivation = [false, self.lastTickStorage, false, false]
        let newInputActivation: Bool = inputPartsActivation.contains(true)
        self.nowTickStorage = newInputActivation || self.nowTickStorage
        return nil
    }
    
    override func initRunTimeState() {
        super.initRunTimeState()
        self.nowTickStorage = false
    }
    
    override func initTick0State() {
        super.initRunTimeState()
        self.lastTickStorage = false
    }
    
    func onStart(isActivate: Bool) {
        // delayer 特有的方法, 在ticket开始时被调用
        isActive = isActivate
        for (index, outputPart) in outputPartList.enumerated() {
            print("\(type(of: self)) (\(x), \(y)) 发出信号 \(index)")
            // 发出信号 -> Sending signal
            outputPart?.onOutput(isActiveSignal: isActive)
        }
    }
}
