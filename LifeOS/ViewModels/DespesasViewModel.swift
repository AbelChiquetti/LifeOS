//
//  DespesasViewModel.swift
//  LifeOS
//
//  ViewModel para gerenciamento de Despesas
//

import Foundation
import Combine
import SwiftUI

// MARK: - Despesas ViewModel
@MainActor
final class DespesasViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var despesas: [DespesaModel] = []
    @Published var mostrarFormulario = false
    @Published var despesaEditando: DespesaModel?
    @Published var carregando = false
    @Published var mensagemErro: String?
    @Published var busca = ""
    @Published var filtroStatus: StatusDespesa?
    @Published var filtroCategoria: String?
    
    // MARK: - Services
    private let coreData = CoreDataService.shared
    private let notificacoes = NotificationService.shared
    
    // MARK: - Computed Properties
    var despesasFiltradas: [DespesaModel] {
        var resultado = despesas
        
        // Filtro de busca
        if !busca.isEmpty {
            resultado = resultado.filter { $0.descricao.localizedCaseInsensitiveContains(busca) }
        }
        
        // Filtro de status
        if let status = filtroStatus {
            resultado = resultado.filter { $0.status == status }
        }
        
        // Filtro de categoria
        if let categoria = filtroCategoria {
            resultado = resultado.filter { $0.categoria == categoria }
        }
        
        return resultado.sorted { $0.dataVencimento > $1.dataVencimento }
    }
    
    var categorias: [String] {
        Array(Set(despesas.map { $0.categoria })).sorted()
    }
    
    var totalDespesas: Decimal {
        despesas.reduce(0) { $0 + $1.valor }
    }
    
    var totalDespesasPagas: Decimal {
        despesas.filter { $0.status == .pago }.reduce(0) { $0 + $1.valor }
    }
    
    var totalDespesasPendentes: Decimal {
        despesas.filter { $0.status == .naoPago }.reduce(0) { $0 + $1.valor }
    }
    
    var despesasAtrasadas: [DespesaModel] {
        despesas.filter { $0.estaAtrasada }
    }
    
    var despesasProximasVencimento: [DespesaModel] {
        despesas.filter { $0.proximaDoVencimento }
    }
    
    // MARK: - Initialization
    init() {
        carregarDespesas()
        configurarNotificacoes()
    }
    
    // MARK: - Public Methods
    
    /// Carrega todas as despesas
    func carregarDespesas() {
        carregando = true
        despesas = coreData.buscarDespesas()
        carregando = false
    }
    
    /// Adiciona uma nova despesa
    func adicionarDespesa(_ despesa: DespesaModel) {
        do {
            try coreData.criarDespesa(despesa)
            carregarDespesas()
            mostrarFormulario = false
            
            // Agenda notificações se não estiver paga
            Task {
                await notificacoes.agendarNotificacoesDespesa(despesa)
            }
        } catch {
            mensagemErro = "Erro ao adicionar despesa: \(error.localizedDescription)"
        }
    }
    
    /// Atualiza uma despesa existente
    func atualizarDespesa(_ despesa: DespesaModel) {
        do {
            try coreData.atualizarDespesa(despesa)
            carregarDespesas()
            mostrarFormulario = false
            despesaEditando = nil
            
            // Atualiza notificações
            Task {
                await notificacoes.removerNotificacoesDespesa(id: despesa.id)
                if despesa.status == .naoPago {
                    await notificacoes.agendarNotificacoesDespesa(despesa)
                }
            }
        } catch {
            mensagemErro = "Erro ao atualizar despesa: \(error.localizedDescription)"
        }
    }
    
    /// Deleta uma despesa
    func deletarDespesa(_ despesa: DespesaModel) {
        do {
            try coreData.deletarDespesa(id: despesa.id)
            
            // Remove notificações
            Task {
                await notificacoes.removerNotificacoesDespesa(id: despesa.id)
            }
            
            carregarDespesas()
        } catch {
            mensagemErro = "Erro ao deletar despesa: \(error.localizedDescription)"
        }
    }
    
    /// Marca uma despesa como paga
    func marcarComoPaga(_ despesa: DespesaModel) {
        var despesaAtualizada = despesa
        despesaAtualizada.status = .pago
        despesaAtualizada.dataPagamento = Date()
        atualizarDespesa(despesaAtualizada)
    }
    
    /// Inicia edição de uma despesa
    func editarDespesa(_ despesa: DespesaModel) {
        despesaEditando = despesa
        mostrarFormulario = true
    }
    
    /// Cancela o formulário
    func cancelarFormulario() {
        mostrarFormulario = false
        despesaEditando = nil
    }
    
    /// Limpa os filtros
    func limparFiltros() {
        busca = ""
        filtroStatus = nil
        filtroCategoria = nil
    }
    
    // MARK: - Private Methods
    
    /// Configura notificações
    private func configurarNotificacoes() {
        Task {
            do {
                try await notificacoes.solicitarPermissao()
                await notificacoes.atualizarTodasNotificacoes()
            } catch {
                print("Erro ao configurar notificações: \(error)")
            }
        }
    }
}
