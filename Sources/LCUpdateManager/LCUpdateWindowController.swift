//
//  LCUpdateWindowController.swift
//
//  Created by DevLiuSir on 2023/3/22.
//


import Foundation
import Cocoa


class LCUpdateWindowController: NSWindowController {
    
    /// 更新视图控制器
    private lazy var vc: LCUpdateViewController = LCUpdateViewController()
    
    /// 初始化方法
    override init(window: NSWindow?) {
        super.init(window: nil)
        self.window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 300),
            styleMask: [.titled, .fullSizeContentView, .miniaturizable, .closable],
            backing: .buffered,
            defer: true
        )
        self.window?.titlebarAppearsTransparent = true // 标题栏透明
        self.window?.standardWindowButton(.zoomButton)?.isHidden = true // 隐藏最大化按钮
        self.window?.isOpaque = false // 窗口不透明
        self.window?.isMovableByWindowBackground = true // 可以通过窗口背景拖动
        self.window?.contentViewController = vc // 设置内容视图控制器
        self.window?.center() // 窗口居中
    }
    
    /// 必须实现的初始化方法，防止 Xcode 报错
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


//MARK: - configure
extension LCUpdateWindowController {
    
    /// 显示新版本信息
    ///
    /// - Parameters:
    ///   - newVersion: 新版本号
    ///   - info: 更新信息
    func showNewVersion(newVersion: String, info: String) {
        // 发现新版本
        let title = "\(LCUpdateManagerLocalizeString("New version found")) : \(newVersion)"
        window?.title = title
        
        // 获取 UpdateViewController 并设置更新信息
        guard let vc = window?.contentViewController as? LCUpdateViewController else { return }
        vc.updateInfo = info
    }
    
}
