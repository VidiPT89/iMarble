import SpriteKit
import UIKit

protocol MarbleSceneDelegate: AnyObject {
    func marbleScene(_ scene: MarbleScene, canLaunch marbleID: UUID) -> Bool
    func marbleScene(_ scene: MarbleScene, isAttackTarget marbleID: UUID) -> Bool
    func marbleScene(_ scene: MarbleScene, didSelectTarget marbleID: UUID)
    func marbleScene(_ scene: MarbleScene, didLaunch marbleID: UUID, dragVector: CGVector)
    func marbleScene(_ scene: MarbleScene, didUpdatePower ratio: Double)
    func marbleScene(_ scene: MarbleScene, marbleDidStop marbleID: UUID, at position: CGPoint)
    func marbleScene(_ scene: MarbleScene, marblesCollided idA: UUID, idB: UUID)
}

final class MarbleScene: SKScene {
    weak var gameDelegate: MarbleSceneDelegate?

    private var marbleNodes: [UUID: MarbleNode] = [:]
    private var holeNodes: [Int: SKShapeNode] = [:]
    private var groundNode: SKSpriteNode?
    private var launchLineNode: SKShapeNode?
    private var draggingMarbleID: UUID?
    private var dragStart: CGPoint = .zero
    private var marbleOriginAtDragStart: CGPoint = .zero
    private var anyMoving = false
    private var aimArrowNode: SKShapeNode?
    private var aimDotNodes: [SKShapeNode] = []
    private var objectiveGlowNode: SKShapeNode?
    private var objectiveHoleNumber: Int?
    var reduceMotion = false {
        didSet {
            for node in marbleNodes.values {
                node.configureMotion(reduceMotion: reduceMotion)
            }
        }
    }

    private static func launchLineSize(for sceneSize: CGSize) -> CGSize {
        sceneSize.height > sceneSize.width
            ? CGSize(width: sceneSize.width * 0.7, height: 2)
            : CGSize(width: 2, height: sceneSize.height * 0.7)
    }

