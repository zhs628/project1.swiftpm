import Foundation
import SpriteKit
import SwiftUI

/// by: rzq
/// ## 绘制水平和垂直的参考线
/// ```
/// GridLinesView 使用方法：
///    实例化 GridLinesView 即可：
///
///    GridLinesView(
///        xProportion:  [Float],  // 垂直参考线的位置，取值 0～1 之间
///        yProportion:  [Float],  // 水平参考线的位置，取值 0～1 之间
///        isShow:       Bool   ,  // 隐藏/显示参考线
///        screenWidth:  CGFloat,  // 总宽度
///        screenHeight: CGFloat,  // 总高度
///        fontSize:     CGFloat,  //（可选）字体大小，默认 30
///        lineWidth:    CGFloat,  //（可选）线宽，默认 2
///    )
///
/// 参考线旁边显示的数字代表这是第几根参考线
/// ```
struct GridLinesView: View {
    
    let xProportion: [Float]
    let yProportion: [Float]
    
    let isShow: Bool

    let screenWidth: CGFloat
    let screenHeight: CGFloat
    
    let fontSize: CGFloat = 30
    let lineWidth: CGFloat = 2
        
    private var xCoordinates: [CGFloat] {
        xProportion.map { CGFloat($0) * screenWidth }
    }
    private var yCoordinates: [CGFloat] {
        yProportion.map { CGFloat($0) * screenHeight }
    }
    
    var body: some View {
        ZStack {
            if isShow {
                Canvas { context, size in
                    for x in xCoordinates {
                        let path = Path { path in
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: size.height))
                        }
                        context.stroke(path, with: .color(.red), lineWidth: lineWidth)
                    }
                }
                ForEach(Array(xCoordinates.filter { $0 < 1*screenWidth }.enumerated()), id: \.1) { index, x in
                    Text("\(xCoordinates.firstIndex(of: CGFloat(x))! )")
                        .position(x: x + fontSize/2, y: fontSize/2*CGFloat(index+1))
                        .font(.system(size: fontSize))
                        .foregroundColor(.red)
                }
                
                Canvas { context, size in
                    for y in yCoordinates {
                        let path = Path { path in
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: size.width, y: y))
                        }
                        context.stroke(path, with: .color(.blue), lineWidth: lineWidth)
                    }
                }
                ForEach(Array(yCoordinates.filter { $0 < 1*screenHeight }.enumerated()), id: \.1) { index, y in
                    Text("\(yCoordinates.firstIndex(of: CGFloat(y))! )")
                        .position(x: fontSize/2*CGFloat(index+1)*3, y: y + fontSize/2)
                        .font(.system(size: fontSize))
                        .foregroundColor(.blue)
                }
            }
        }
        .background(Color.gray)
        .opacity(0.6)
    }
}


// 绘制一个可分别定义四个圆角的矩形
struct RoundedCorners: View {
    var color: Color = .blue
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
 
    var body: some View {
        GeometryReader { geometry in
            Path { path in
 
                let w = geometry.size.width
                let h = geometry.size.height
 
                // Make sure we do not exceed the size of the rectangle
                let tr = min(min(self.tr, h/2), w/2)
                let tl = min(min(self.tl, h/2), w/2)
                let bl = min(min(self.bl, h/2), w/2)
                let br = min(min(self.br, h/2), w/2)
 
                path.move(to: CGPoint(x: w / 2.0, y: 0))
                path.addLine(to: CGPoint(x: w - tr, y: 0))
                path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                path.addLine(to: CGPoint(x: w, y: h - br))
                path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                path.addLine(to: CGPoint(x: bl, y: h))
                path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                path.addLine(to: CGPoint(x: 0, y: tl))
                path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
            }
            .fill(self.color)
        }
    }
}


class SquareFrame {
    var minX: CGFloat
    var minY: CGFloat
    var sideLength: CGFloat
    
    var maxX: CGFloat {
        return minX + sideLength
    }
    
    var maxY: CGFloat {
        return minY + sideLength
    }
    
    var centerX: CGFloat {
        return minX + sideLength / 2
    }
    
    var centerY: CGFloat {
        return minY + sideLength / 2
    }
    
    init(minX: CGFloat, minY: CGFloat, sideLength: CGFloat) {
        self.minX = minX
        self.minY = minY
        self.sideLength = sideLength
    }
    
    func contains(point: (x: CGFloat, y: CGFloat)) -> Bool {
        return point.x >= minX && point.x < maxX && point.y >= minY && point.y < maxY
    }
}

class GridFrame {
    var squares: [[SquareFrame]] = []
    var minX: CGFloat
    var minY: CGFloat
    var sideLength: CGFloat
    var spacing: CGFloat
    var nRows: Int {
        return squares.count
    }
    
    var nCols: Int {
        guard let firstRow = squares.first else {
            return 0
        }
        return firstRow.count
    }
    var width: CGFloat {
        return CGFloat(nCols) * (sideLength + spacing) - spacing
    }
    
    var height: CGFloat {
        return CGFloat(nRows) * (sideLength + spacing) - spacing
    }
    
