//
//  File.swift
//  project1
//
//  Created by rzq on 2024/2/25.
//

import Foundation
import SwiftUI


protocol ComponentViews: View {
    var x: CGFloat { get set }
    var y: CGFloat { get set }
    var width: CGFloat { get set }
    var height: CGFloat { get set }
    var isSelected: Bool { get set }
    static var componentType: Component.Type { get set }
    
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, isSelected: Bool)
}


struct PowerSourceView: ComponentViews {
    
    var x: CGFloat
    
    var y: CGFloat
    
    var width: CGFloat
    
    var height: CGFloat
    
    var isSelected: Bool
    
    static var componentType: Component.Type = PowerSource.self
    
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, isSelected: Bool) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.isSelected = isSelected
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Image(self.isSelected ? "component_PowerSource_selected" : "component_PowerSource" )
                .resizable() // 使图片可伸缩
                .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
//                    .frame(width: width, height: height)
        }
//            .position(
//                x: x + width/2,
//                y: y + height/2
//            )

    }
}


struct WireView: ComponentViews {
    
    var width: CGFloat
    
    var height: CGFloat
    
    var isSelected: Bool
    
    var y: CGFloat
    
    var x: CGFloat
        
    static var componentType: Component.Type = Wire.self

    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, isSelected: Bool) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.isSelected = isSelected
        
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Image(self.isSelected ? "component_Wire_selected" : "component_Wire" )
                .resizable() // 使图片可伸缩
                .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
//                    .frame(width: width, height: height)
        }
//            .position(
//                x: x + width/2,
//                y: y + height/2
//            )

    }
}

struct DistributorView: ComponentViews {
    
    var width: CGFloat
    
    var height: CGFloat
    
    var isSelected: Bool
    
    var y: CGFloat
    
    var x: CGFloat
        
    static var componentType: Component.Type = Distributor.self

    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, isSelected: Bool) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.isSelected = isSelected
        
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Image(self.isSelected ? "component_Distributor_selected" : "component_Distributor" )
                .resizable() // 使图片可伸缩
                .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
//                    .frame(width: width, height: height)
        }
//            .position(
//                x: x + width/2,
//                y: y + height/2
//            )

    }
}

struct BridgeView: ComponentViews {
    
    var width: CGFloat
    
    var height: CGFloat
    
    var isSelected: Bool
    
    var y: CGFloat
    
    var x: CGFloat
        
    static var componentType: Component.Type = Bridge.self

    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, isSelected: Bool) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.isSelected = isSelected
        
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Image(self.isSelected ? "component_Bridge_selected" : "component_Bridge" )
                .resizable() // 使图片可伸缩
                .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
//                    .frame(width: width, height: height)
        }
//            .position(
//                x: x + width/2,
//                y: y + height/2
//            )

    }
}

struct PowerOutletView: ComponentViews {
    
    var width: CGFloat
    
    var height: CGFloat
    
    var isSelected: Bool
    
    var y: CGFloat
    
    var x: CGFloat
    
    static var componentType: Component.Type = PowerOutlet.self // <--
    
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, isSelected: Bool) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.isSelected = isSelected
        
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Image(self.isSelected ? "component_PowerOutlet_selected" : "component_PowerOutlet" )  // <--
                .resizable() // 使图片可伸缩
                .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
            
        }
    }
    
    
    
    
    
}
struct InterrupterView: ComponentViews {
    
    var width: CGFloat
    
    var height: CGFloat
    
    var isSelected: Bool
    
    var y: CGFloat
    
    var x: CGFloat
    
    static var componentType: Component.Type = Interrupter.self // <--
    
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, isSelected: Bool) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.isSelected = isSelected
        
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Image(self.isSelected ? "component_Interrupter_selected" : "component_Interrupter" )  // <--
                .resizable() // 使图片可伸缩
                .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
        }
        
        
        
    }
    
    }
struct DelayerView: ComponentViews {
    
    var width: CGFloat
    
    var height: CGFloat
    
    var isSelected: Bool
    
    var y: CGFloat
    
    var x: CGFloat
    
    
    
    static var componentType: Component.Type = Delayer.self // <--
    
    init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, isSelected: Bool) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.isSelected = isSelected
        
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Image(self.isSelected ? "component_Delayer_selected" : "component_Delayer" )  // <--
                .resizable() // 使图片可伸缩
                .aspectRatio(contentMode: .fit) // 等比缩放，整个图片都能被显示，不会被裁剪
        }
        
        
    }
    }
