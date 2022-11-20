//
//  GameScene.swift
//  SpaceShip
//
//  Created by Андрей Антонов on 14.02.2021.
//  Copyright © 2021 Андрей Антонов. All rights reserved.
//
import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scorelabel: SKLabelNode!
    var score = 0 {
        didSet {
            scorelabel.text = "Счет: \(score)"
        }
    }
    
    var gameTimer: Timer!
    var aliens = ["alien", "alien2", "alien3"]
    let alienCategory: UInt32 = 0x1 << 1
    let bulletCategory: UInt32 = 0x1 << 0
    
    let motionManeger = CMMotionManager()
    var xAccelerate: CGFloat = 0
    
    override func didMove(to view: SKView) {
        starfield = SKEmitterNode(fileNamed: "Starfield")
        starfield.position = CGPoint(x: 0, y: 1472)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "shuttle")
        player.position = CGPoint(x: 0, y: -300)
        
        self.addChild(player)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scorelabel = SKLabelNode(text: "Счет: 0")
        scorelabel.fontName = "AmericanTypewriter-Bold"
        scorelabel.fontSize = 30
        scorelabel.fontColor = .white
        scorelabel.position = CGPoint(x: -100, y: 300)
        score = 0
        
        self.addChild(scorelabel)
        
        var timeInteval = 0.75
        
        if UserDefaults.standard.bool(forKey: "hard") {
            timeInteval = 0.3
        }
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        motionManeger.accelerometerUpdateInterval = 0.2
        motionManeger.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometrData = data {
                let acceleration = accelerometrData.acceleration
                self.xAccelerate = CGFloat(acceleration.x) * 0.75 + self.xAccelerate * 0.50
            }
        }
    }
    
    override func didSimulatePhysics() {
        player.position.x += xAccelerate * 50
        
        if player.position.x < 0 {
            player.position = CGPoint(x: UIScreen.main.bounds.width - player.size.width, y: player.position.y)
        }
        else if player.position.x > UIScreen.main.bounds.width {
            player.position = CGPoint(x: 20, y: player.position.y)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var alienBody: SKPhysicsBody
        var bulletBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bulletBody = contact.bodyA
            alienBody = contact.bodyB
        }
        else {
            bulletBody = contact.bodyB
            alienBody = contact.bodyA
        }
        
        if (alienBody.categoryBitMask & alienCategory) != 0 && (bulletBody.categoryBitMask & bulletCategory) != 0 {
            collisionElements(bulletNode: bulletBody.node as! SKSpriteNode, alienNode: alienBody.node as! SKSpriteNode)
        }
    }
    
    func collisionElements (bulletNode: SKSpriteNode, alienNode: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Vzriv")
        explosion?.position = alienNode.position
        self.addChild(explosion!)
        self.run(SKAction.playSoundFileNamed("vzriv", waitForCompletion: false))
        
        bulletNode.removeFromParent()
        alienNode.removeFromParent()
        self.run(SKAction.wait(forDuration: 2)) {
            explosion?.removeFromParent()
        }
        
        score += 1
    }
    
    @objc func addAlien() {
        aliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: aliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: aliens[0])
        let randomPosition = GKRandomDistribution(lowestValue: 20, highestValue: Int(UIScreen.main.bounds.size.width - 20))
        let position = CGFloat(randomPosition.nextInt())
        alien.position = CGPoint(x: position, y: UIScreen.main.bounds.size.height + alien.size.height)
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = bulletCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        let animDuration: TimeInterval = 6
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: position, y: 0 - alien.size.height), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actions))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }
    
    func fireBullet() {
        self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
        
        let bullet = SKSpriteNode(imageNamed: "torpedo")
        bullet.position = player.position
        bullet.position.y += 5
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        bullet.physicsBody?.isDynamic = true
        
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = alienCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(bullet)
        
        let animDuration: TimeInterval = 0.3
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: UIScreen.main.bounds.size.height + bullet.size.height), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        bullet.run(SKAction.sequence(actions))
    }
}
