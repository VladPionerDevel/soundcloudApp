//
//  extensionUIWindow.swift
//  soundcloudApp
//
//  Created by pioner on 06.11.2021.
//

import UIKit

extension UIApplication {
    var bottomSafeArial: CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows.first
            let bottomPadding = window?.safeAreaInsets.bottom
            
            return bottomPadding ?? 0
        } else {
            return 0
        }
    }
}