    var centerX: CGFloat {
        return minX + CGFloat(nCols) * (sideLength + spacing) / 2.0
    }
    
    var centerY: CGFloat {
        return minY + CGFloat(nRows) * (sideLength + spacing) / 2.0
    }
    
    
    init(nCols: Int, nRows: Int, sideLength: CGFloat, spacing: CGFloat, minX: CGFloat, minY: CGFloat) {
        self.sideLength = sideLength
        self.spacing = spacing
        self.minX = minX
        self.minY = minY
        
        
        self.createSquares(nCols: nCols, nRows: nRows, sideLength: sideLength, spacing: spacing, minX: minX, minY: minY)

    }
    
    init(nCols: Int, nRows: Int, sideLength: CGFloat, spacing: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        self.sideLength = sideLength
        self.spacing = spacing
        
        let _minX = centerX - CGFloat(nCols) * (sideLength + spacing) / 2.0
        let _minY = centerY - CGFloat(nRows) * (sideLength + spacing) / 2.0
        
        self.minX = _minX
        self.minY = _minY
        
        self.createSquares(nCols: nCols, nRows: nRows, sideLength: sideLength, spacing: spacing, minX: _minX, minY: _minY)
    }
    
    
    private func createSquares(nCols: Int, nRows: Int, sideLength: CGFloat, spacing: CGFloat, minX: CGFloat, minY: CGFloat) {
        var currentX = minX
        var currentY = minY
        
        for _ in 0..<nRows {
            var line: [SquareFrame] = []
            for _ in 0..<nCols {
                line.append(SquareFrame(minX: currentX, minY: currentY, sideLength: sideLength))
                currentX += sideLength + spacing
            }
            currentX = minX
            currentY += sideLength + spacing
            self.squares.append(line)
        }
    }
    
    func getIntPos(x: CGFloat, y: CGFloat) -> (x: Int, y: Int)? {
        for row in 0..<squares.count {
            for col in 0..<squares[row].count {
                let square = squares[row][col]
                if CGFloat(square.minX) <= x && x < CGFloat(square.maxX) && CGFloat(square.minY) <= y && y < CGFloat(square.maxY) {
                    return (x: col, y: row)
                }
            }
        }
        return nil
    }
    
    func getFloatPos(x: Int, y: Int) -> (x: CGFloat, y: CGFloat) {
        let square = squares[y][x]
        let floatX = CGFloat(square.minX)
        let floatY = CGFloat(square.minY)
        return (x: floatX, y: floatY)
    }
    
    func selectSquare(x: Int, y: Int) -> SquareFrame? {
        let (x,y) = self.getFloatPos(x: x, y: y)
        return self.selectSquare(x: x, y: y)
    }
    
    func selectSquare(x: CGFloat, y: CGFloat) -> SquareFrame? {
        for row in 0..<squares.count {
            for col in 0..<squares[row].count {
                let square = squares[row][col]
                if CGFloat(square.minX) <= x && x < CGFloat(square.maxX) && CGFloat(square.minY) <= y && y < CGFloat(square.maxY) {
                    return square
                }
            }
        }
        return nil
    }
    
    func iterateSquares(_ closure: (SquareFrame) -> Void) {
        for row in 0..<nRows {
            for col in 0..<nCols {
                let square = squares[row][col]
                closure(square)
            }
        }
    }
    
}


class RecurringActionUpdater<T> {
    var lastTime: TimeInterval = 0
    let executeTimeInterval: [TimeInterval]
    var executionCount: Int = 0
    let action: ((Int) -> T)?
    
    init(executeTimeInterval: [TimeInterval], action: ((Int) -> T)? = nil) {
        self.executeTimeInterval = executeTimeInterval
        self.action = action
    }
    
    func tryToExecute() -> (hasActived: Bool, result:T?){
        let currentTime = Date().timeIntervalSince1970
        
        if currentTime - lastTime >= executeTimeInterval[0] {
            lastTime = currentTime
            let res = self.action?(executionCount)
            executionCount += 1
            return (hasActived:true, result:res)
        }
        else {
            return (hasActived:true, result:nil)
        }
    }
}


func rotateArray<T>(_ array: [T], by positions: Int) -> [T] {
    // 返回array中元素向右移动position个位置后的副本
    guard array.count > 1 else {
        return array
    }
    
    let newPositions = -positions
    
    let positionsNormalized = newPositions >= 0 ? newPositions : array.count + newPositions
    let offset = positionsNormalized % array.count
    
    if offset == 0 {
        return array
    }
    let slice1 = array[offset...]
    let slice2 = array[..<offset]
    return Array(slice1) + Array(slice2)
}


func pairingConvertToTupleArray<T>(_ array: [T]) -> [(left:T, right:T?)] {
    var result: [(left:T, right:T?)] = []
    
    for i in stride(from: 0, to: array.count, by: 2) {
        if i + 1 < array.count {
            let pair = (left:array[i], right:array[i+1])
            result.append(pair)
        } else {
            let single:(left:T, right:T?) = (left:array[i], right:nil)
            result.append(single)
        }
    }
    
    return result
}

