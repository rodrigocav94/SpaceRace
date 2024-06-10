//
//  GameScene.swift
//  SpaceRace
//
//  Created by Rodrigo Cavalcanti on 09/06/24.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var isPlayerRerouting = false
    var amountOfEnemies = 0
    var enemyCreationDelay: Double = 1
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    let possibleEnemies = ["chair", "tv", "hammer", "ball", "shoe", "octopus", "astronaut", "tower", "redeemer", "samba", "witch"]
    var isGameOver = false
    var gameTimer: Timer?
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1180, y: 410)
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "rocket")
        player.position = CGPoint(x: 200, y: 410)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size) // Create a physics body based on the texture and size.
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        startTimer()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        if isGameOver { gameTimer?.invalidate() }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...784))
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1 // Collision tag.
        
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0) // Velocity going from right to left.
        sprite.physicsBody?.angularVelocity = 5 // Rotation/Spinning Velocity.
        sprite.physicsBody?.linearDamping = 0 // Movement will not slow down over time.
        sprite.physicsBody?.angularDamping = 0 // Rotation will not slow down over time.
        
        amountOfEnemies += 1
        if amountOfEnemies % 20 == 0 {
            enemyCreationDelay -= 0.1
            startTimer()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        clampLocation(location: &location)
        
        isPlayerRerouting = true
        let moveToLocation = SKAction.move(to: location, duration: 0.3)
        let reactivateMovement = SKAction.run { [unowned self] in
            isPlayerRerouting = false
        }
        player.run(SKAction.sequence([moveToLocation, reactivateMovement]))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if isPlayerRerouting { return }
        var location = touch.location(in: self)
        
        clampLocation(location: &location)
        player.position = location
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        let delay = SKAction.wait(forDuration: 0.5)
        let removeExplosionNode = SKAction.run { [unowned explosion] in
            explosion.removeFromParent()
        }
        player.removeFromParent()
        explosion.run(SKAction.sequence([delay, removeExplosionNode]))
        
        isGameOver = true
    }
    
    func clampLocation(location: inout CGPoint) {
        // Clamping vertical position
        if location.y < 100 {
            location.y = 100
        } else if location.y > 720 {
            location.y = 720
        }
    }
    
    func startTimer() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: enemyCreationDelay, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
}
