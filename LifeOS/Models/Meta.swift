//
//  Meta.swift
//  LifeOS
//
//  Model para Meta Financeira
//

import Foundation
import CoreData

// MARK: - Meta Model
/// Representa uma meta financeira (ex: Ford Mustang, Viagem)
struct MetaModel: Identifiable {
    let id: UUID
    var nome: String
    var valorTotal: Decimal
    var valorAcumulado: Decimal
    var prazo: Date?
    var descricao: String?
    var cor: String // Cor em hex para personalização
    
    init(id: UUID = UUID(), nome: String, valorTotal: Decimal, valorAcumulado: Decimal = 0, prazo: Date? = nil, descricao: String? = nil, cor: String = "#007AFF") {
        self.id = id
        self.nome = nome
        self.valorTotal = valorTotal
        self.valorAcumulado = valorAcumulado
        self.prazo = prazo
        self.descricao = descricao
        self.cor = cor
    }
    
    /// Progresso da meta (0.0 a 1.0)
    var progresso: Double {
        guard valorTotal > 0 else { return 0 }
        return min(Double(truncating: valorAcumulado as NSNumber) / Double(truncating: valorTotal as NSNumber), 1.0)
    }
    
    /// Percentual de conclusão (0 a 100)
    var percentual: Int {
        Int(progresso * 100)
    }
    
    /// Valor restante para atingir a meta
    var valorRestante: Decimal {
        max(valorTotal - valorAcumulado, 0)
    }
    
    /// Verifica se a meta foi completada
    var completa: Bool {
        valorAcumulado >= valorTotal
    }
    
    /// Dias restantes até o prazo (se houver)
    var diasRestantes: Int? {
        guard let prazo = prazo else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: prazo).day
    }
}

// MARK: - Core Data Extensions
extension MetaEntity {
    /// Converte a entidade Core Data para o Model
    func toModel() -> MetaModel {
        MetaModel(
            id: id ?? UUID(),
            nome: nome ?? "",
            // Converte NSDecimalNumber? para Decimal de forma segura
            valorTotal: (valorTotal as? NSDecimalNumber)?.decimalValue ?? 0,
            valorAcumulado: (valorAcumulado as? NSDecimalNumber)?.decimalValue ?? 0,
            prazo: prazo,
            descricao: descricao,
            cor: cor ?? "#007AFF"
        )
    }
    
    /// Atualiza a entidade com dados do Model
    func update(from model: MetaModel) {
        self.id = model.id
        self.nome = model.nome
        self.valorTotal = model.valorTotal as NSDecimalNumber
        self.valorAcumulado = model.valorAcumulado as NSDecimalNumber
        self.prazo = model.prazo
        self.descricao = model.descricao
        self.cor = model.cor
    }
}
