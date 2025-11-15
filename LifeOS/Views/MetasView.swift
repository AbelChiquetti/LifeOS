//
//  MetasView.swift
//  LifeOS
//
//  Tela de gerenciamento de Metas Financeiras
//

import SwiftUI

// MARK: - Metas View
struct MetasView: View {
    @StateObject private var vm = MetasViewModel()
    @State private var mostrarDetalhes: MetaModel?
    
    var body: some View {
        ZStack {
            LiquidGlassPanel()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Cabeçalho com progresso geral
                cabecalhoView
                    .padding()
                
                Divider()
                
                // Busca
                buscaView
                    .padding()
                
                // Lista de metas
                if vm.carregando {
                    LoadingView(mensagem: "Carregando metas...")
                } else if vm.metasFiltradas.isEmpty {
                    EmptyStateView(
                        icone: "target",
                        titulo: "Nenhuma meta",
                        mensagem: vm.busca.isEmpty ? "Crie sua primeira meta financeira" : "Nenhuma meta encontrada",
                        botaoTitulo: "Nova Meta",
                        botaoAction: { vm.mostrarFormulario = true }
                    )
                } else {
                    listaMetasView
                }
            }
        }
        .navigationTitle("Metas Financeiras")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    vm.mostrarFormulario = true
                } label: {
                    Label("Nova Meta", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $vm.mostrarFormulario) {
            MetaFormView(vm: vm, meta: vm.metaEditando)
        }
        .sheet(item: $mostrarDetalhes) { meta in
            MetaDetailView(meta: meta, vm: vm)
        }
    }
    
    // MARK: - Cabeçalho
    private var cabecalhoView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                MetricCard(
                    titulo: "Total em Metas",
                    valor: vm.totalValorMetas.formatadoBRL,
                    icone: "target",
                    cor: .blue
                )
                
                MetricCard(
                    titulo: "Acumulado",
                    valor: vm.totalAcumulado.formatadoBRL,
                    icone: "chart.bar.fill",
                    cor: .green
                )
            }
            
            // Progresso geral
            ProgressCard(
                titulo: "Progresso Geral",
                progresso: vm.progressoGeral,
                valorAtual: vm.totalAcumulado.formatadoBRL,
                valorTotal: vm.totalValorMetas.formatadoBRL,
                cor: .blue
            )
        }
    }
    
    // MARK: - Busca
    private var buscaView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Buscar metas...", text: $vm.busca)
                .textFieldStyle(.plain)
            
            if !vm.busca.isEmpty {
                Button {
                    vm.busca = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
    
    // MARK: - Lista
    private var listaMetasView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(vm.metasFiltradas) { meta in
                    MetaRow(meta: meta, vm: vm)
                        .onTapGesture {
                            mostrarDetalhes = meta
                        }
                        .contextMenu {
                            Button {
                                vm.editarMeta(meta)
                            } label: {
                                Label("Editar", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                vm.deletarMeta(meta)
                            } label: {
                                Label("Deletar", systemImage: "trash")
                            }
                        }
                }
            }
            .padding()
        }
    }
}

// MARK: - Meta Row
struct MetaRow: View {
    let meta: MetaModel
    let vm: MetasViewModel
    
