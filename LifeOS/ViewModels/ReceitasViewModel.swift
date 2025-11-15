//
//  ReceitasViewModel.swift
//  LifeOS
//
//  ViewModel para gerenciamento de Receitas
//

import Foundation
import Combine
import SwiftUI

// MARK: - Receitas ViewModel
@MainActor
final class ReceitasViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var receitas: [ReceitaModel] = []
    @Published var mostrarFormulario = false
    @Published var receitaEditando: ReceitaModel?
    @Published var carregando = false
    @Published var mensagemErro: String?
    @Published var busca = ""
    @Published var filtroCategoria: String?
    
    // MARK: - Services
    private let coreData = CoreDataService.shared
    
    // MARK: - Computed Properties
    var receitasFiltradas: [ReceitaModel] {
        var resultado = receitas
        
        // Filtro de busca
        if !busca.isEmpty {
            resultado = resultado.filter { $0.descricao.localizedCaseInsensitiveContains(busca) }
        }
        
        // Filtro de categoria
        if let categoria = filtroCategoria {
            resultado = resultado.filter { $0.categoria == categoria }
        }
        
        return resultado.sorted { $0.data > $1.data }
    }
    
    var categorias: [String] {
        Array(Set(receitas.compactMap { $0.categoria })).sorted()
    }
    
    var totalReceitas: Decimal {
        receitas.reduce(0) { $0 + $1.valor }
    }
    
    // MARK: - Initialization
    init() {
        carregarReceitas()
    }
    
    // MARK: - Public Methods
    
    /// Carrega todas as receitas
    func carregarReceitas() {
        carregando = true
        receitas = coreData.buscarReceitas()
        carregando = false
    }
    
    /// Adiciona uma nova receita
    func adicionarReceita(_ receita: ReceitaModel) {
        do {
            try coreData.criarReceita(receita)
            carregarReceitas()
            mostrarFormulario = false
            
            // Se tem meta associada, adiciona o valor à meta
            if let metaId = receita.metaAssociada {
                try coreData.adicionarValorMeta(id: metaId, valor: receita.valor)
            }
        } catch {
            mensagemErro = "Erro ao adicionar receita: \(error.localizedDescription)"
        }
    }
    
    /// Atualiza uma receita existente
    func atualizarReceita(_ receita: ReceitaModel) {
        do {
            try coreData.atualizarReceita(receita)
            carregarReceitas()
            mostrarFormulario = false
            receitaEditando = nil
        } catch {
            mensagemErro = "Erro ao atualizar receita: \(error.localizedDescription)"
        }
    }
    
    /// Deleta uma receita
    func deletarReceita(_ receita: ReceitaModel) {
        do {
            try coreData.deletarReceita(id: receita.id)
            carregarReceitas()
        } catch {
            mensagemErro = "Erro ao deletar receita: \(error.localizedDescription)"
        }
    }
    
    /// Inicia edição de uma receita
    func editarReceita(_ receita: ReceitaModel) {
        receitaEditando = receita
        mostrarFormulario = true
    }
    
    /// Cancela o formulário
    func cancelarFormulario() {
        mostrarFormulario = false
        receitaEditando = nil
    }
    
    /// Limpa os filtros
    func limparFiltros() {
        busca = ""
        filtroCategoria = nil
    }
}
