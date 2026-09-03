import SpriteKit

final class MarbleNode: SKShapeNode {
    let marbleID: UUID
    var velocity: CGVector = .zero
    var isProtected: Bool = false {
        didSet { updateProtectionRing() }
    }
    var isTargeted: Bool = false {
        didSet { targetRingNode.isHidden = !isTargeted }
    }

    private let ringNode: SKShapeNode
    private let targetRingNode: SKShapeNode

    init(marbleID: UUID, radius: CGFloat, color: SKColor) {
        self.marbleID = marbleID
        self.ringNode = SKShapeNode(circleOfRadius: radius + 4)
        self.targetRingNode = SKShapeNode(circleOfRadius: radius + 7)
        super.init()
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)
        self.fillColor = color
        self.strokeColor = SKColor.white.withAlphaComponent(0.85)
        self.lineWidth = 1.5
        self.glowWidth = 0.5
        self.zPosition = 10

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

        let shadow = SKShapeNode(circleOfRadius: radius)
        shadow.fillColor = SKColor.black.withAlphaComponent(0.35)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 2, y: -3)
        shadow.zPosition = -1
        addChild(shadow)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateProtectionRing() {
        ringNode.isHidden = !isProtected
    }

    var currentSpeed: CGFloat {
        sqrt(velocity.dx * velocity.dx + velocity.dy * velocity.dy)
    }
}
