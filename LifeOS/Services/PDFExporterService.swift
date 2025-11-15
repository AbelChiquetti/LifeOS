//
//  PDFExporterService.swift
//  LifeOS
//
//  Serviço para exportação de relatórios em PDF
//

import Foundation
import PDFKit
import AppKit

// MARK: - PDF Exporter Service
/// Gera relatórios financeiros em PDF
final class PDFExporterService {
    
    // MARK: - Singleton
    static let shared = PDFExporterService()
    private init() {}
    
    enum Erro: Error {
        case falhaAoCriarPDF
        case falhaAoSalvar
    }
    
    // MARK: - Geração de PDF
    
    /// Gera relatório financeiro completo em PDF
    func gerarRelatorioFinanceiro() throws -> URL {
        let pdf = NSMutableData()
        var pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // Tamanho A4
        
        guard let consumer = CGDataConsumer(data: pdf as CFMutableData) else {
            throw Erro.falhaAoCriarPDF
        }
        
        // Cria contexto PDF usando ponteiro direto do CGRect
        guard let context = CGContext(consumer: consumer, mediaBox: &pageRect, nil) else {
            throw Erro.falhaAoCriarPDF
        }
        
        context.beginPDFPage(nil)
        
        // Busca dados
        let saldo = CoreDataService.shared.calcularSaldoTotal()
        let receitasMes = CoreDataService.shared.calcularTotalReceitasMes()
        let despesasMes = CoreDataService.shared.calcularTotalDespesasMes()
        let receitas = CoreDataService.shared.buscarReceitasDoMes()
        let despesas = CoreDataService.shared.buscarDespesasDoMes()
        let metas = CoreDataService.shared.buscarMetas()
        
        var yPosition: CGFloat = 720
        
        // Cabeçalho
        desenharTexto("RELATÓRIO FINANCEIRO", em: CGPoint(x: 40, y: yPosition), fontSize: 24, bold: true, context: context)
        yPosition -= 30
        
        desenharTexto("LifeOS - Gerado em \(formatarData(Date()))", em: CGPoint(x: 40, y: yPosition), fontSize: 12, cor: .gray, context: context)
        yPosition -= 40
        
        // Linha separadora
        desenharLinha(de: CGPoint(x: 40, y: yPosition), ate: CGPoint(x: 572, y: yPosition), context: context)
        yPosition -= 30
        
        // Resumo Financeiro
        desenharTexto("RESUMO FINANCEIRO", em: CGPoint(x: 40, y: yPosition), fontSize: 18, bold: true, context: context)
        yPosition -= 25
        
        desenharTexto("Saldo Atual:", em: CGPoint(x: 40, y: yPosition), fontSize: 14, context: context)
        desenharTexto(formatarValorBRL(saldo), em: CGPoint(x: 200, y: yPosition), fontSize: 14, bold: true, context: context)
        yPosition -= 20
        
        desenharTexto("Receitas do Mês:", em: CGPoint(x: 40, y: yPosition), fontSize: 14, context: context)
        desenharTexto(formatarValorBRL(receitasMes), em: CGPoint(x: 200, y: yPosition), fontSize: 14, context: context)
        yPosition -= 20
        
        desenharTexto("Despesas do Mês:", em: CGPoint(x: 40, y: yPosition), fontSize: 14, context: context)
        desenharTexto(formatarValorBRL(despesasMes), em: CGPoint(x: 200, y: yPosition), fontSize: 14, context: context)
        yPosition -= 35
        
        // Receitas
        desenharTexto("RECEITAS DO MÊS", em: CGPoint(x: 40, y: yPosition), fontSize: 16, bold: true, context: context)
        yPosition -= 25
        
        if receitas.isEmpty {
            desenharTexto("Nenhuma receita registrada", em: CGPoint(x: 40, y: yPosition), fontSize: 12, cor: .gray, context: context)
            yPosition -= 20
        } else {
            for receita in receitas.prefix(10) {
                desenharTexto("• \(receita.descricao)", em: CGPoint(x: 40, y: yPosition), fontSize: 11, context: context)
                desenharTexto(formatarValorBRL(receita.valor), em: CGPoint(x: 400, y: yPosition), fontSize: 11, context: context)
                desenharTexto(formatarData(receita.data), em: CGPoint(x: 500, y: yPosition), fontSize: 10, cor: .gray, context: context)
                yPosition -= 18
            }
        }
        
        yPosition -= 15
        
        // Despesas
        desenharTexto("DESPESAS DO MÊS", em: CGPoint(x: 40, y: yPosition), fontSize: 16, bold: true, context: context)
        yPosition -= 25
        
        if despesas.isEmpty {
            desenharTexto("Nenhuma despesa registrada", em: CGPoint(x: 40, y: yPosition), fontSize: 12, cor: .gray, context: context)
            yPosition -= 20
        } else {
            for despesa in despesas.prefix(10) {
                desenharTexto("• \(despesa.descricao)", em: CGPoint(x: 40, y: yPosition), fontSize: 11, context: context)
                desenharTexto(formatarValorBRL(despesa.valor), em: CGPoint(x: 400, y: yPosition), fontSize: 11, context: context)
                desenharTexto(despesa.status.rawValue, em: CGPoint(x: 500, y: yPosition), fontSize: 10, cor: despesa.status == .pago ? .systemGreen : .systemRed, context: context)
                yPosition -= 18
            }
        }
        
        yPosition -= 15
        
        // Metas
        desenharTexto("METAS FINANCEIRAS", em: CGPoint(x: 40, y: yPosition), fontSize: 16, bold: true, context: context)
        yPosition -= 25
        
        if metas.isEmpty {
            desenharTexto("Nenhuma meta cadastrada", em: CGPoint(x: 40, y: yPosition), fontSize: 12, cor: .gray, context: context)
        } else {
            for meta in metas {
                desenharTexto("• \(meta.nome)", em: CGPoint(x: 40, y: yPosition), fontSize: 11, bold: true, context: context)
                yPosition -= 15
                desenharTexto("Meta: \(formatarValorBRL(meta.valorTotal)) | Acumulado: \(formatarValorBRL(meta.valorAcumulado))", em: CGPoint(x: 50, y: yPosition), fontSize: 10, context: context)
                yPosition -= 15
                desenharTexto("Progresso: \(meta.percentual)%", em: CGPoint(x: 50, y: yPosition), fontSize: 10, context: context)
                yPosition -= 20
            }
        }
        
        // Rodapé
        desenharLinha(de: CGPoint(x: 40, y: 40), ate: CGPoint(x: 572, y: 40), context: context)
        desenharTexto("LifeOS - Seu assistente financeiro pessoal", em: CGPoint(x: 40, y: 25), fontSize: 10, cor: .gray, context: context)
        
        context.endPDFPage()
        context.closePDF()
        
        // Salva o PDF
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("RelatorioFinanceiro_\(Date().timeIntervalSince1970).pdf")
        
        guard pdf.write(to: url, atomically: true) else {
            throw Erro.falhaAoSalvar
        }
        
        return url
    }
    
    // MARK: - Helpers de Desenho
    
    private func desenharTexto(_ texto: String, em ponto: CGPoint, fontSize: CGFloat, bold: Bool = false, cor: NSColor = .black, context: CGContext) {
        let font = bold ? NSFont.boldSystemFont(ofSize: fontSize) : NSFont.systemFont(ofSize: fontSize)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: cor
        ]
        
        let attributedString = NSAttributedString(string: texto, attributes: attributes)
        
        context.saveGState()
        context.translateBy(x: 0, y: 792)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let yFlipped = 792 - ponto.y
        attributedString.draw(at: CGPoint(x: ponto.x, y: yFlipped - fontSize))
        
        context.restoreGState()
    }
    
    private func desenharLinha(de inicio: CGPoint, ate fim: CGPoint, context: CGContext) {
        context.setStrokeColor(NSColor.gray.cgColor)
        context.setLineWidth(0.5)
        context.move(to: inicio)
        context.addLine(to: fim)
        context.strokePath()
    }
    
    // MARK: - Formatação
    
    private func formatarValorBRL(_ valor: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: valor as NSDecimalNumber) ?? "R$ 0,00"
    }
    
    private func formatarData(_ data: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: data)
    }
}