    var body: some View {
        GlassCard(padding: 20) {
            VStack(alignment: .leading, spacing: 16) {
                // Cabeçalho
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(meta.nome)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        if let descricao = meta.descricao {
                            Text(descricao)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Badge de conclusão
                    if meta.completa {
                        AlertBadge(texto: "Concluída", cor: .green)
                    } else {
                        Text("\(meta.percentual)%")
                            .font(.title3)
                            .fontWeight(.bold)
                            .monospacedDigit()
                    }
                }
                
                // Barra de progresso
                VStack(spacing: 8) {
                    ProgressView(value: meta.progresso)
                        .tint(Color(hex: meta.cor) ?? .blue)
                        .scaleEffect(y: 1.5)
                    
                    HStack {
                        Text(meta.valorAcumulado.formatadoBRL)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text(meta.valorTotal.formatadoBRL)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Informações adicionais
                HStack(spacing: 16) {
                    Label(
                        "Faltam \(meta.valorRestante.formatadoBRL)",
                        systemImage: "chart.line.uptrend.xyaxis"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    
                    if let diasRestantes = meta.diasRestantes {
                        Label(
                            "\(diasRestantes) dias",
                            systemImage: "calendar"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Meta Detail View
struct MetaDetailView: View {
    let meta: MetaModel
    let vm: MetasViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var mostrarAdicionarValor = false
    @State private var valorAdicionar = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassPanel()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Card de progresso grande
                        GlassCard(padding: 24) {
                            VStack(spacing: 20) {
                                // Título
                                Text(meta.nome)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if let descricao = meta.descricao {
                                    Text(descricao)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                // Progresso circular
                                ZStack {
                                    Circle()
                                        .stroke(Color.secondary.opacity(0.2), lineWidth: 20)
                                    
                                    Circle()
                                        .trim(from: 0, to: meta.progresso)
                                        .stroke(
                                            Color(hex: meta.cor) ?? .blue,
                                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                        )
                                        .rotationEffect(.degrees(-90))
                                        .animation(.easeInOut, value: meta.progresso)
                                    
                                    VStack(spacing: 4) {
                                        Text("\(meta.percentual)%")
                                            .font(.system(size: 48, weight: .bold, design: .rounded))
                                        
                                        Text("Concluído")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .frame(width: 200, height: 200)
                                .padding()
                                
                                // Valores
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("Acumulado")
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Text(meta.valorAcumulado.formatadoBRL)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    Divider()
                                    
                                    HStack {
                                        Text("Meta")
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Text(meta.valorTotal.formatadoBRL)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    Divider()
                                    
                                    HStack {
                                        Text("Restante")
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                        Text(meta.valorRestante.formatadoBRL)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.orange)
                                    }
                                }
                                .font(.subheadline)
                            }
                        }
                        
                        // Informações adicionais
                        if let prazo = meta.prazo {
                            GlassCard {
                                HStack {
                                    Label("Prazo", systemImage: "calendar")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(prazo.formatado)
                                            .fontWeight(.medium)
                                        
                                        if let dias = meta.diasRestantes {
                                            Text("\(dias) dias restantes")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Botão para adicionar valor
                        if !meta.completa {
                            Button {
                                mostrarAdicionarValor = true
                            } label: {
                                Label("Adicionar Valor", systemImage: "plus.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Color(hex: meta.cor) ?? .blue)
                        } else {
                            GlassCard {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title)
                                        .foregroundStyle(.green)
                                    
                                    Text("Meta concluída! 🎉")
                                        .font(.headline)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Detalhes da Meta")
#if os(macOS)
            // On macOS 13+, `toolbarTitleDisplayMode` is available
            .toolbarTitleDisplayMode(.inline)
#else
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        vm.editarMeta(meta)
                        dismiss()
                    } label: {
                        Label("Editar", systemImage: "pencil")
                    }
                }
            }
            .sheet(isPresented: $mostrarAdicionarValor) {
                adicionarValorSheet
            }
        }
    }
    
    // MARK: - Sheet para adicionar valor
    private var adicionarValorSheet: some View {
        NavigationStack {
            Form {
                Section("Adicionar Valor") {
                    TextField("Valor (R$)", text: $valorAdicionar)
#if canImport(UIKit)
                        .keyboardType(.decimalPad)
#endif
                    
                    Text("Valor atual: \(meta.valorAcumulado.formatadoBRL)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Adicionar Valor")
#if os(macOS)
            // On macOS 13+, `toolbarTitleDisplayMode` is available
            .toolbarTitleDisplayMode(.inline)
#else
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        mostrarAdicionarValor = false
                        valorAdicionar = ""
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Adicionar") {
                        if let valor = Decimal(string: valorAdicionar.replacingOccurrences(of: ",", with: ".")) {
                            vm.adicionarValor(para: meta, valor: valor)
                            mostrarAdicionarValor = false
                            valorAdicionar = ""
                            dismiss()
                        }
                    }
                    .disabled(valorAdicionar.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Meta Form View
struct MetaFormView: View {
    @ObservedObject var vm: MetasViewModel
    let meta: MetaModel?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var nome: String = ""
    @State private var valorTotal: String = ""
    @State private var valorAcumulado: String = ""
    @State private var descricao: String = ""
    @State private var prazo: Date = Date().addingTimeInterval(86400 * 365) // 1 ano
    @State private var temPrazo: Bool = false
    @State private var corSelecionada: String = "#007AFF"
    
    private let coresDisponiveis = [
        "#007AFF", "#FF3B30", "#34C759", "#FF9500",
        "#5856D6", "#FF2D55", "#64D2FF", "#FFD60A"
    ]
    
    init(vm: MetasViewModel, meta: MetaModel?) {
        self.vm = vm
        self.meta = meta
        
        if let meta = meta {
            _nome = State(initialValue: meta.nome)
            _valorTotal = State(initialValue: "\(meta.valorTotal)")
            _valorAcumulado = State(initialValue: "\(meta.valorAcumulado)")
            _descricao = State(initialValue: meta.descricao ?? "")
            _corSelecionada = State(initialValue: meta.cor)
            
            if let prazo = meta.prazo {
                _prazo = State(initialValue: prazo)
                _temPrazo = State(initialValue: true)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informações") {
                    TextField("Nome da meta", text: $nome)
                    
                    TextField("Valor total (R$)", text: $valorTotal)
#if canImport(UIKit)
                        .keyboardType(.decimalPad)
#endif
                    
                    TextField("Valor inicial acumulado (R$)", text: $valorAcumulado)
#if canImport(UIKit)
                        .keyboardType(.decimalPad)
#endif
                    
                    TextField("Descrição (opcional)", text: $descricao)
                }
                
                Section("Prazo") {
                    Toggle("Definir prazo", isOn: $temPrazo)
                    
                    if temPrazo {
                        DatePicker("Data limite", selection: $prazo, displayedComponents: .date)
                    }
                }
                
                Section("Cor") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(coresDisponiveis, id: \.self) { cor in
                            Circle()
                                .fill(Color(hex: cor) ?? .blue)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .strokeBorder(.white, lineWidth: corSelecionada == cor ? 3 : 0)
                                )
                                .onTapGesture {
                                    corSelecionada = cor
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(meta == nil ? "Nova Meta" : "Editar Meta")
#if os(macOS)
            // On macOS 13+, `toolbarTitleDisplayMode` is available
            .toolbarTitleDisplayMode(.inline)
#else
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        vm.cancelarFormulario()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        salvarMeta()
                    }
                    .disabled(nome.isEmpty || valorTotal.isEmpty)
                }
            }
        }
    }
    
    private func salvarMeta() {
        guard let valorTotalDecimal = Decimal(string: valorTotal.replacingOccurrences(of: ",", with: ".")) else { return }
        let valorAcumuladoDecimal = Decimal(string: valorAcumulado.replacingOccurrences(of: ",", with: ".")) ?? 0
        
        let novaMeta = MetaModel(
            id: meta?.id ?? UUID(),
            nome: nome,
            valorTotal: valorTotalDecimal,
            valorAcumulado: valorAcumuladoDecimal,
            prazo: temPrazo ? prazo : nil,
            descricao: descricao.isEmpty ? nil : descricao,
            cor: corSelecionada
        )
        
        if meta == nil {
            vm.adicionarMeta(novaMeta)
        } else {
            vm.atualizarMeta(novaMeta)
        }
        
        dismiss()
    }
}

// MARK: - Color Extension
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    MetasView()
}
