//
//  MetasViewModel.swift
//  LifeOS
//
//  ViewModel para gerenciamento de Metas Financeiras
//

import Foundation
import Combine
import SwiftUI

// MARK: - Metas ViewModel
@MainActor
final class MetasViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var metas: [MetaModel] = []
    @Published var mostrarFormulario = false
    @Published var metaEditando: MetaModel?
    @Published var carregando = false
    @Published var mensagemErro: String?
    @Published var busca = ""
    
    // MARK: - Services
    private let coreData = CoreDataService.shared
    
    // MARK: - Computed Properties
    var metasFiltradas: [MetaModel] {
        if busca.isEmpty {
            return metas.sorted { $0.progresso > $1.progresso }
        } else {
            return metas
                .filter { $0.nome.localizedCaseInsensitiveContains(busca) }
                .sorted { $0.progresso > $1.progresso }
        }
    }
    
    var metasCompletas: [MetaModel] {
        metas.filter { $0.completa }
    }
    
    var metasEmAndamento: [MetaModel] {
        metas.filter { !$0.completa }
    }
    
    var totalValorMetas: Decimal {
        metas.reduce(0) { $0 + $1.valorTotal }
    }
    
    var totalAcumulado: Decimal {
        metas.reduce(0) { $0 + $1.valorAcumulado }
    }
    
    var progressoGeral: Double {
        guard totalValorMetas > 0 else { return 0 }
        return Double(truncating: totalAcumulado as NSNumber) / Double(truncating: totalValorMetas as NSNumber)
    }
    
    // MARK: - Initialization
    init() {
        carregarMetas()
    }
    
    // MARK: - Public Methods
    
    /// Carrega todas as metas
    func carregarMetas() {
        carregando = true
        metas = coreData.buscarMetas()
        carregando = false
    }
    
    /// Adiciona uma nova meta
    func adicionarMeta(_ meta: MetaModel) {
        do {
            try coreData.criarMeta(meta)
            carregarMetas()
            mostrarFormulario = false
        } catch {
            mensagemErro = "Erro ao adicionar meta: \(error.localizedDescription)"
        }
    }
    
    /// Atualiza uma meta existente
    func atualizarMeta(_ meta: MetaModel) {
        do {
            try coreData.atualizarMeta(meta)
            carregarMetas()
            mostrarFormulario = false
            metaEditando = nil
        } catch {
            mensagemErro = "Erro ao atualizar meta: \(error.localizedDescription)"
        }
    }
    
    /// Deleta uma meta
    func deletarMeta(_ meta: MetaModel) {
        do {
            try coreData.deletarMeta(id: meta.id)
            carregarMetas()
        } catch {
            mensagemErro = "Erro ao deletar meta: \(error.localizedDescription)"
        }
    }
    
    /// Adiciona valor ao acumulado de uma meta
    func adicionarValor(para meta: MetaModel, valor: Decimal) {
        do {
            try coreData.adicionarValorMeta(id: meta.id, valor: valor)
            carregarMetas()
        } catch {
            mensagemErro = "Erro ao adicionar valor à meta: \(error.localizedDescription)"
        }
    }
    
    /// Inicia edição de uma meta
    func editarMeta(_ meta: MetaModel) {
        metaEditando = meta
        mostrarFormulario = true
    }
    
    /// Cancela o formulário
    func cancelarFormulario() {
        mostrarFormulario = false
        metaEditando = nil
    }
    
    /// Limpa a busca
    func limparBusca() {
        busca = ""
    }
}
