//
//  LoadingPpussungImageView.swift
//  SaintKit
//
//  Created by Gyuni on 2021/12/22.
//

import UIKit
#if !APPCLIP
#endif

class LoadingPpussungImageView: UIImageView {

    init() {
        super.init(frame: .zero)
        #if APPCLIP
        let jump = UIImage(named: "ppussungJump")!
        let walk1 = UIImage(named: "ppussungWalk1")!
        let walk2 = UIImage(named: "ppussungWalk2")!
        #else
        let jump = UIImage(named: "ppussungJump")!
        let walk1 = UIImage(named: "ppussungWalk1")!
        let walk2 = UIImage(named: "ppussungWalk2")!
        #endif
        if let ppussungImages = UIImage.animatedImage(with: [
            walk1,
            walk2,
            walk1,
            walk2,
            jump
        ], duration: 2) {

            image = ppussungImages
        }

        animationDuration = 3
        contentMode = .scaleAspectFit
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
