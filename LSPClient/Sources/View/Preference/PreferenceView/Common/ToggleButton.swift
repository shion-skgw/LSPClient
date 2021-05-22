//
//  ToggleButton.swift
//  LSPClient
//
//  Created by Shion on 2021/03/20.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class ToggleButton: UIControl {

    weak var titleLabel: UILabel!
    private weak var baseLayer: ToggleButtonShape!
    private weak var selectLayer: ToggleButtonShape!

    private let buttonSize: CGSize = CGSize(width: 28, height: 28)

    override var isSelected: Bool {
        didSet {
            if self.isSelected == oldValue {
                return
            }
            self.baseLayer.color = self.baseColor
            self.selectLayer.color = self.selectColor
        }
    }

    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted == oldValue {
                return
            }
            self.baseLayer.color = self.baseColor
        }
    }

    private var baseColor: CGColor {
        switch (self.isSelected, self.isHighlighted) {
        case (false, false): return UIColor.opaqueSeparator.cgColor
        case (_, _): return UIColor.systemBlue.cgColor
        }
    }

    private var selectColor: CGColor {
        switch (self.isSelected) {
        case (false): return UIColor.clear.cgColor
        case (true): return UIColor.white.cgColor
        }
    }

    init(frame: CGRect, style: Style) {
        super.init(frame: frame)

        var layerFrame = CGRect(origin: .zero, size: buttonSize)
        layerFrame.origin.y = frame.height.centeringPoint(buttonSize.height)

        let baseLayer: ToggleButtonShape = style == .radio ? RadioBase(frame: layerFrame) : CheckBoxBase(frame: layerFrame)
        baseLayer.color = baseColor
        self.layer.addSublayer(baseLayer)
        self.baseLayer = baseLayer

        let selectLayer: ToggleButtonShape = style == .radio ? RadioSelect(frame: layerFrame) : CheckBoxSelect(frame: layerFrame)
        selectLayer.color = selectColor
        self.layer.addSublayer(selectLayer)
        self.selectLayer = selectLayer

        var titleLabelFrame = CGRect(origin: .zero, size: frame.size)
        titleLabelFrame.origin.x = layerFrame.maxX + 8
        titleLabelFrame.size.width -= titleLabelFrame.minX

        let titleLabel = UILabel(frame: titleLabelFrame)
        self.addSubview(titleLabel)
        self.titleLabel = titleLabel

        self.addAction(UIAction(handler: { _ in self.isSelected.toggle() }), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        var titleLabelFrame = titleLabel.frame
        titleLabelFrame.size.width = frame.width
        titleLabelFrame.size.width -= titleLabelFrame.minX
        titleLabel.frame = titleLabelFrame
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard !self.isHidden, self.isEnabled, self.isUserInteractionEnabled else {
            return false
        }

        var hitArea = baseLayer.frame
        hitArea.size.width *= 1.6
        hitArea.size.height *= 1.6
        hitArea.origin.x += baseLayer.frame.width.centeringPoint(hitArea.width)
        hitArea.origin.y += baseLayer.frame.height.centeringPoint(hitArea.height)
        return hitArea.contains(point)
    }

}

extension ToggleButton {

    enum Style {
        case radio
        case check
    }

}

private protocol ToggleButtonShape: CAShapeLayer {
    var color: CGColor? { get set }
}

private final class RadioBase: CAShapeLayer, ToggleButtonShape {

    private let size: CGSize = CGSize(width: 28, height: 28)

    var color: CGColor? {
        get {
            return self.fillColor
        }
        set {
            self.fillColor = newValue
        }
    }

    init(frame: CGRect) {
        super.init()

        self.frame = frame

        var circleRect = CGRect(origin: .zero, size: size)
        circleRect.origin.x = frame.width.centeringPoint(size.width)
        circleRect.origin.y = frame.height.centeringPoint(size.height)
        self.path = UIBezierPath(ovalIn: circleRect).cgPath
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private final class RadioSelect: CAShapeLayer, ToggleButtonShape {

    private let size: CGSize = CGSize(width: 12, height: 12)

    var color: CGColor? {
        get {
            return self.fillColor
        }
        set {
            self.fillColor = newValue
        }
    }

    init(frame: CGRect) {
        super.init()

        self.frame = frame

        var circleRect = CGRect(origin: .zero, size: size)
        circleRect.origin.x = frame.width.centeringPoint(size.width)
        circleRect.origin.y = frame.height.centeringPoint(size.height)
        self.path = UIBezierPath(ovalIn: circleRect).cgPath

        self.shadowColor = UIColor.black.cgColor
        self.shadowRadius = 1
        self.shadowOffset = CGSize(width: .zero, height: 1)
        self.shadowOpacity = 1.0 / 3
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private final class CheckBoxBase: CAShapeLayer, ToggleButtonShape {

    private let size: CGSize = CGSize(width: 24, height: 24)

    var color: CGColor? {
        get {
            return self.fillColor
        }
        set {
            self.fillColor = newValue
        }
    }

    init(frame: CGRect) {
        super.init()

        self.frame = frame

        var boxRect = CGRect(origin: .zero, size: size)
        boxRect.origin.x = frame.width.centeringPoint(size.width)
        boxRect.origin.y = frame.height.centeringPoint(size.height)
        self.path = UIBezierPath(roundedRect: boxRect, cornerRadius: 4).cgPath
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private final class CheckBoxSelect: CAShapeLayer, ToggleButtonShape {

    private let size: CGSize = CGSize(width: 24, height: 24)

    var color: CGColor? {
        get {
            return self.strokeColor
        }
        set {
            self.strokeColor = newValue
        }
    }

    init(frame: CGRect) {
        super.init()

        self.frame = frame

        let check = UIBezierPath()
        check.move(to: CGPoint(x: 6, y: 14))
        check.addLine(to: CGPoint(x: 11.5, y: 20.5))
        check.addLine(to: CGPoint(x: 21, y: 7))
        self.path = check.cgPath

        self.lineWidth = 3
        self.fillColor = UIColor.clear.cgColor

        self.shadowColor = UIColor.black.cgColor
        self.shadowRadius = 1
        self.shadowOffset = CGSize(width: .zero, height: 1)
        self.shadowOpacity = 1.0 / 3
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