    private static func launchLinePosition(for sceneSize: CGSize) -> CGPoint {
        sceneSize.height > sceneSize.width
            ? CGPoint(x: sceneSize.width / 2, y: sceneSize.height * 0.88)
            : CGPoint(x: sceneSize.width * 0.12, y: sceneSize.height / 2)
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.16, green: 0.10, blue: 0.05, alpha: 1.0)
        physicsWorld.gravity = .zero
        isUserInteractionEnabled = true
    }

    func layoutField(holes: [Hole], sceneSize: CGSize) {
        removeAllChildren()
        marbleNodes.removeAll()
        holeNodes.removeAll()
        size = sceneSize

        let ground = SKSpriteNode(texture: Self.groundTexture())
        ground.size = sceneSize
        ground.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        ground.zPosition = -10
        addChild(ground)
        groundNode = ground

        let launchLine = SKShapeNode(rectOf: Self.launchLineSize(for: sceneSize))
        launchLine.fillColor = SKColor.systemYellow.withAlphaComponent(0.5)
        launchLine.strokeColor = .clear
        launchLine.position = Self.launchLinePosition(for: sceneSize)
        launchLine.zPosition = -5
        addChild(launchLine)
        launchLineNode = launchLine

        for hole in holes {
            let radius = CGFloat(hole.radius)
            let node = SKShapeNode(circleOfRadius: radius)
            node.fillTexture = Self.holeTexture(radius: radius)
            node.fillColor = .white
            node.strokeColor = SKColor(red: 0.95, green: 0.6, blue: 0.1, alpha: 1)
            node.lineWidth = 2
            node.position = hole.position.cgPoint
            node.zPosition = 1
            addChild(node)
            holeNodes[hole.number] = node
        }
    }

    /// Highlights the hole the current player should aim at with a soft
    /// pulsing golden ring; pass nil to clear the highlight.
    func setObjectiveHole(_ number: Int?) {
        guard objectiveHoleNumber != number else { return }
        objectiveHoleNumber = number
        objectiveGlowNode?.removeAllActions()
        objectiveGlowNode?.removeFromParent()
        objectiveGlowNode = nil
        guard let number, let holeNode = holeNodes[number] else { return }
        let radius = holeNode.frame.width / 2
        let glow = SKShapeNode(circleOfRadius: radius + 6)
        glow.strokeColor = SKColor(red: 1.0, green: 0.78, blue: 0.25, alpha: 0.9)
        glow.lineWidth = 3
        glow.fillColor = .clear
        glow.position = holeNode.position
        glow.zPosition = 2
        addChild(glow)
        objectiveGlowNode = glow
        guard !reduceMotion else { return }
        let pulse = SKAction.sequence([
            .group([.scale(to: 1.08, duration: 0.85), .fadeAlpha(to: 0.35, duration: 0.85)]),
            .group([.scale(to: 1.0, duration: 0.85), .fadeAlpha(to: 0.9, duration: 0.85)]),
        ])
        glow.run(.repeatForever(pulse))
    }

    /// Repositions existing field elements (ground, launch line, holes) for a
    /// new scene size without removing marble nodes, preserving in-progress
    /// game state.
    func relayoutField(holes: [Hole], sceneSize: CGSize) {
        size = sceneSize

        groundNode?.size = sceneSize
        groundNode?.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)

        let lineSize = Self.launchLineSize(for: sceneSize)
        launchLineNode?.path = CGPath(rect: CGRect(x: -lineSize.width / 2, y: -lineSize.height / 2, width: lineSize.width, height: lineSize.height), transform: nil)
        launchLineNode?.position = Self.launchLinePosition(for: sceneSize)

        for hole in holes {
            holeNodes[hole.number]?.position = hole.position.cgPoint
        }
    }

    func addMarble(_ marble: Marble, color: SKColor) {
        let node = MarbleNode(marbleID: marble.id, radius: CGFloat(GameRules.marbleRadius), color: color)
        node.position = marble.position.cgPoint
        node.configureMotion(reduceMotion: reduceMotion)
        node.isProtected = marble.isProtected
        addChild(node)
        marbleNodes[marble.id] = node
    }

    func removeMarble(_ id: UUID) {
        marbleNodes[id]?.removeFromParent()
        marbleNodes.removeValue(forKey: id)
    }

    func setProtected(_ id: UUID, protected: Bool) {
        marbleNodes[id]?.isProtected = protected
    }

    func setPosition(_ id: UUID, position: CGPoint) {
        marbleNodes[id]?.position = position
    }

    func clearTargetHighlight() {
        for node in marbleNodes.values {
            node.isTargeted = false
        }
    }

    /// Shows a dashed aim line from the marble in the direction it will fly,
    /// growing and shifting color (yellow → red) with the launch power ratio.
    func updateAimIndicator(origin: CGPoint, direction: CGVector, ratio: CGFloat) {
        let clampedRatio = min(max(ratio, 0), 1)
        let minLength: CGFloat = 34
        let maxLength: CGFloat = 130
        let length = minLength + (maxLength - minLength) * clampedRatio
        let angle = atan2(direction.dy, direction.dx)
        let color = aimColor(for: clampedRatio)

        let dotCount = 6
        if aimDotNodes.count != dotCount || aimDotNodes.contains(where: { $0.parent == nil }) {
            aimDotNodes.forEach { $0.removeFromParent() }
            aimDotNodes = (0..<dotCount).map { _ in
                let dot = SKShapeNode(circleOfRadius: 3)
                dot.strokeColor = .clear
                dot.zPosition = 18
                addChild(dot)
                return dot
            }
        }
        for (index, dot) in aimDotNodes.enumerated() {
            let t = CGFloat(index + 1) / CGFloat(dotCount)
            let distance = length * t
            dot.position = CGPoint(x: origin.x + direction.dx * distance, y: origin.y + direction.dy * distance)
            dot.fillColor = color
            dot.alpha = 0.35 + 0.5 * t
        }

        let tip = CGPoint(x: origin.x + direction.dx * length, y: origin.y + direction.dy * length)
        let arrowSize: CGFloat = 9
        let arrowPath = CGMutablePath()
        arrowPath.move(to: CGPoint(x: arrowSize, y: 0))
        arrowPath.addLine(to: CGPoint(x: -arrowSize * 0.6, y: arrowSize * 0.7))
        arrowPath.addLine(to: CGPoint(x: -arrowSize * 0.6, y: -arrowSize * 0.7))
        arrowPath.closeSubpath()

        if aimArrowNode == nil || aimArrowNode?.parent == nil {
            aimArrowNode?.removeFromParent()
            let arrow = SKShapeNode()
            arrow.strokeColor = .clear
            arrow.zPosition = 19
            addChild(arrow)
            aimArrowNode = arrow
        }
        aimArrowNode?.path = arrowPath
        aimArrowNode?.fillColor = color
        aimArrowNode?.position = tip
        aimArrowNode?.zRotation = angle
    }

    private func aimColor(for ratio: CGFloat) -> SKColor {
        if ratio < 0.5 {
            let t = ratio / 0.5
            return SKColor(
                red: 1.0,
                green: 0.85 - 0.25 * t,
                blue: 0.15 - 0.1 * t,
                alpha: 1.0
            )
        } else {
            let t = (ratio - 0.5) / 0.5
            return SKColor(
                red: 1.0,
                green: 0.6 - 0.6 * t,
                blue: 0.05,
                alpha: 1.0
            )
        }
    }

    func hideAimIndicator() {
        aimDotNodes.forEach { $0.removeFromParent() }
        aimDotNodes.removeAll()
        aimArrowNode?.removeFromParent()
        aimArrowNode = nil
    }

    func playEntrySplash(at position: CGPoint) {
        guard !reduceMotion else { return }
        let container = SKNode()
        container.position = position
        container.zPosition = 20
        addChild(container)
        for _ in 0..<10 {
            let dot = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.5...3))
            dot.fillColor = [SKColor.systemYellow, SKColor.systemOrange].randomElement()!
            dot.strokeColor = .clear
            container.addChild(dot)
            let angle = CGFloat.random(in: 0...(.pi * 2))
            let distance = CGFloat.random(in: 14...30)
            let dest = CGPoint(x: cos(angle) * distance, y: sin(angle) * distance)
            dot.run(.group([
                .move(to: dest, duration: 0.4),
                .fadeOut(withDuration: 0.45),
            ]))
        }
        container.run(.sequence([.wait(forDuration: 0.5), .removeFromParent()]))
    }

    func pulseHit(at position: CGPoint) {
        guard !reduceMotion else { return }
        let ring = SKShapeNode(circleOfRadius: 4)
        ring.strokeColor = .systemOrange
        ring.lineWidth = 3
        ring.fillColor = .clear
        ring.position = position
        ring.zPosition = 20
        addChild(ring)
        let scale = SKAction.scale(to: 6, duration: 0.4)
        let fade = SKAction.fadeOut(withDuration: 0.4)
        ring.run(.sequence([.group([scale, fade]), .removeFromParent()]))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)
        for (id, node) in marbleNodes where node.frame.insetBy(dx: -14, dy: -14).contains(point) {
            if gameDelegate?.marbleScene(self, isAttackTarget: id) == true {
                selectTarget(id)
                return
            }
        }
        for (id, node) in marbleNodes where node.frame.insetBy(dx: -14, dy: -14).contains(point) {
            guard gameDelegate?.marbleScene(self, canLaunch: id) == true else { continue }
            draggingMarbleID = id
            dragStart = point
            marbleOriginAtDragStart = node.position
            break
        }
    }

    private func selectTarget(_ id: UUID) {
        for (nodeID, node) in marbleNodes {
            node.isTargeted = (nodeID == id)
        }
        gameDelegate?.marbleScene(self, didSelectTarget: id)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let id = draggingMarbleID, let node = marbleNodes[id] else { return }
        let point = touch.location(in: self)

        let drag = CGVector(dx: dragStart.x - point.x, dy: dragStart.y - point.y)
        let length = sqrt(drag.dx * drag.dx + drag.dy * drag.dy)
        let ratio = min(length / CGFloat(GameRules.maximumDragDistance), 1.0)
        gameDelegate?.marbleScene(self, didUpdatePower: Double(ratio))
        let clampedLength = min(length, CGFloat(GameRules.maximumDragDistance))
        if length > 0 {
            let normalized = CGVector(dx: drag.dx / length, dy: drag.dy / length)
            let pullBack = min(clampedLength * 0.35, 30)
            node.position = CGPoint(
                x: marbleOriginAtDragStart.x - normalized.dx * pullBack,
                y: marbleOriginAtDragStart.y - normalized.dy * pullBack
            )
            updateAimIndicator(origin: marbleOriginAtDragStart, direction: normalized, ratio: ratio)
        } else {
            hideAimIndicator()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let id = draggingMarbleID, let node = marbleNodes[id] else {
            draggingMarbleID = nil
            return
        }
        let point = touch.location(in: self)

        let drag = CGVector(dx: dragStart.x - point.x, dy: dragStart.y - point.y)
        let velocity = PhysicsEngine.velocity(fromDrag: drag, rules: GameRules.default)
        node.position = marbleOriginAtDragStart
        node.velocity = velocity
        draggingMarbleID = nil
        gameDelegate?.marbleScene(self, didUpdatePower: 0)
        hideAimIndicator()
        if velocity.dx != 0 || velocity.dy != 0 {
            gameDelegate?.marbleScene(self, didLaunch: id, dragVector: drag)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        draggingMarbleID = nil
        gameDelegate?.marbleScene(self, didUpdatePower: 0)
        hideAimIndicator()
    }

    func launch(marbleID: UUID, dragVector: CGVector) {
        guard let node = marbleNodes[marbleID] else { return }
        node.velocity = PhysicsEngine.velocity(fromDrag: dragVector, rules: GameRules.default)
        gameDelegate?.marbleScene(self, didLaunch: marbleID, dragVector: dragVector)
    }

    override func update(_ currentTime: TimeInterval) {
        anyMoving = false
        let bounds = CGRect(origin: .zero, size: size).insetBy(dx: 20, dy: 20)

        for (id, node) in marbleNodes {
            guard node.currentSpeed > 0 else { continue }
            node.position.x += node.velocity.dx * (1.0 / 60.0)
            node.position.y += node.velocity.dy * (1.0 / 60.0)
            node.velocity = PhysicsEngine.applyFriction(velocity: node.velocity)
            node.position = PhysicsEngine.clampPosition(node.position, in: bounds, radius: CGFloat(GameRules.marbleRadius))

            if PhysicsEngine.hasStopped(velocity: node.velocity) {
                node.velocity = .zero
                gameDelegate?.marbleScene(self, marbleDidStop: id, at: node.position)
            } else {
                anyMoving = true
            }
        }

        checkCollisions()
    }

    private func checkCollisions() {
        let ids = Array(marbleNodes.keys)
        guard ids.count > 1 else { return }
        for i in 0..<ids.count {
            for j in (i + 1)..<ids.count {
                guard let a = marbleNodes[ids[i]], let b = marbleNodes[ids[j]] else { continue }
                let dx = b.position.x - a.position.x
                let dy = b.position.y - a.position.y
                let distance = sqrt(dx * dx + dy * dy)
                let minDistance = CGFloat(GameRules.marbleRadius * 2)
                if distance < minDistance, distance > 0 {
                    let overlap = (minDistance - distance) / 2
                    let nx = dx / distance
                    let ny = dy / distance
                    a.position.x -= nx * overlap
                    a.position.y -= ny * overlap
                    b.position.x += nx * overlap
                    b.position.y += ny * overlap
                    let temp = a.velocity
                    a.velocity = CGVector(dx: b.velocity.dx * 0.6, dy: b.velocity.dy * 0.6)
                    b.velocity = CGVector(dx: temp.dx * 0.6, dy: temp.dy * 0.6)
                    gameDelegate?.marbleScene(self, marblesCollided: a.marbleID, idB: b.marbleID)
                }
            }
        }
    }

    private static var cachedGroundTexture: SKTexture?
    private static var cachedHoleTextures: [CGFloat: SKTexture] = [:]

    private static func groundTexture() -> SKTexture {
        if let cached = cachedGroundTexture { return cached }
        let size = CGSize(width: 256, height: 256)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cg = context.cgContext
            let rect = CGRect(origin: .zero, size: size)
            let base = UIColor(red: 0.22, green: 0.14, blue: 0.06, alpha: 1)
            base.setFill()
            cg.fill(rect)

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let vignette = [
                UIColor.clear.cgColor,
                UIColor.black.withAlphaComponent(0.22).cgColor,
            ]
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: vignette as CFArray, locations: [0, 1]) {
                cg.drawRadialGradient(
                    gradient,
                    startCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                    startRadius: size.width * 0.2,
                    endCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                    endRadius: size.width * 0.75,
                    options: []
                )
            }

            var generator = SystemRandomNumberGenerator()
            for _ in 0..<420 {
                let x = CGFloat.random(in: 0...size.width, using: &generator)
                let y = CGFloat.random(in: 0...size.height, using: &generator)
                let speckSize = CGFloat.random(in: 0.6...2.0, using: &generator)
                let lighten = Bool.random(using: &generator)
                let alpha = CGFloat.random(in: 0.08...0.2, using: &generator)
                let color = lighten
                    ? UIColor(red: 0.34, green: 0.23, blue: 0.11, alpha: alpha)
                    : UIColor(red: 0.12, green: 0.07, blue: 0.03, alpha: alpha)
                color.setFill()
                cg.fillEllipse(in: CGRect(x: x, y: y, width: speckSize, height: speckSize))
            }
        }
        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        cachedGroundTexture = texture
        return texture
    }

    private static func holeTexture(radius: CGFloat) -> SKTexture {
        if let cached = cachedHoleTextures[radius] { return cached }
        let diameter = radius * 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        let image = renderer.image { context in
            let cg = context.cgContext
            let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
            cg.saveGState()
            cg.addEllipse(in: rect)
            cg.clip()
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [
                UIColor(red: 0.62, green: 0.4, blue: 0.12, alpha: 1).cgColor,
                UIColor(red: 0.22, green: 0.13, blue: 0.05, alpha: 1).cgColor,
                UIColor.black.cgColor,
            ]
            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0, 0.55, 1]) {
                cg.drawRadialGradient(
                    gradient,
                    startCenter: CGPoint(x: diameter / 2, y: diameter / 2),
                    startRadius: 0,
                    endCenter: CGPoint(x: diameter / 2, y: diameter / 2),
                    endRadius: diameter / 2,
                    options: []
                )
            }
            cg.restoreGState()
        }
        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        cachedHoleTextures[radius] = texture
        return texture
    }
}
