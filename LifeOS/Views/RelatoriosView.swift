//
//  RelatoriosView.swift
//  LifeOS
//
//  Tela para geração de relatórios em PDF.
//

import SwiftUI

struct RelatoriosView: View {
    @State private var exportando = false
    @State private var mensagemSucesso: String?
    
    var body: some View {
        ZStack {
            LiquidGlassPanel()
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "doc.richtext")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                
                VStack(spacing: 12) {
                    Text("Relatórios")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Gere relatórios completos das suas finanças em PDF")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: exportarPDF) {
                    Label(exportando ? "Gerando..." : "Exportar Relatório PDF", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: 320)
                }
                .buttonStyle(.borderedProminent)
                .disabled(exportando)
                
                if let mensagem = mensagemSucesso {
                    Text(mensagem)
                        .font(.subheadline)
                        .foregroundStyle(.green)
                }
            }
            .padding(40)
        }
        .navigationTitle("Relatórios")
    }
    
    private func exportarPDF() {
        exportando = true
        
        Task {
            do {
                let url = try PDFExporterService.shared.gerarRelatorioFinanceiro()
                await MainActor.run {
                    NSWorkspace.shared.activateFileViewerSelecting([url])
                    mensagemSucesso = "Relatório gerado com sucesso!"
                    exportando = false
                }
            } catch {
                await MainActor.run {
                    mensagemSucesso = "Erro ao gerar relatório"
                    exportando = false
                }
            }
        }
    }
}

#Preview {
    RelatoriosView()
}
