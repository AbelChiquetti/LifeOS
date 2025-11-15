//
//  DashboardView.swift
//  LifeOS
//
//  Dashboard principal com métricas e gráficos
//

import SwiftUI
import Charts

// MARK: - Dashboard View
struct DashboardView: View {
    @StateObject private var vm = DashboardViewModel()
    
    var body: some View {
        ZStack {
            AnimatedBackground()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Métricas principais
                    metricasView
                    
                    // Gráfico mensal
                    graficoMensalView
                    
                    // Metas em destaque
                    if !vm.metasResumo.isEmpty {
                        metasView
                    }
                    
                    // Percentual por categoria
                    if !vm.percentualPorCategoria.isEmpty {
                        categoriesView
                    }
                    
                    // Últimas movimentações
                    if !vm.ultimasMovimentacoes.isEmpty {
                        movimentacoesView
                    }
                }
                .padding(24)
            }
        }
        .navigationTitle("Dashboard")
        .onAppear {
            vm.carregarDadosIniciais()
        }
        .refreshable {
            vm.atualizar()
        }
    }
    
    // MARK: - Métricas
    private var metricasView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                MetricCard(
                    titulo: "Saldo Atual",
                    valor: vm.saldoAtual.formatadoBRL,
                    icone: "dollarsign.circle.fill",
                    cor: .blue
                )
                
                MetricCard(
                    titulo: "Receitas do Mês",
                    valor: vm.totalReceitasMes.formatadoBRL,
                    icone: "arrow.down.circle.fill",
                    cor: .green
                )
            }
            
            MetricCard(
                titulo: "Despesas do Mês",
                valor: vm.totalDespesasMes.formatadoBRL,
                icone: "arrow.up.circle.fill",
                cor: .red
            )
        }
    }
    
    // MARK: - Gráfico Mensal
    private var graficoMensalView: some View {
        GlassCard(padding: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Label("Evolução Mensal", systemImage: "chart.xyaxis.line")
                    .font(.headline)
                
                if vm.seriesMensal.isEmpty {
                    Text("Sem dados suficientes")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                } else {
                    Chart {
                        ForEach(Array(vm.seriesMensal.enumerated()), id: \.offset) { index, valor in
                            LineMark(
                                x: .value("Mês", nomeDoMes(paraIndice: index)),
                                y: .value("Valor", valor)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                            
                            AreaMark(
                                x: .value("Mês", nomeDoMes(paraIndice: index)),
                                y: .value("Valor", valor)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .purple.opacity(0.1)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(values: .automatic) { _ in
                            AxisValueLabel()
                                .font(.caption)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisValueLabel {
                                if let doubleValue = value.as(Double.self) {
                                    Text(FormatHelper.formatarBRL(doubleValue))
                                        .font(.caption2)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Metas
    private var metasView: some View {
        GlassCard(padding: 20) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Suas Metas", systemImage: "target")
                        .font(.headline)
                    Spacer()
                    NavigationLink {
                        MetasView()
                    } label: {
                        Text("Ver todas")
                            .font(.subheadline)
                    }
                }
                
                ForEach(vm.metasResumo.prefix(3)) { meta in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(meta.nome)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(meta.percentual)%")
                                .font(.subheadline)
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        
                        ProgressView(value: meta.progresso)
                            .tint(Color(hex: meta.cor) ?? .blue)
                        
                        HStack {
                            Text(meta.valorAcumulado.formatadoBRL)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(meta.valorTotal.formatadoBRL)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if meta.id != vm.metasResumo.prefix(3).last?.id {
                        Divider()
                    }
                }
            }
        }
    }
    
    // MARK: - Categorias
    private var categoriesView: some View {
        GlassCard(padding: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Label("Despesas por Categoria", systemImage: "chart.pie.fill")
                    .font(.headline)
                
                // Gráfico de pizza
                Chart(vm.percentualPorCategoria, id: \.categoria) { item in
                    SectorMark(
                        angle: .value("Valor", item.valor),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(by: .value("Categoria", item.categoria))
                }
                .frame(height: 200)
                
                // Legenda
                VStack(spacing: 8) {
                    ForEach(vm.percentualPorCategoria, id: \.categoria) { item in
                        HStack {
                            Text(item.categoria)
                                .font(.subheadline)
                            Spacer()
                            Text("\(Int(item.valor))%")
                                .font(.subheadline)
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Movimentações
    private var movimentacoesView: some View {
        GlassCard(padding: 20) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label("Últimas Movimentações", systemImage: "list.bullet")
                        .font(.headline)
                    Spacer()
                }
                
                ForEach(vm.ultimasMovimentacoes.prefix(10), id: \.data) { mov in
                    HStack {
                        Image(systemName: mov.tipo == "receita" ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                            .foregroundStyle(mov.tipo == "receita" ? .green : .red)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(mov.descricao)
                                .font(.subheadline)
                            Text(mov.data.formatado)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(mov.valor.formatadoBRL)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(mov.tipo == "receita" ? .green : .red)
                    }
                    .padding(.vertical, 4)
                    
                    if mov.data != vm.ultimasMovimentacoes.prefix(10).last?.data {
                        Divider()
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func nomeDoMes(paraIndice index: Int) -> String {
        let calendar = Calendar.current
        guard let data = calendar.date(byAdding: .month, value: index - 11, to: Date()) else {
            return ""
        }
        return FormatHelper.nomeDoMes(data)
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
}
