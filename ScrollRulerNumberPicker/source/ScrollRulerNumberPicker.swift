//
//  ScrollRulerNumberPicker.swift
//  ScrollRulerNumberPicker
//
//  Created by Chen on 2016/11/8.
//  Copyright © 2016年 Chen. All rights reserved.
//

import UIKit

extension String {
    func cy_width(font: UIFont, height: CGFloat) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
        label.numberOfLines = 1
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = self
        label.sizeToFit()
        return label.frame.width
    }
}

protocol ScrollRulerNumberPickerDelegate: class {
    func numberPicker(numberPicker: ScrollRulerNumberPicker, updateValue value: CGFloat)

    func numberPicker(numberPicker: ScrollRulerNumberPicker, textForValue value: CGFloat) -> String
}

enum MinorTicksPerMajorTick: Int {
    case zero = 1
    case two = 2
    case five = 5
}

class ScrollRulerNumberPicker: UIView {

    //private current value
    fileprivate var value: CGFloat = 0

    //current value
    public var pickerValue: CGFloat {
        return self.value
    }

    public var textColor: UIColor = UIColor.black {
        didSet {
            self.setNeedsLayout()
        }
    }

    public var textFont: UIFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            self.setNeedsLayout()
        }
    }

    public var textFontSize: CGFloat = 12 {
        didSet {
            self.setNeedsLayout()
        }
    }

    public var textOffset: CGFloat = 24 {
        didSet {
            self.setNeedsLayout()
        }
    }

    public var redLineWidth: CGFloat = 1.0 {
        didSet {
            self.setNeedsLayout()
        }
    }

    public var redLineLength: CGFloat = 20.0 {
        didSet {
            self.setNeedsLayout()
        }
    }

    public var redLineColor: UIColor = UIColor.red {
        didSet {
            self.setNeedsLayout()
        }
    }

    public var topStraightLineWidth: CGFloat = 1.0 {
        didSet {
            self.setNeedsLayout()
        }
    }

    public var topStraightLineColor: UIColor = UIColor.black {
        didSet {
            self.setNeedsLayout()
        }
    }

    //major
    public var majorTickColor: UIColor = UIColor.black {
        didSet {
            self.setNeedsLayout()
        }
    }

    public var majorTickLength: CGFloat = 15.0 {
        didSet {
            self.setNeedsLayout()
        }
    }

    public var majorTickWidth: CGFloat = 1.0 {
        didSet {
            self.setNeedsLayout()
        }
    }

    //minjor
    public var minorTickColor: UIColor = UIColor.lightGray {
        didSet {
            self.setNeedsLayout()
        }
    }

    public var minorTickLength: CGFloat = 10.0 {
        didSet {
            self.setNeedsLayout()
        }
    }

    public var minorTickWidth: CGFloat = 1.0 {
        didSet {
            self.setNeedsLayout()
        }
    }
 
    public var minorTicksPerMajorTick: MinorTicksPerMajorTick = .five {
        didSet {
            self.setNeedsLayout()
        }
    }
 
    public var minorTickDistance: CGFloat = 15.0 {
        didSet {
            self.setNeedsLayout()
        }
    }

    public var minValue: CGFloat = 0.0 {
        didSet {
            self.setNeedsLayout()
        }
    }

    public var maxValue: CGFloat = 304.0 {
        didSet {
            self.setNeedsLayout()
        }
    }

    public var majorValueStep: CGFloat = 10.0 {
        didSet {
            self.setNeedsLayout()
        }
    }

    private let scrollView = UIScrollView()

    private let redLineLayer = CAShapeLayer()
    private let topStraightLineLayer = CAShapeLayer()
    private let majorLineLayer = CAShapeLayer()
    private let minorLineLayer = CAShapeLayer()

    private let redLinePath = UIBezierPath()
    private let topStraightLinePath = UIBezierPath()
    private let majorLinePath = UIBezierPath()
    private let minorLinePath = UIBezierPath()

    private var textLayers = [CATextLayer]()

    weak var delegate: ScrollRulerNumberPickerDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.white

        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self
        self.addSubview(scrollView)
        self.setLayerLineStyle()
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    private func setLayerLineStyle() {
        redLineLayer.fillColor = UIColor.clear.cgColor
        redLineLayer.strokeColor = redLineColor.cgColor
        redLineLayer.lineCap = kCALineCapSquare
        redLineLayer.lineWidth = redLineWidth

        topStraightLineLayer.fillColor = UIColor.clear.cgColor
        topStraightLineLayer.strokeColor = topStraightLineColor.cgColor
        topStraightLineLayer.lineCap = kCALineCapSquare
        topStraightLineLayer.lineWidth = topStraightLineWidth

        majorLineLayer.fillColor = UIColor.clear.cgColor
        majorLineLayer.strokeColor = majorTickColor.cgColor
        majorLineLayer.lineCap = kCALineCapSquare
        majorLineLayer.lineWidth = majorTickWidth

        minorLineLayer.fillColor = UIColor.clear.cgColor
        minorLineLayer.strokeColor = minorTickColor.cgColor
        minorLineLayer.lineCap = kCALineCapSquare
        minorLineLayer.lineWidth = minorTickWidth
    }

    private func shapeLayer(lineColor: UIColor, lineWidth: CGFloat) -> CAShapeLayer {
        return self.shapeLayer(lineColor: lineColor, lineWidth: lineWidth, lineCap: kCALineCapSquare)
    }

    private func shapeLayer(lineColor: UIColor, lineWidth: CGFloat, lineCap: String) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = lineColor.cgColor
        layer.lineCap = lineCap
        layer.lineWidth = lineWidth
        return layer
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        //reset layer style
        self.setLayerLineStyle()

        //clean path
        self.majorLinePath.removeAllPoints()
        self.minorLinePath.removeAllPoints()
        
        //clean text layers
        if let sublayers = self.majorLineLayer.sublayers {
            for layer in sublayers where layer is CATextLayer {
                layer.removeFromSuperlayer()
            }
        }
        self.textLayers.removeAll()

        //set scroll view frame
        let width = bounds.size.width
        scrollView.frame = self.bounds

        //draw center red line
        redLineLayer.frame = self.bounds

        redLinePath.move(to: CGPoint(x: width / 2.0, y: redLineWidth / 2.0))
        redLinePath.addLine(to: CGPoint(x: width / 2.0, y: redLineWidth / 2.0 + redLineLength))

        redLineLayer.path = redLinePath.cgPath
        self.layer.addSublayer(redLineLayer)

        //calculate scroll content width
        let scrollWidth = width + CGFloat(maxValue - minValue) / majorValueStep * minorTickDistance * CGFloat(self.minorTicksPerMajorTick.rawValue)
        scrollView.contentSize = CGSize(width: scrollWidth, height: bounds.size.height)

        //layer frame
        let frame = CGRect(x: 0, y: 0, width: scrollWidth, height: bounds.size.height)
        topStraightLineLayer.frame = frame
        majorLineLayer.frame = frame
        minorLineLayer.frame = frame

        //draw top strainght line
        topStraightLinePath.move(to: CGPoint(x: 0, y: 0))
        topStraightLinePath.addLine(to: CGPoint(x: scrollWidth, y: 0))

        topStraightLineLayer.path = topStraightLinePath.cgPath

        var start = self.minValue
        while (start <= self.maxValue) {
            //draw major ticks
            let x = width / 2.0 + CGFloat(start - minValue) / majorValueStep * minorTickDistance * CGFloat(self.minorTicksPerMajorTick.rawValue)
            majorLinePath.move(to: CGPoint(x: x, y: topStraightLineWidth / 2.0))
            majorLinePath.addLine(to: CGPoint(x: x, y: topStraightLineWidth / 2.0 + majorTickLength))

            if let text = self.delegate?.numberPicker(numberPicker: self, textForValue: start) {
                let textLayer = CATextLayer()
                textLayer.contentsScale = UIScreen.main.scale
                textLayer.font = textFont
                textLayer.fontSize = textFontSize
                let textWidth = text.cy_width(font: textFont, height: 20)
                textLayer.frame = CGRect(x: x - textWidth / 2.0, y: textOffset, width: textWidth, height: textFontSize)
                textLayer.string = text
                textLayer.alignmentMode = kCAAlignmentCenter
                textLayer.foregroundColor = UIColor.black.cgColor
                majorLineLayer.addSublayer(textLayer)

                self.textLayers.append(textLayer)
            }

            //draw minor ticks
            for i in 0 ..< self.minorTicksPerMajorTick.rawValue {
                if i != 0 {
                    let minorValue = start + CGFloat(i) * majorValueStep / CGFloat(self.minorTicksPerMajorTick.rawValue)
                    if minorValue <= self.maxValue {
                        let minorOffset = x + CGFloat(i) * minorTickDistance
                        minorLinePath.move(to: CGPoint(x: minorOffset, y: topStraightLineWidth / 2.0))
                        minorLinePath.addLine(to: CGPoint(x: minorOffset, y: topStraightLineWidth / 2.0 + minorTickLength))
                    }
                }
            }
            start += self.majorValueStep
        }

        majorLineLayer.path = majorLinePath.cgPath
        minorLineLayer.path = minorLinePath.cgPath

        scrollView.layer.addSublayer(topStraightLineLayer)
        scrollView.layer.addSublayer(majorLineLayer)
        scrollView.layer.addSublayer(minorLineLayer)
    }

    fileprivate func handleOffset(contentOffset: CGPoint) {
        let offsetX = contentOffset.x
        let range = CGFloat(maxValue - minValue) / majorValueStep * minorTickDistance * CGFloat(self.minorTicksPerMajorTick.rawValue)
        if offsetX < 0 {
            if self.value != self.minValue {
                self.value = self.minValue
                self.delegate?.numberPicker(numberPicker: self, updateValue: self.minValue)
            }
            return
        } else if offsetX > range {
            if self.value != self.maxValue {
                self.value = self.maxValue
                self.delegate?.numberPicker(numberPicker: self, updateValue: self.maxValue)
            }
            return
        }

        //let red line match tick
        var sourceValue = offsetX / range * (maxValue - minValue)
        let step = majorValueStep / CGFloat(self.minorTicksPerMajorTick.rawValue)
        let remainder = sourceValue.truncatingRemainder(dividingBy: step)
        if remainder < step / 2.0 {
            sourceValue = sourceValue - remainder
        } else {
            sourceValue = sourceValue - remainder + step
        }

        self.value = sourceValue
        self.delegate?.numberPicker(numberPicker: self, updateValue: self.value)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setPickerValue(value: CGFloat, animated: Bool) {
        let range = CGFloat(maxValue - minValue) / majorValueStep * minorTickDistance * CGFloat(self.minorTicksPerMajorTick.rawValue)
        var offset = value * range / (maxValue - minValue)
        if offset < 0 {
            self.value = self.minValue
            offset = 0
        } else if offset > range {
            self.value = self.maxValue
            offset = range
        }

        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: animated)
    }
}

extension ScrollRulerNumberPicker: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.handleOffset(contentOffset: scrollView.contentOffset)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //while stop Dragging without Decelerating
        if scrollView.isDragging == false {
            self.handleOffset(contentOffset: scrollView.contentOffset)
            self.setPickerValue(value: self.value, animated: true)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.handleOffset(contentOffset: scrollView.contentOffset)
        self.setPickerValue(value: self.value, animated: true)
    }

}
