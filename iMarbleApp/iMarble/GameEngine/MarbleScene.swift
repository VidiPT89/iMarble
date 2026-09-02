import SpriteKit

protocol MarbleSceneDelegate: AnyObject {
    func marbleScene(_ scene: MarbleScene, canLaunch marbleID: UUID) -> Bool
    func marbleScene(_ scene: MarbleScene, didLaunch marbleID: UUID)
    func marbleScene(_ scene: MarbleScene, didUpdatePower ratio: Double)
    func marbleScene(_ scene: MarbleScene, marbleDidStop marbleID: UUID, at position: CGPoint)
    func marbleScene(_ scene: MarbleScene, marblesCollided idA: UUID, idB: UUID)
}

final class MarbleScene: SKScene {
    weak var gameDelegate: MarbleSceneDelegate?

    private var marbleNodes: [UUID: MarbleNode] = [:]
    private var holeNodes: [Int: SKShapeNode] = [:]
    private var draggingMarbleID: UUID?
    private var dragStart: CGPoint = .zero
    private var marbleOriginAtDragStart: CGPoint = .zero
    private var anyMoving = false
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

        let launchLine = SKShapeNode(rectOf: CGSize(width: 2, height: sceneSize.height * 0.7))
        launchLine.fillColor = SKColor.systemYellow.withAlphaComponent(0.5)
        launchLine.strokeColor = .clear
        launchLine.position = CGPoint(x: sceneSize.width * 0.12, y: sceneSize.height / 2)
        launchLine.zPosition = -5
        addChild(launchLine)

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
            guard gameDelegate?.marbleScene(self, canLaunch: id) == true else { continue }
            draggingMarbleID = id
            dragStart = point
            marbleOriginAtDragStart = node.position
            break
        }
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
        if velocity.dx != 0 || velocity.dy != 0 {
            gameDelegate?.marbleScene(self, didLaunch: id)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        draggingMarbleID = nil
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
