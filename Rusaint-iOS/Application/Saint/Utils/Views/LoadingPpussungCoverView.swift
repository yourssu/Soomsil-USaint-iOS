//
//  LoadingPpussungCoverView.swift
//  SaintKit
//
//  Created by Gyuni on 2022/06/19.
//

import UIKit
import SwiftUI

class LoadingPpussungCoverView: UIView {

    let ppussungImageView = LoadingPpussungImageView()
    let backgroundImageView = UIImageView()

    init() {
        super.init(frame: .zero)

        #if APPCLIP
        addSubview(backgroundImageView)
        addSubview(ppussungImageView)
        backgroundImageView.image = UIImage(named: "jumppuGrassBG")
        #else
        addSubviews(backgroundImageView, ppussungImageView)
        backgroundImageView.image = UIImage(named: "jumppuGrassBG")
        #endif
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        ppussungImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
struct LoadingCoverView: View {
    @State private var currentImageIndex = 0
    let images = [
        Image("ppussungWalk1"),
        Image("ppussungWalk2"),
        Image("ppussungWalk1"),
        Image("ppussungWalk2"),
        Image("ppussungJump")
    ]
    let backgroundImage = Image("jumppuGrassBG")
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                backgroundImage
                    .frame(width: proxy.size.width, height: proxy.size.height)
                images[self.currentImageIndex]
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                            self.changeImage()
                        }
                    }
            }
        }
        .ignoresSafeArea()
    }
    func changeImage() {
        self.currentImageIndex = (self.currentImageIndex + 1) % self.images.count
    }
}
