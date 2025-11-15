//
//  ContentView.swift
//  LifeOS
//
//  Criado por Abel Chiquetti em 11/15/25
//
//  Tela inicial (Dashboard) do app Financeiro pessoal para macOS.
//  Em PT-BR, com estilo visual Liquid/Glass e MVVM.
//

import SwiftUI
import WidgetKit

// MARK: - ContentView (Dashboard Shell)
struct ContentView: View {
    @State private var selectedTab: DashboardTab = .dashboard

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedTab: $selectedTab)
        } detail: {
            ZStack {
                // Fundo com material para efeito Glass/Liquid
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()

                switch selectedTab {
                case .dashboard:
                    DashboardView()
                case .receitas:
                    ReceitasView()
                case .despesas:
                    DespesasView()
                case .metas:
                    MetasView()
                case .relatorios:
                    RelatoriosView()
                }
            }
            .toolbar { MainToolbar() }
        }
        .environment(\.managedObjectContext, CoreDataStack.shared.viewContext)
    }
}

// MARK: - Sidebar
private struct SidebarView: View {
    @Binding var selectedTab: DashboardTab

    var body: some View {
        List(selection: $selectedTab) {
            Section("Principal") {
                NavigationLink(value: DashboardTab.dashboard) {
                    Label("Dashboard", systemImage: "speedometer")
                }
            }
            Section("Movimentações") {
                NavigationLink(value: DashboardTab.receitas) {
                    Label("Receitas", systemImage: "arrow.down.circle")
                }
                NavigationLink(value: DashboardTab.despesas) {
                    Label("Despesas", systemImage: "arrow.up.circle")
                }
            }
            Section("Metas") {
                NavigationLink(value: DashboardTab.metas) {
                    Label("Metas financeiras", systemImage: "target")
                }
            }
            Section("Relatórios") {
                NavigationLink(value: DashboardTab.relatorios) {
                    Label("Relatórios", systemImage: "doc.richtext")
                }
            }
        }
        .listStyle(.sidebar)
    }
}

// MARK: - Toolbar principal
private struct MainToolbar: ToolbarContent {
    @AppStorage("usuarioNome") private var usuarioNome: String = "Abel"
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Text("\(saudacao()), \(usuarioNome)")
                .font(.headline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
        }
        ToolbarItemGroup(placement: .automatic) {
            Button {
                WidgetCenter.shared.reloadAllTimelines()
            } label: {
                Label("Atualizar Widgets", systemImage: "arrow.clockwise")
            }
            Button {
                exportarPDF()
            } label: {
                Label("Exportar PDF", systemImage: "square.and.arrow.up")
            }
        }
    }
    
    /// Retorna saudação de acordo com o horário atual
    private func saudacao() -> String {
        let hora = Calendar.current.component(.hour, from: Date())
        switch hora {
        case 5..<12:
            return "Bom dia"
        case 12..<18:
            return "Boa tarde"
        default:
            return "Boa noite"
        }
    }
    
    private func exportarPDF() {
        do {
            let url = try PDFExporterService.shared.gerarRelatorioFinanceiro()
            NSWorkspace.shared.activateFileViewerSelecting([url])
        } catch {
            print("Erro ao exportar PDF: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
