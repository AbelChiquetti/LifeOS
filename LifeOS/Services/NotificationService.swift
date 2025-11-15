//
//  NotificationService.swift
//  LifeOS
//
//  Serviço de notificações para despesas
//

import Foundation
import UserNotifications

// MARK: - Notification Service
/// Gerencia notificações de despesas vencidas e próximas do vencimento
final class NotificationService {
    
    // MARK: - Singleton
    static let shared = NotificationService()
    private init() {}
    
    private let center = UNUserNotificationCenter.current()
    
    // MARK: - Permissões
    
    /// Solicita permissão para enviar notificações
    func solicitarPermissao() async throws {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }
    
    /// Verifica se as notificações estão autorizadas
    func verificarAutorizacao() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    // MARK: - Agendar Notificações
    
    /// Agenda notificações para uma despesa
    func agendarNotificacoesDespesa(_ despesa: DespesaModel) async {
        guard despesa.status == .naoPago else { return }
        
        // Remove notificações antigas desta despesa
        await removerNotificacoesDespesa(id: despesa.id)
        
        // Notificação 3 dias antes
        if let data3Dias = Calendar.current.date(byAdding: .day, value: -3, to: despesa.dataVencimento),
           data3Dias > Date() {
            await agendarNotificacao(
                id: "\(despesa.id.uuidString)-3dias",
                titulo: "Despesa vence em 3 dias",
                corpo: "\(despesa.descricao) - R$ \(formatarValor(despesa.valor))",
                data: data3Dias
            )
        }
        
        // Notificação no dia do vencimento
        if despesa.dataVencimento > Date() {
            await agendarNotificacao(
                id: "\(despesa.id.uuidString)-vencimento",
                titulo: "Despesa vence hoje!",
                corpo: "\(despesa.descricao) - R$ \(formatarValor(despesa.valor))",
                data: despesa.dataVencimento
            )
        }
    }
    
    /// Agenda uma notificação genérica
    private func agendarNotificacao(id: String, titulo: String, corpo: String, data: Date) async {
        let content = UNMutableNotificationContent()
        content.title = titulo
        content.body = corpo
        content.sound = .default
        content.categoryIdentifier = "DESPESA"
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: data)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        do {
            try await center.add(request)
        } catch {
            print("Erro ao agendar notificação: \(error)")
        }
    }
    
    /// Remove notificações de uma despesa específica
    func removerNotificacoesDespesa(id: UUID) async {
        let ids = [
            "\(id.uuidString)-3dias",
            "\(id.uuidString)-vencimento"
        ]
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }
    
    /// Atualiza notificações para todas as despesas não pagas
    func atualizarTodasNotificacoes() async {
        let despesas = CoreDataService.shared.buscarDespesasNaoPagas()
        
        for despesa in despesas {
            await agendarNotificacoesDespesa(despesa)
        }
    }
    
    /// Remove todas as notificações pendentes
    func removerTodasNotificacoes() {
        center.removeAllPendingNotificationRequests()
    }
    
    /// Lista todas as notificações pendentes (para debug)
    func listarNotificacoesPendentes() async -> [UNNotificationRequest] {
        await center.pendingNotificationRequests()
    }
    
    // MARK: - Helpers
    
    private func formatarValor(_ valor: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: valor as NSNumber) ?? "0,00"
    }
}
