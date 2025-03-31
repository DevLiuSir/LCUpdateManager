//
//  LCUpdateManager.swift
//
//  Created by DevLiuSir on 2023/3/22.
//


import Foundation


// 获取应用名称
public let kAppName: String = {
    let bundle = Bundle.main
    return bundle.localizedInfoDictionary?["CFBundleDisplayName"] as? String
    ?? bundle.infoDictionary?["CFBundleDisplayName"] as? String
    ?? bundle.localizedInfoDictionary?["CFBundleName"] as? String
    ?? bundle.infoDictionary?["CFBundleName"] as? String
    ?? "Unknown App Name" // 默认值，如果无法获取应用名称
}()


public func LCUpdateManagerLocalizeString(_ key: String) -> String {
    #if SWIFT_PACKAGE
    // 如果是通过 Swift Package Manager 使用
    return Bundle.module.localizedString(forKey: key, value: "", table: "LCUpdateManager")
    #else
    // 如果是通过 CocoaPods 使用
    struct StaticBundle {
        static let bundle: Bundle = {
            return Bundle(for: LCUpdateManager.self)
        }()
    }
    return StaticBundle.bundle.localizedString(forKey: key, value: "", table: "LCUpdateManager")
    #endif
}



#if OFFLINE
import Sparkle
import Cocoa



/// 封装的 Sparkle 更新管理类
public class LCUpdateManager: NSObject, SPUUpdaterDelegate, SPUStandardUserDriverDelegate {
    
    /// 单例
    public static let shared = LCUpdateManager()
    
    /// 更新控制器
    private var updateController: SPUStandardUpdaterController?
    
    /// 初始化
    private override init() {
        super.init()
        
        // 创建 Sparkle 更新控制器，用于处理应用程序更新
        // startingUpdater: 是否立即启动更新检查，默认为 false
        // updaterDelegate: 更新代理对象，处理更新相关的回调和事件
        // userDriverDelegate: 用户界面驱动代理对象，可选，用于自定义用户界面的显示
        updateController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: self, userDriverDelegate: self)
    }
    
    /// Sparkle 后台检查更新（根据用户设置，是否自动更新）
    public func checkForUpdatesInBackground() {
        
        //        updaterController.updater.automaticallyChecksForUpdates = Database.standard.isEnableAutomaticCheckUpdate
        
        // 是否启用：自动检查更新， false: 会隐藏`稍后提醒` 按钮  隐藏《以后自动下载并安装更新》勾选项
        updateController?.updater.automaticallyChecksForUpdates = true
        
        // 后台检查版本更新：有新版本后，才提示更新，没有就不提示弹窗
        updateController?.updater.checkForUpdatesInBackground()
        
        /*
         // 手动触发应用程序更新检查
         updaterController.checkForUpdates(nil)
         
         // 更新频率（以秒为单位，设置为非零值表示定期检查更新）
         updaterController.updater.updateCheckInterval = 5  // 秒为单位 检查一次
         */
        
    }
    
    /// 手动更新
    @objc func checkForUpdates(_ sender: Any?) {
        updateController?.checkForUpdates(sender)
    }
    
    
    
    
    /// 判断`应用过期时间`
    /// - Parameters:
    ///   - year: 年份
    ///   - month: 月份
    ///   - day: 日期
    public func judgeAppExpire(year: Int, month: Int, day: Int) {
        let calendar = Calendar.current
        // 获取当前日期
        let currentDate = Date()
        // 创建给定的日期
        let expirationDate = calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? currentDate
        
        // 比较《给定的日期》是否超过《当前日期》，超过指定日期，显示警告
        if currentDate > expirationDate {
            // 过期了
            let alert = NSAlert()
            alert.messageText = LCUpdateManagerLocalizeString("Kind tips") // 提示标题
            alert.informativeText = String(format: LCUpdateManagerLocalizeString("Expire Tips"), kAppName)       // 提示内容
            alert.addButton(withTitle: LCUpdateManagerLocalizeString("Click to download"))      // 按钮标题
            alert.alertStyle = .warning
            // 0.弹窗
            alert.runModal()
            
            // 1.使用浏览器打开链接
            NSWorkspace.shared.open(URL(string: Web_app_offline)!)
            
            // 2.退出 app
            NSApp.terminate(nil)
        }
    }
    
    
    
    /// 根据`系统版本`判断`试用到期`
    /// - Parameter osVersion: 系统版本字符串，格式如 "X.Y.Z"
    public func judgeAppExpire(withOSVersion osVersion: String) {
        // 获取当前系统版本号
        let sv = ProcessInfo.processInfo.operatingSystemVersion
        let sysVersion = "\(sv.majorVersion).\(sv.minorVersion).\(sv.patchVersion)"
        // 大于、等于设置的 系统版本
        if sysVersion.compare(osVersion, options: .numeric) != .orderedAscending {
            let alert = NSAlert()
            alert.messageText = LCUpdateManagerLocalizeString("Kind tips")
            alert.informativeText = String(format: LCUpdateManagerLocalizeString("OS Expire Tips"), kAppName)
            alert.addButton(withTitle: LCUpdateManagerLocalizeString("Click to update"))
            alert.alertStyle = .warning
            // 0.弹窗
            alert.runModal()
            // 1.使用浏览器打开链接
            NSWorkspace.shared.open(URL(string: appIntroduceUrl)!)
            
            // 2.退出 app
            NSApp.terminate(nil)
        }
    }
    
    
    /// 当更新器完成加载 appcast 时调用。
    /// - Parameters:
    ///   - updater: 调用此方法的 SPUUpdater 实例。
    ///   - appcast: 加载完成的 appcast 实例。
    func updater(_ updater: SPUUpdater, didFinishLoading appcast: SUAppcast) {
        // 假设 SUAppcastItem 有 title 和 versionString 属性
        if let firstItem = appcast.items.first {
            // 直接访问属性来获取信息
            let title = firstItem.title ?? "无标题"
            let versionString = firstItem.versionString
            // 构建一个字典或者直接打印信息
            print("\(#function) 获取xml文件成功: 标题：\(title), 版本：\(versionString)")
        }
    }
    
    /// 当更新器检查更新，但`未发现新版本时`调用。
    /// - Parameter updater: 调用此方法的 SPUUpdater 实例。
    func updaterDidNotFindUpdate(_ updater: SPUUpdater) {
        print("暂无更新")
    }
    
    /// 当更新器发现`有效更新时`调用。
    /// - Parameters:
    ///   - updater: 调用此方法的 SPUUpdater 实例。
    ///   - item: 发现的有效更新。
    func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        
        let versionStr = item.displayVersionString
        
        print("\(#function) 有可用升级:")
        print("Version: \(versionStr)")
        print("Build number: \(item.versionString)")
        
        // 确保 URL 存在，否则打印 "未知"
        if let fileURL = item.fileURL?.absoluteString {
            print("Url: \(fileURL)")
        } else {
            print("Url: 未知")
        }
        
        // 确保更新说明存在，否则打印 "无"
        let note = item.itemDescription ?? "无"
        print("Note: \(note)")
        
    }
    
    /// 当用户做出`更新选择后`调用，例如`安装更新、跳过此版本或稍后提醒。`
    /// - Parameters:
    ///   - updater: 调用此方法的 SPUUpdater 实例。
    ///   - choice: 用户所做的选择。
    ///   - updateItem: 用户做出选择的更新项。
    ///   - state: 更新过程中的当前状态。
    func updater(_ updater: SPUUpdater, userDidMake choice: SPUUserUpdateChoice, forUpdate updateItem: SUAppcastItem, state: SPUUserUpdateState) {
        switch choice {
        case .skip:
            // 跳过
            print("\(#function) 用户点击 跳过这个版本")
        case .install:
            // 安装
            print("\(#function) 用户点击 安装更新")
        case .dismiss:
            // 稍后提醒
            print("\(#function) 用户点击 稍后提醒")
        @unknown default:
            break
        }
    }
    
    
    
    
}

