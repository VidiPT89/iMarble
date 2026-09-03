import SpriteKit
import UIKit

final class MarbleNode: SKShapeNode {
    let marbleID: UUID
    let radius: CGFloat
    var velocity: CGVector = .zero
    var isProtected: Bool = false {
        didSet { updateProtectionRing() }
    }
    var isTargeted: Bool = false {
        didSet { targetRingNode.isHidden = !isTargeted }
    }
    var isReadyToLaunch: Bool = false {
        didSet { updateReadyRing() }
    }

    private let ringNode: SKShapeNode
    private let targetRingNode: SKShapeNode
    private let readyRingNode: SKShapeNode
    private let glassNode: SKSpriteNode
    private var reduceMotion = false

    init(marbleID: UUID, radius: CGFloat, color: SKColor) {
        self.marbleID = marbleID
        self.radius = radius
        self.ringNode = SKShapeNode(circleOfRadius: radius + 4)
        self.targetRingNode = SKShapeNode(circleOfRadius: radius + 7)
        self.readyRingNode = SKShapeNode(circleOfRadius: radius + 10)
        self.glassNode = SKSpriteNode(texture: MarbleNode.texture(for: color, radius: radius))
        super.init()
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)
        self.fillColor = .clear
        self.strokeColor = .clear
        self.lineWidth = 0
        self.zPosition = 10

        let shadow = SKShapeNode(ellipseOf: CGSize(width: radius * 1.9, height: radius * 0.9))
        shadow.fillColor = SKColor.black.withAlphaComponent(0.32)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 2, y: -radius * 0.85)
        shadow.zPosition = -1
        addChild(shadow)

        glassNode.size = CGSize(width: radius * 2, height: radius * 2)
        glassNode.zPosition = 0
        addChild(glassNode)

        ringNode.strokeColor = SKColor.systemYellow
        ringNode.lineWidth = 2
        ringNode.fillColor = .clear
        ringNode.isHidden = true
        ringNode.zPosition = 9
        addChild(ringNode)

        targetRingNode.strokeColor = SKColor.systemRed
        targetRingNode.lineWidth = 2.5
        targetRingNode.fillColor = .clear
        targetRingNode.isHidden = true
        targetRingNode.zPosition = 11
        addChild(targetRingNode)

        readyRingNode.strokeColor = SKColor.systemGreen
        readyRingNode.lineWidth = 2.5
        readyRingNode.fillColor = .clear
        readyRingNode.isHidden = true
        readyRingNode.zPosition = 8
        addChild(readyRingNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureMotion(reduceMotion: Bool) {
        self.reduceMotion = reduceMotion
        if isProtected {
            updateProtectionRing()
        }
        if isReadyToLaunch {
            updateReadyRing()
        }
    }

    private func updateReadyRing() {
        readyRingNode.removeAllActions()
        readyRingNode.isHidden = !isReadyToLaunch
        readyRingNode.alpha = 1
        readyRingNode.setScale(1)
        guard isReadyToLaunch, !reduceMotion else { return }
        let pulse = SKAction.sequence([
            .group([.scale(to: 1.15, duration: 0.6), .fadeAlpha(to: 0.4, duration: 0.6)]),
            .group([.scale(to: 1.0, duration: 0.6), .fadeAlpha(to: 1.0, duration: 0.6)]),
        ])
        readyRingNode.run(.repeatForever(pulse))
    }

    private func updateProtectionRing() {
        ringNode.removeAllActions()
        ringNode.isHidden = !isProtected
        ringNode.alpha = 1
        ringNode.setScale(1)
        guard isProtected, !reduceMotion else { return }
        let pulse = SKAction.sequence([
            .group([.scale(to: 1.12, duration: 0.9), .fadeAlpha(to: 0.45, duration: 0.9)]),
            .group([.scale(to: 1.0, duration: 0.9), .fadeAlpha(to: 1.0, duration: 0.9)]),
        ])
        ringNode.run(.repeatForever(pulse))
    }

    var currentSpeed: CGFloat {
        sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
    }

    private static var textureCache: [String: SKTexture] = [:]

    private static func texture(for color: SKColor, radius: CGFloat) -> SKTexture {
        let key = "\(color.hashValue)-\(radius)"
        if let cached = textureCache[key] {
            return cached
        }
        let diameter = radius * 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        let image = renderer.image { context in
            let cg = context.cgContext
            let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            color.getRed(&r, green: &g, blue: &b, alpha: &a)

            cg.saveGState()
            cg.addEllipse(in: rect)
            cg.clip()

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let baseColors = [
                UIColor(red: min(r + 0.35, 1), green: min(g + 0.35, 1), blue: min(b + 0.35, 1), alpha: 1).cgColor,
                UIColor(red: r, green: g, blue: b, alpha: 1).cgColor,
                UIColor(red: r * 0.45, green: g * 0.45, blue: b * 0.45, alpha: 1).cgColor,
            ]
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: baseColors as CFArray, locations: [0, 0.55, 1]) {
                cg.drawRadialGradient(
                    gradient,
                    startCenter: CGPoint(x: diameter * 0.38, y: diameter * 0.62),
                    startRadius: 0,
                    endCenter: CGPoint(x: diameter * 0.5, y: diameter * 0.5),
                    endRadius: diameter * 0.62,
                    options: []
                )
            }
            cg.restoreGState()

            cg.saveGState()
            cg.addEllipse(in: rect)
            cg.clip()
            let highlightColors = [
                UIColor.white.withAlphaComponent(0.85).cgColor,
                UIColor.white.withAlphaComponent(0.0).cgColor,
            ]
            if let highlight = CGGradient(colorsSpace: colorSpace, colors: highlightColors as CFArray, locations: [0, 1]) {
                cg.drawRadialGradient(
                    highlight,
                    startCenter: CGPoint(x: diameter * 0.32, y: diameter * 0.72),
                    startRadius: 0,
                    endCenter: CGPoint(x: diameter * 0.32, y: diameter * 0.72),
                    endRadius: diameter * 0.22,
                    options: []
                )
            }
            cg.restoreGState()

            cg.setStrokeColor(UIColor.white.withAlphaComponent(0.5).cgColor)
            cg.setLineWidth(1.2)
            cg.strokeEllipse(in: rect.insetBy(dx: 0.8, dy: 0.8))
        }
        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        textureCache[key] = texture
        return texture
    }
}
