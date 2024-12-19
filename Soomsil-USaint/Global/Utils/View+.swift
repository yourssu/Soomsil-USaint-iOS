//
//  View+.swift
//  Soomsil-USaint-iOS 
//
//  Created by 최지우 on 12/19/24.
//

import SwiftUI
import Photos

extension View {
    private func takeScreenshot(origin: CGPoint, size: CGSize) -> UIImage? {
        let window = UIWindow(frame: CGRect(origin: origin, size: size))
        let hosting = UIHostingController(rootView: self)
        hosting.view.frame = window.frame
        window.addSubview(hosting.view)
        window.makeKeyAndVisible()
        return hosting.view.screenShot()
    }

    func screenShot(origin: CGPoint, size: CGSize, success: @escaping () -> Void, failure: @escaping () -> Void) {
        guard let screenshot = body.takeScreenshot(origin: origin, size: size) else {
            DispatchQueue.main.async {
                failure()
            }
            return
        }

        // 사진권한이 허용 되어 있으면 저장
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                UIImageWriteToSavedPhotosAlbum(screenshot, self, nil, nil)
                DispatchQueue.main.async {
                    success()
                }
            case .denied, .restricted, .notDetermined:
                DispatchQueue.main.async {
                    failure()
                }
            default:
                DispatchQueue.main.async {
                    failure()
                }
            }
        }
    }
}

extension UIView {
    func screenShot() -> UIImage? {
        let size = self.frame.size
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            self.layer.render(in: context.cgContext)
        }
    }
}