#else

import Cocoa



/// LCUpdateManager 管理应用的更新检测和链接生成
public class LCUpdateManager: NSObject {
    
    /// 单例对象，提供全局访问点
    public static let shared = LCUpdateManager()
    
    /// 获取当前地区的国家代码（小写字母）
    /// 根据设备的区域设置动态获取国家代码，用于生成与地区相关的链接
    private var countryCode: String {
        return Locale.current.regionCode?.lowercased() ?? ""
    }
    
    /// 应用的唯一标识符（App Store 上的应用 ID）
    /// 设置后会自动更新相关链接，如应用商店链接、更新检测链接和介绍页面链接
    public var appID: String = "" {
        didSet {
            // App Store 下载链接
            appStoreUrl = "itms-apps://itunes.apple.com/cn/app/id\(appID)"
            // App 更新检测链接
            appUpdateUrl = "http://itunes.apple.com/lookup?id=\(appID)&country=\(countryCode)"
            // App 介绍页面链接
            appIntroduceUrl = "https://apps.apple.com/cn/app/id\(appID)"
        }
    }
    
    /// App Store 下载链接
    /// 私有设置，只能通过该类读取
    private(set) var appStoreUrl: String = ""
    
    /// App 更新检测链接
    /// 私有设置，只能通过该类读取
    private(set) var appUpdateUrl: String = ""
    
    /// 应用的介绍页面链接（仅限国内使用）
    /// 私有设置，只能通过该类读取
    private(set) var appIntroduceUrl: String = ""
    
    /// 主程序的版本号
    /// 通过读取 Info.plist 文件中的 `CFBundleShortVersionString` 字段获取当前应用版本
    private static let kAPP_Version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    
    
