//
//  ReceitasView.swift
//  LifeOS
//
//  Tela de gerenciamento de Receitas
//

import SwiftUI

// MARK: - Receitas View
struct ReceitasView: View {
    @StateObject private var vm = ReceitasViewModel()
    @State private var mostrarDetalhes: ReceitaModel?
    
    var body: some View {
        ZStack {
            LiquidGlassPanel()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Cabeçalho com métricas
                cabecalhoView
                    .padding()
                
                Divider()
                
                // Filtros e busca
                filtrosView
                    .padding()
                
                // Lista de receitas
                if vm.carregando {
                    LoadingView(mensagem: "Carregando receitas...")
                } else if vm.receitasFiltradas.isEmpty {
                    EmptyStateView(
                        icone: "arrow.down.circle",
                        titulo: "Nenhuma receita",
                        mensagem: vm.busca.isEmpty ? "Adicione sua primeira receita" : "Nenhuma receita encontrada com os filtros",
                        botaoTitulo: "Nova Receita",
                        botaoAction: { vm.mostrarFormulario = true }
                    )
                } else {
                    listaReceitasView
                }
            }
        }
        .navigationTitle("Receitas")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    vm.mostrarFormulario = true
                } label: {
                    Label("Nova Receita", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $vm.mostrarFormulario) {
            ReceitaFormView(vm: vm, receita: vm.receitaEditando)
        }
        .sheet(item: $mostrarDetalhes) { receita in
            ReceitaDetailView(receita: receita, vm: vm)
        }
    }
    
    // MARK: - Cabeçalho
    private var cabecalhoView: some View {
        HStack(spacing: 16) {
            MetricCard(
                titulo: "Total de Receitas",
                valor: vm.totalReceitas.formatadoBRL,
                icone: "dollarsign.circle.fill",
                cor: .green
            )
            
            MetricCard(
                titulo: "Quantidade",
                valor: "\(vm.receitas.count)",
                icone: "number.circle.fill",
                cor: .blue
            )
        }
    }
    
    // MARK: - Filtros
    private var filtrosView: some View {
        VStack(spacing: 12) {
            // Campo de busca
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Buscar receitas...", text: $vm.busca)
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
            
            // Filtro de categoria
            if !vm.categorias.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(
                            titulo: "Todas",
                            selecionado: vm.filtroCategoria == nil
                        ) {
                            vm.filtroCategoria = nil
                        }
                        
                        ForEach(vm.categorias, id: \.self) { categoria in
                            FilterChip(
                                titulo: categoria,
                                selecionado: vm.filtroCategoria == categoria
                            ) {
                                vm.filtroCategoria = categoria
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Lista
    private var listaReceitasView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(vm.receitasFiltradas) { receita in
                    ReceitaRow(receita: receita)
                        .onTapGesture {
                            mostrarDetalhes = receita
                        }
                        .contextMenu {
                            Button {
                                vm.editarReceita(receita)
                            } label: {
                                Label("Editar", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                vm.deletarReceita(receita)
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

// MARK: - Receita Row
struct ReceitaRow: View {
    let receita: ReceitaModel
    
    var body: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(receita.descricao)
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        Text(receita.data.formatado)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if let categoria = receita.categoria {
                            Text("•")
                                .foregroundStyle(.secondary)
                            Text(categoria)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Text(receita.valor.formatadoBRL)
                    .font(.headline)
                    .foregroundStyle(.green)
            }
        }
    }
}

// MARK: - Receita Detail View
struct ReceitaDetailView: View {
    let receita: ReceitaModel
    let vm: ReceitasViewModel
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
                            
                            Text(receita.valor.formatadoBRL)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(.green)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                        
                        // Informações
                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                InfoRow(titulo: "Descrição", valor: receita.descricao)
                                Divider()
                                InfoRow(titulo: "Data", valor: receita.data.formatado)
                                
                                if let categoria = receita.categoria {
                                    Divider()
                                    InfoRow(titulo: "Categoria", valor: categoria)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Detalhes da Receita")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        vm.editarReceita(receita)
                        dismiss()
                    } label: {
                        Label("Editar", systemImage: "pencil")
                    }
                }
            }
        }
    }
}

// MARK: - Receita Form View
struct ReceitaFormView: View {
    @ObservedObject var vm: ReceitasViewModel
    let receita: ReceitaModel?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var valor: String = ""
    @State private var descricao: String = ""
    @State private var categoria: String = ""
    @State private var data: Date = Date()
    @State private var metaAssociada: UUID?
    
    @StateObject private var metasVM = MetasViewModel()
    
    init(vm: ReceitasViewModel, receita: ReceitaModel?) {
        self.vm = vm
        self.receita = receita
        
        if let receita = receita {
            _valor = State(initialValue: "\(receita.valor)")
            _descricao = State(initialValue: receita.descricao)
            _categoria = State(initialValue: receita.categoria ?? "")
            _data = State(initialValue: receita.data)
            _metaAssociada = State(initialValue: receita.metaAssociada)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informações") {
                    TextField("Valor (R$)", text: $valor)
                    
                    TextField("Descrição", text: $descricao)
                    
                    TextField("Categoria (opcional)", text: $categoria)
                    
                    DatePicker("Data", selection: $data, displayedComponents: .date)
                }
                
                Section("Meta Associada") {
                    Picker("Meta", selection: $metaAssociada) {
                        Text("Nenhuma").tag(nil as UUID?)
                        ForEach(metasVM.metas) { meta in
                            Text(meta.nome).tag(meta.id as UUID?)
                        }
                    }
                }
            }
            .navigationTitle(receita == nil ? "Nova Receita" : "Editar Receita")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        vm.cancelarFormulario()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        salvarReceita()
                    }
                    .disabled(descricao.isEmpty || valor.isEmpty)
                }
            }
        }
    }
    
    private func salvarReceita() {
        guard let valorDecimal = Decimal(string: valor.replacingOccurrences(of: ",", with: ".")) else { return }
        
        let novaReceita = ReceitaModel(
            id: receita?.id ?? UUID(),
            valor: valorDecimal,
            descricao: descricao,
            categoria: categoria.isEmpty ? nil : categoria,
            data: data,
            metaAssociada: metaAssociada
        )
        
        if receita == nil {
            vm.adicionarReceita(novaReceita)
        } else {
            vm.atualizarReceita(novaReceita)
        }
        
        dismiss()
    }
}

// MARK: - Helper Views
struct FilterChip: View {
    let titulo: String
    let selecionado: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(titulo)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(selecionado ? Color.accentColor : Color.secondary.opacity(0.2))
                .foregroundStyle(selecionado ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct InfoRow: View {
    let titulo: String
    let valor: String
    
    var body: some View {
        HStack {
            Text(titulo)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(valor)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    ReceitasView()
}
