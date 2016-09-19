//
//  MainMenu.swift
//  SpriteKitIntro
//
//  Created by Dave Vo on 7/4/16.
//  Copyright © 2016 DaveVo. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let game: GameScene = GameScene(fileNamed: "GameScene")!
        game.scaleMode = .aspectFill
        let transition: SKTransition = SKTransition.crossFade(withDuration: 0.5)
        
        self.view?.presentScene(game, transition: transition)
    }
}