    /// 检查新版本（Apple Store）
    /// - Parameter showAlertIfLatest:
    ///   - `true`：如果当前已经是最新版本，弹出提示框显示“已是最新版本”。
    ///   - `false`：如果当前已经是最新版本，不弹出任何提示框。
    public static func checkNewVersion(showAlertIfLatest: Bool) {
        
        /// 定义一个变量，根据系统语言判断，来存储对应语言环境的请求URL
        var urlStr: String = ""
        
        // 获取当前系统语言
        guard let primaryLanguage = Locale.preferredLanguages.first else {
            print("无法确定当前系统语言")
            // 在这里可以执行错误处理或返回
            fatalError("无法确定当前系统语言")
        }
        
        // 根据语言设置不同的更新 URL
        if Locale(identifier: primaryLanguage).languageCode == "zh" {
            print("当前系统语言为中文")
            urlStr = LCUpdateManager.shared.appUpdateUrl
        } else {
            print("当前系统语言为非中文")
            urlStr =  LCUpdateManager.shared.appUpdateUrl
        }
        
        guard let url = URL(string: urlStr) else { return }
        
        // 发起网络请求
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // 处理网络请求返回的数据
            guard let data = data else { return }
            do {
                // 解析 JSON 数据
                guard let resp = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let resultCount = resp["resultCount"] as? Int, resultCount > 0,
                      let resultsArray = resp["results"] as? [[String: Any]],
                      let version = resultsArray[0]["version"] as? String,
                      let info = resultsArray[0]["releaseNotes"] as? String else { return }
                
                // 检查版本号
                // kAPP_Version
                // 1.0.0
                if version.compare(kAPP_Version, options: .numeric) == .orderedDescending {
                    // 如果有新版本，显示提示信息
                    DispatchQueue.main.async {
                        print("新版本。。。")
                        print(info)
                        // 创建并显示更新提示窗口
                        let wc = LCUpdateWindowController()
                        wc.showNewVersion(newVersion: version, info: info)
                        wc.window?.makeKeyAndOrderFront(nil)
                        NSApp.activate(ignoringOtherApps: true) // 激活应用程序并忽略其他应用
                    }
                } else {
                    // 没有更新的版本
                    print("没有更新的版本")
                    
                    if showAlertIfLatest {
                        DispatchQueue.main.async {
                            LCUpdateManager.showNoUpdateAlert()
                        }
                    }
                    
                }
            } catch {
                // JSON 解析错误
                print("Error parsing JSON: \(error)")
            }
        }
        
        // 启动网络请求任务
        task.resume()
    }
    
    
    /// 显示`“已是最新版本”`的提示
    private static func showNoUpdateAlert() {
        let alert = NSAlert()
        // 图标
        alert.icon = NSImage (named: NSImage.applicationIconName)
        
        // AppStore
        // 信息标题
        alert.messageText = LCUpdateManagerLocalizeString("Kind tips")
        alert.informativeText = LCUpdateManagerLocalizeString("Latest version")
        alert.addButton(withTitle: LCUpdateManagerLocalizeString("Sure"))
        alert.alertStyle = .warning
        
        // 帮助按钮
        alert.showsHelp = false
        
        // 指定警报是否包括复选框
        alert.showsSuppressionButton = false
        
        alert.runModal()
    }
    
    
    /// 判断`应用过期时间`
    /// - Parameters:
    ///   - year: 年份
    ///   - month: 月份
    ///   - day: 日期
    public func judgeAppExpire(year: Int, month: Int, day: Int) {
        let calendar = Calendar.current
        // 获取当前日期
        let currentDate = Date()
        // 创建给定的日期
        let expirationDate = calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? currentDate
        
        // 比较《给定的日期》是否超过《当前日期》，超过指定日期，显示警告
        if currentDate > expirationDate {
            // 过期了
            let alert = NSAlert()
            alert.messageText = LCUpdateManagerLocalizeString("Kind tips") // 提示标题
            alert.informativeText = String(format: LCUpdateManagerLocalizeString("Expire Tips"), kAppName)       // 提示内容
            alert.addButton(withTitle: LCUpdateManagerLocalizeString("Click to download"))      // 按钮标题
            alert.alertStyle = .warning
            
            // 0.弹窗
            alert.runModal()
            
            // 1.使用浏览器打开链接
            NSWorkspace.shared.open(URL(string: appIntroduceUrl)!)
            
            // 2.退出 app
            NSApp.terminate(nil)
        }
    }
    
    
    
    /// 根据`系统版本`判断`试用到期`
    /// - Parameter osVersion: 系统版本字符串，格式如 "X.Y.Z"
    public func judgeAppExpire(withOSVersion osVersion: String) {
        // 获取当前系统版本号
        let sv = ProcessInfo.processInfo.operatingSystemVersion
        let sysVersion = "\(sv.majorVersion).\(sv.minorVersion).\(sv.patchVersion)"
        // 大于、等于设置的 系统版本
        if sysVersion.compare(osVersion, options: .numeric) != .orderedAscending {
            let alert = NSAlert()
            alert.messageText = LCUpdateManagerLocalizeString("Kind tips")
            alert.informativeText = String(format: LCUpdateManagerLocalizeString("OS Expire Tips"), kAppName)
            alert.addButton(withTitle: LCUpdateManagerLocalizeString("Click to update"))
            alert.alertStyle = .warning
            // 0.弹窗
            alert.runModal()
            // 1.使用浏览器打开链接
            NSWorkspace.shared.open(URL(string: appIntroduceUrl)!)
            
            // 2.退出 app
            NSApp.terminate(nil)
        }
    }
    
}


#endif
