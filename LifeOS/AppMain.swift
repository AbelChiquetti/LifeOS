//
//  AppMain.swift
//  LifeOS
//
//  Ponto de entrada do app macOS com SwiftUI.
//

import SwiftUI
import UserNotifications
import AppKit

// IMPORTANTE: Certifique-se de que não existe outro arquivo com `@main` no projeto.
// Se houver, remova o atributo `@main` do outro arquivo para evitar `Invalid redeclaration of 'LifeOSApp'`.
@main
struct LifeOSApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("usuarioNome") private var usuarioNome: String = "Abel"
    
    init() {
        Task {
            try? await NotificationService.shared.solicitarPermissao()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, CoreDataStack.shared.viewContext)
                .frame(minWidth: 1000, minHeight: 700)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 1200, height: 800)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About LifeOS", action: mostrarSobre)
            }
        }
        
        Settings {
            SettingsView(usuarioNome: $usuarioNome)
        }
    }
    
    private func mostrarSobre() {
        let info: [NSApplication.AboutPanelOptionKey: Any] = [
            .applicationName: "LifeOS",
            .applicationVersion: "1.0.0 (build 2025.11.15)",
            .credits: "Criado por Abel Chiquetti\nRepositório: http://github.com/AbelChiquetti/LifeOS\nLicença: Creative Commons BY-NC 4.0 (uso não comercial)\nStatus: App em desenvolvimento"
        ]
        NSApp.orderFrontStandardAboutPanel(options: info)
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configura o centro de notificações
        UNUserNotificationCenter.current().delegate = self
    }
}

// MARK: - Notification Delegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}

