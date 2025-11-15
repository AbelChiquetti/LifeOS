//
//  DashboardViewModel.swift
//  LifeOS
//
//  ViewModel do Dashboard
//

import Foundation
import Combine
import SwiftUI
import WidgetKit

// MARK: - Dashboard Tab
enum DashboardTab: Hashable {
    case dashboard, receitas, despesas, metas, relatorios
}

// MARK: - Dashboard ViewModel
@MainActor
final class DashboardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var selectedTab: DashboardTab = .dashboard
    
    // Métricas principais
    @Published var saldoAtual: Decimal = 0
    @Published var totalReceitasMes: Decimal = 0
    @Published var totalDespesasMes: Decimal = 0
    
    // Dados para gráficos
    @Published var seriesMensal: [Double] = []
    @Published var percentualPorCategoria: [(categoria: String, valor: Double)] = []
    @Published var ultimasMovimentacoes: [(tipo: String, descricao: String, valor: Decimal, data: Date)] = []
    @Published var metasResumo: [MetaModel] = []
    
    // Estados
    @Published var carregando = false
    @Published var mensagemErro: String?
    
    // MARK: - Services
    private let coreData = CoreDataService.shared
    private let pdf = PDFExporterService.shared
    
    // MARK: - Initialization
    init() {
        carregarDadosIniciais()
    }
    
    // MARK: - Public Methods
    
    /// Carrega todos os dados do dashboard
    func carregarDadosIniciais() {
        carregando = true
        
        // Calcula métricas
        saldoAtual = coreData.calcularSaldoTotal()
        totalReceitasMes = coreData.calcularTotalReceitasMes()
        totalDespesasMes = coreData.calcularTotalDespesasMes()
        
        // Carrega dados para gráficos
        percentualPorCategoria = coreData.calcularPercentualPorCategoria()
        ultimasMovimentacoes = coreData.buscarUltimasMovimentacoes(limite: 10)
        metasResumo = coreData.buscarMetas()
        
        // Gera série mensal (últimos 12 meses)
        seriesMensal = gerarSerieMensal()
        
        carregando = false
    }
    
    /// Atualiza os dados do dashboard
    func atualizar() {
        carregarDadosIniciais()
    }
    
    /// Exporta relatório em PDF
    func exportarPDF() {
        do {
            let url = try pdf.gerarRelatorioFinanceiro()
            NSWorkspace.shared.activateFileViewerSelecting([url])
        } catch {
            mensagemErro = "Falha ao exportar PDF: \(error.localizedDescription)"
            print("Erro ao exportar PDF: \(error)")
        }
    }
    
    /// Sincroniza dados com os Widgets
    func sincronizarWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - Private Methods
    
    /// Gera série de dados dos últimos 12 meses
    private func gerarSerieMensal() -> [Double] {
        var series: [Double] = []
        let calendar = Calendar.current
        
        for i in 0..<12 {
            guard let mesInicio = calendar.date(byAdding: .month, value: -i, to: Date()),
                  let inicio = calendar.date(from: calendar.dateComponents([.year, .month], from: mesInicio)),
                  let fim = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: inicio) else {
                continue
            }
            
            // Busca receitas do mês
            let receitas = coreData.buscarReceitas().filter { $0.data >= inicio && $0.data <= fim }
            let totalReceitas = receitas.reduce(0.0) { $0 + Double(truncating: $1.valor as NSNumber) }
            
            series.insert(totalReceitas, at: 0)
        }
        
        return series
    }
}
