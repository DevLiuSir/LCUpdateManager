//
//  LCUpdateViewController.swift
//  AutoSwitchInput
//
//  Created by Liu Chuan on 2024/12/1.
//
//  Copyright Ningbo Shangguan Technology Co.,Ltd. All Rights Reserved.
//  宁波上官科技有限公司版权所有，保留一切权利。
//


import Cocoa


/// 更新视图控制器
class LCUpdateViewController: NSViewController {
    
    /// 毛玻璃效果视图
    private lazy var effectView: NSVisualEffectView = {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow // 设置毛玻璃模式
        return view
    }()
    
    /// 信息标签，显示更新内容
    public lazy var infoLabel: NSTextField = {
        let label = NSTextField(wrappingLabelWithString: "")
        label.isEditable = false // 禁用编辑
        label.isBordered = false // 去掉边框
        label.controlSize = .regular
        return label
    }()
    
    /// 跳过按钮
    private lazy var skipBtn: NSButton = createButton(
        title: LCUpdateManagerLocalizeString("Skip"),
        action: #selector(skip(_:))
    )
    
    /// 更新按钮
    private lazy var updateBtn: NSButton = createButton(
        title: LCUpdateManagerLocalizeString("Update"),
        action: #selector(update(_:))
    )
    
    /// 更新内容字符串，设置时会动态调整窗口大小
    var updateInfo: String = "" {
        didSet {
            updateInfoDidChange()
        }
    }
    
    // MARK: - 生命周期方法
    
    override func loadView() {
        view = NSView() // 初始化主视图
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews() // 添加子视图
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        layoutSubviews() // 调整布局
    }
    
    // MARK: - 按钮事件
    
    /// 跳过更新
    @objc private func skip(_ sender: NSButton) {
        view.window?.close() // 关闭窗口
    }
    
    /// 前往更新
    @objc private func update(_ sender: NSButton) {
        guard let appStoreUrl = URL(string: LCUpdateManager.shared.appStoreUrl) else {
            print("Error: 无效的 App Store URL") // 添加日志记录
            return
        }
        NSWorkspace.shared.open(appStoreUrl) // 打开 App Store
        view.window?.close()    // 关闭窗口
    }
    
    // MARK: - 私有方法
    
    /// 创建`按钮`的通用方法
    /// - Parameters:
    ///   - title: 按钮标题
    ///   - action: 按钮点击事件
    /// - Returns: 初始化后的按钮
    private func createButton(title: String, action: Selector) -> NSButton {
        let button = NSButton(title: title, target: self, action: action)
        button.bezelStyle = .rounded // 设置按钮样式
        return button
    }
    
    /// 添加`子视图`到`主视图`
    private func setupSubviews() {
        [effectView, infoLabel, skipBtn, updateBtn].forEach { view.addSubview($0) }
    }
    
    /// 调整子视图布局
    private func layoutSubviews() {
        effectView.frame = view.bounds // 毛玻璃填满整个视图
        
        updateBtn.sizeToFit()
        skipBtn.sizeToFit()
        
        // 布局更新按钮
        updateBtn.frame = CGRect(
            x: view.frame.width - 20 - updateBtn.frame.width,
            y: 10,
            width: updateBtn.frame.width,
            height: updateBtn.frame.height
        )
        
        // 布局跳过按钮
        skipBtn.frame = CGRect(
            x: updateBtn.frame.minX - skipBtn.frame.width,
            y: 10,
            width: skipBtn.frame.width,
            height: skipBtn.frame.height
        )
        
        // 布局信息标签
        let infoY = updateBtn.frame.maxY + 10
        infoLabel.frame = NSRect(
            x: 20,
            y: infoY,
            width: view.frame.width - 40,
            height: view.frame.height - infoY - 40
        )
    }
    
    /// 更新内容变更后调整窗口大小和标签内容
    private func updateInfoDidChange() {
        infoLabel.stringValue = updateInfo
        let attributes: [NSAttributedString.Key: Any] = [.font: infoLabel.font!]
        
        // 计算信息内容所需的高度
        let height = (updateInfo as NSString).boundingRect(
            with: CGSize(width: 460, height: CGFloat.greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: attributes
        ).height + 100
        
        // 调整窗口大小并居中
        if let window = view.window {
            window.setFrame(NSRect(x: 0, y: 0, width: 500, height: height), display: true)
            window.center()
        }
    }
}
