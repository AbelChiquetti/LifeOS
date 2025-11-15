//
//  DespesasView.swift
//  LifeOS
//
//  Tela de gerenciamento de Despesas
//

import SwiftUI

// MARK: - Despesas View
struct DespesasView: View {
    @StateObject private var vm = DespesasViewModel()
    @State private var mostrarDetalhes: DespesaModel?
    
    var body: some View {
        ZStack {
            LiquidGlassPanel()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Cabeçalho com métricas
                cabecalhoView
                    .padding()
                
                Divider()
                
                // Alertas
                if !vm.despesasAtrasadas.isEmpty || !vm.despesasProximasVencimento.isEmpty {
                    alertasView
                        .padding()
                }
                
                // Filtros e busca
                filtrosView
                    .padding()
                
                // Lista de despesas
                if vm.carregando {
                    LoadingView(mensagem: "Carregando despesas...")
                } else if vm.despesasFiltradas.isEmpty {
                    EmptyStateView(
                        icone: "arrow.up.circle",
                        titulo: "Nenhuma despesa",
                        mensagem: vm.busca.isEmpty ? "Adicione sua primeira despesa" : "Nenhuma despesa encontrada com os filtros",
                        botaoTitulo: "Nova Despesa",
                        botaoAction: { vm.mostrarFormulario = true }
                    )
                } else {
                    listaDespesasView
                }
            }
        }
        .navigationTitle("Despesas")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    vm.mostrarFormulario = true
                } label: {
                    Label("Nova Despesa", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $vm.mostrarFormulario) {
            DespesaFormView(vm: vm, despesa: vm.despesaEditando)
        }
        .sheet(item: $mostrarDetalhes) { despesa in
            DespesaDetailView(despesa: despesa, vm: vm)
        }
    }
    
    // MARK: - Cabeçalho
    private var cabecalhoView: some View {
        HStack(spacing: 12) {
            MetricCard(
                titulo: "Total",
                valor: vm.totalDespesas.formatadoBRL,
                icone: "creditcard.fill",
                cor: .red
            )
            
            MetricCard(
                titulo: "Pagas",
                valor: vm.totalDespesasPagas.formatadoBRL,
                icone: "checkmark.circle.fill",
                cor: .green
            )
            
            MetricCard(
                titulo: "Pendentes",
                valor: vm.totalDespesasPendentes.formatadoBRL,
                icone: "clock.fill",
                cor: .orange
            )
        }
    }
    
    // MARK: - Alertas
    private var alertasView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !vm.despesasAtrasadas.isEmpty {
                AlertBanner(
                    icone: "exclamationmark.triangle.fill",
                    titulo: "\(vm.despesasAtrasadas.count) despesa(s) atrasada(s)",
                    cor: .red
                )
            }
            
            if !vm.despesasProximasVencimento.isEmpty {
                AlertBanner(
                    icone: "bell.fill",
                    titulo: "\(vm.despesasProximasVencimento.count) despesa(s) próxima(s) do vencimento",
                    cor: .orange
                )
            }
        }
    }
    
    // MARK: - Filtros
    private var filtrosView: some View {
        VStack(spacing: 12) {
            // Campo de busca
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Buscar despesas...", text: $vm.busca)
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
            
            // Filtros de status e categoria
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        titulo: "Todos",
                        selecionado: vm.filtroStatus == nil
                    ) {
                        vm.filtroStatus = nil
                    }
                    
                    ForEach(StatusDespesa.allCases, id: \.self) { status in
                        FilterChip(
                            titulo: status.rawValue,
                            selecionado: vm.filtroStatus == status
                        ) {
                            vm.filtroStatus = status
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Lista
    private var listaDespesasView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(vm.despesasFiltradas) { despesa in
                    DespesaRow(despesa: despesa, vm: vm)
                        .onTapGesture {
                            mostrarDetalhes = despesa
                        }
                        .contextMenu {
                            if despesa.status == .naoPago {
                                Button {
                                    vm.marcarComoPaga(despesa)
                                } label: {
                                    Label("Marcar como Paga", systemImage: "checkmark.circle")
                                }
                            }
                            
                            Button {
                                vm.editarDespesa(despesa)
                            } label: {
                                Label("Editar", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                vm.deletarDespesa(despesa)
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

// MARK: - Despesa Row
struct DespesaRow: View {
    let despesa: DespesaModel
    let vm: DespesasViewModel
    
    var body: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(despesa.descricao)
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        Text(FormatHelper.textosDiasRestantes(despesa.dataVencimento))
                            .font(.caption)
                            .foregroundStyle(despesa.estaAtrasada ? .red : .secondary)
                        
                        Text("•")
                            .foregroundStyle(.secondary)
                        
                        Text(despesa.categoria)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Badges de status
                    HStack(spacing: 8) {
                        AlertBadge(
                            texto: despesa.status.rawValue,
                            cor: corParaStatus(despesa.status)
                        )
                        
                        if despesa.estaAtrasada {
                            AlertBadge(texto: "Atrasada", cor: .red)
                        } else if despesa.proximaDoVencimento {
                            AlertBadge(texto: "Vence em breve", cor: .orange)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text(despesa.valor.formatadoBRL)
                        .font(.headline)
                        .foregroundStyle(.red)
                    
                    if despesa.status == .naoPago {
                        Button {
                            vm.marcarComoPaga(despesa)
                        } label: {
                            Image(systemName: "checkmark.circle")
                                .font(.title3)
                                .foregroundStyle(.green)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    private func corParaStatus(_ status: StatusDespesa) -> Color {
        switch status {
        case .pago: return .green
        case .naoPago: return .orange
        case .atrasado: return .red
        }
    }
}

// MARK: - Alert Banner
struct AlertBanner: View {
    let icone: String
    let titulo: String
    let cor: Color
    
    var body: some View {
        HStack {
            Image(systemName: icone)
                .foregroundStyle(cor)
            Text(titulo)
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
        }
        .padding()
        .background(cor.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Despesa Detail View
struct DespesaDetailView: View {
    let despesa: DespesaModel
    let vm: DespesasViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassPanel()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Valor principal
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Valor")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text(despesa.valor.formatadoBRL)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(.red)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                        
                        // Status
                        GlassCard {
                            HStack {
                                Text("Status")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                AlertBadge(
                                    texto: despesa.status.rawValue,
                                    cor: despesa.status == .pago ? .green : .orange
                                )
                            }
                        }
                        
                        // Informações
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                InfoRow(titulo: "Descrição", valor: despesa.descricao)
                                Divider()
                                InfoRow(titulo: "Categoria", valor: despesa.categoria)
                                Divider()
                                InfoRow(titulo: "Vencimento", valor: despesa.dataVencimento.formatado)
                                Divider()
                                InfoRow(titulo: "Status", valor: FormatHelper.textosDiasRestantes(despesa.dataVencimento))
                                
                                if let dataPagamento = despesa.dataPagamento {
                                    Divider()
                                    InfoRow(titulo: "Pago em", valor: dataPagamento.formatado)
                                }
                            }
                        }
                        
                        // Ação rápida
                        if despesa.status == .naoPago {
                            Button {
                                vm.marcarComoPaga(despesa)
                                dismiss()
                            } label: {
                                Label("Marcar como Paga", systemImage: "checkmark.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Detalhes da Despesa")
#if os(iOS) || os(watchOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        vm.editarDespesa(despesa)
                        dismiss()
                    } label: {
                        Label("Editar", systemImage: "pencil")
                    }
                }
            }
        }
    }
}

// MARK: - Despesa Form View
struct DespesaFormView: View {
    @ObservedObject var vm: DespesasViewModel
    let despesa: DespesaModel?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var valor: String = ""
    @State private var descricao: String = ""
    @State private var categoria: String = ""
    @State private var dataVencimento: Date = Date()
    @State private var status: StatusDespesa = .naoPago
    
    private let categoriasPadrao = ["Moradia", "Transporte", "Alimentação", "Saúde", "Lazer", "Educação", "Outros"]
    
    init(vm: DespesasViewModel, despesa: DespesaModel?) {
        self.vm = vm
        self.despesa = despesa
        
        if let despesa = despesa {
            _valor = State(initialValue: "\(despesa.valor)")
            _descricao = State(initialValue: despesa.descricao)
            _categoria = State(initialValue: despesa.categoria)
            _dataVencimento = State(initialValue: despesa.dataVencimento)
            _status = State(initialValue: despesa.status)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informações") {
                    TextField("Valor (R$)", text: $valor)
                    
                    TextField("Descrição", text: $descricao)
                    
                    Picker("Categoria", selection: $categoria) {
                        ForEach(categoriasPadrao, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    
                    DatePicker("Vencimento", selection: $dataVencimento, displayedComponents: .date)
                }
                
                Section("Status") {
                    Picker("Status", selection: $status) {
                        ForEach(StatusDespesa.allCases, id: \.self) { st in
                            Text(st.rawValue).tag(st)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(despesa == nil ? "Nova Despesa" : "Editar Despesa")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        vm.cancelarFormulario()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        salvarDespesa()
                    }
                    .disabled(descricao.isEmpty || valor.isEmpty || categoria.isEmpty)
                }
            }
        }
    }
    
    private func salvarDespesa() {
        guard let valorDecimal = Decimal(string: valor.replacingOccurrences(of: ",", with: ".")) else { return }
        
        let novaDespesa = DespesaModel(
            id: despesa?.id ?? UUID(),
            valor: valorDecimal,
            descricao: descricao,
            categoria: categoria,
            dataVencimento: dataVencimento,
            status: status,
            dataPagamento: status == .pago ? Date() : nil
        )
        
        if despesa == nil {
            vm.adicionarDespesa(novaDespesa)
        } else {
            vm.atualizarDespesa(novaDespesa)
        }
        
        dismiss()
    }
}

#Preview {
    DespesasView()
}
