import SpriteKit

protocol MarbleSceneDelegate: AnyObject {
    func marbleScene(_ scene: MarbleScene, canLaunch marbleID: UUID) -> Bool
    func marbleScene(_ scene: MarbleScene, isAttackTarget marbleID: UUID) -> Bool
    func marbleScene(_ scene: MarbleScene, didSelectTarget marbleID: UUID)
    func marbleScene(_ scene: MarbleScene, didLaunch marbleID: UUID)
    func marbleScene(_ scene: MarbleScene, didUpdatePower ratio: Double)
    func marbleScene(_ scene: MarbleScene, marbleDidStop marbleID: UUID, at position: CGPoint)
    func marbleScene(_ scene: MarbleScene, marblesCollided idA: UUID, idB: UUID)
    func marbleScene(_ scene: MarbleScene, isPalmoTarget marbleID: UUID) -> Bool
    func marbleScene(_ scene: MarbleScene, palmoRangeFor marbleID: UUID) -> CGFloat
    func marbleScene(_ scene: MarbleScene, didDragPalmo marbleID: UUID, vector: CGVector)
}

final class MarbleScene: SKScene {
    weak var gameDelegate: MarbleSceneDelegate?

    private var marbleNodes: [UUID: MarbleNode] = [:]
    private var holeNodes: [Int: SKShapeNode] = [:]
    private var groundNode: SKShapeNode?
    private var launchLineNode: SKShapeNode?
    private var draggingMarbleID: UUID?
    private var dragStart: CGPoint = .zero
    private var marbleOriginAtDragStart: CGPoint = .zero
    private var anyMoving = false
    private var isDraggingPalmo = false
    private var palmoRangeNode: SKShapeNode?
    var reduceMotion = false

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

        let ground = SKShapeNode(rectOf: sceneSize)
        ground.fillColor = SKColor(red: 0.22, green: 0.14, blue: 0.06, alpha: 1)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        ground.zPosition = -10
        addChild(ground)
        groundNode = ground

        let launchLine = SKShapeNode(rectOf: CGSize(width: 2, height: sceneSize.height * 0.7))
        launchLine.fillColor = SKColor.systemYellow.withAlphaComponent(0.5)
        launchLine.strokeColor = .clear
        launchLine.position = CGPoint(x: sceneSize.width * 0.12, y: sceneSize.height / 2)
        launchLine.zPosition = -5
        addChild(launchLine)
        launchLineNode = launchLine

        for hole in holes {
            let node = SKShapeNode(circleOfRadius: CGFloat(hole.radius))
            node.fillColor = SKColor.black.withAlphaComponent(0.75)
            node.strokeColor = SKColor(red: 0.95, green: 0.6, blue: 0.1, alpha: 1)
            node.lineWidth = 2
            node.position = hole.position.cgPoint
            node.zPosition = 1
            addChild(node)
            holeNodes[hole.number] = node
        }
    }

    /// Repositions existing field elements (ground, launch line, holes) for a
    /// new scene size without removing marble nodes, preserving in-progress
    /// game state.
    func relayoutField(holes: [Hole], sceneSize: CGSize) {
        size = sceneSize

        groundNode?.path = CGPath(rect: CGRect(x: -sceneSize.width / 2, y: -sceneSize.height / 2, width: sceneSize.width, height: sceneSize.height), transform: nil)
        groundNode?.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)

        launchLineNode?.path = CGPath(rect: CGRect(x: -1, y: -sceneSize.height * 0.35, width: 2, height: sceneSize.height * 0.7), transform: nil)
        launchLineNode?.position = CGPoint(x: sceneSize.width * 0.12, y: sceneSize.height / 2)

        for hole in holes {
            holeNodes[hole.number]?.position = hole.position.cgPoint
        }
    }

    func addMarble(_ marble: Marble, color: SKColor) {
        let node = MarbleNode(marbleID: marble.id, radius: CGFloat(GameRules.marbleRadius), color: color)
        node.position = marble.position.cgPoint
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

    func showPalmoRange(marbleID: UUID, radius: CGFloat) {
        guard let node = marbleNodes[marbleID] else { return }
        palmoRangeNode?.removeFromParent()
        let ring = SKShapeNode(circleOfRadius: radius)
        ring.strokeColor = SKColor.systemYellow.withAlphaComponent(0.6)
        ring.lineWidth = 2
        ring.lineCap = .round
        ring.fillColor = .clear
        ring.position = node.position
        ring.zPosition = 15
        if !reduceMotion {
            ring.setScale(0.85)
            ring.run(.scale(to: 1.0, duration: 0.2))
        }
        addChild(ring)
        palmoRangeNode = ring
    }

    func hidePalmoRange() {
        palmoRangeNode?.removeFromParent()
        palmoRangeNode = nil
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
            if gameDelegate?.marbleScene(self, isPalmoTarget: id) == true {
                draggingMarbleID = id
                isDraggingPalmo = true
                dragStart = point
                marbleOriginAtDragStart = node.position
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

        if isDraggingPalmo {
            let maxRange = gameDelegate?.marbleScene(self, palmoRangeFor: id) ?? 0
            let move = CGVector(dx: point.x - dragStart.x, dy: point.y - dragStart.y)
            let length = min(sqrt(move.dx * move.dx + move.dy * move.dy), maxRange)
            if length > 0 {
                let normalized = CGVector(dx: move.dx / sqrt(move.dx * move.dx + move.dy * move.dy), dy: move.dy / sqrt(move.dx * move.dx + move.dy * move.dy))
                node.position = CGPoint(
                    x: marbleOriginAtDragStart.x + normalized.dx * length,
                    y: marbleOriginAtDragStart.y + normalized.dy * length
                )
            } else {
                node.position = marbleOriginAtDragStart
            }
            return
        }

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
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let id = draggingMarbleID, let node = marbleNodes[id] else {
            draggingMarbleID = nil
            isDraggingPalmo = false
            return
        }
        let point = touch.location(in: self)

        if isDraggingPalmo {
            let vector = CGVector(dx: point.x - dragStart.x, dy: point.y - dragStart.y)
            node.position = marbleOriginAtDragStart
            draggingMarbleID = nil
            isDraggingPalmo = false
            gameDelegate?.marbleScene(self, didDragPalmo: id, vector: vector)
            return
        }

        let drag = CGVector(dx: dragStart.x - point.x, dy: dragStart.y - point.y)
        let velocity = PhysicsEngine.velocity(fromDrag: drag, rules: GameRules.default)
        node.position = marbleOriginAtDragStart
        node.velocity = velocity
        draggingMarbleID = nil
        gameDelegate?.marbleScene(self, didUpdatePower: 0)
        if velocity.dx != 0 || velocity.dy != 0 {
            gameDelegate?.marbleScene(self, didLaunch: id)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        draggingMarbleID = nil
        isDraggingPalmo = false
        gameDelegate?.marbleScene(self, didUpdatePower: 0)
    }

    func launch(marbleID: UUID, dragVector: CGVector) {
        guard let node = marbleNodes[marbleID] else { return }
        node.velocity = PhysicsEngine.velocity(fromDrag: dragVector, rules: GameRules.default)
        gameDelegate?.marbleScene(self, didLaunch: marbleID)
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
}
