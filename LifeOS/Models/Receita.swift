//
//  Receita.swift
//  LifeOS
//
//  Model para Receita (Entrada financeira)
//

import Foundation
import CoreData

// MARK: - Receita Model
/// Representa uma receita (entrada de dinheiro)
struct ReceitaModel: Identifiable {
    let id: UUID
    var valor: Decimal
    var descricao: String
    var categoria: String?
    var data: Date
    var metaAssociada: UUID?
    
    init(id: UUID = UUID(), valor: Decimal, descricao: String, categoria: String? = nil, data: Date = Date(), metaAssociada: UUID? = nil) {
        self.id = id
        self.valor = valor
        self.descricao = descricao
        self.categoria = categoria
        self.data = data
        self.metaAssociada = metaAssociada
    }
}

// MARK: - Core Data Extensions
extension ReceitaEntity {
    /// Converte a entidade Core Data para o Model
    func toModel() -> ReceitaModel {
        ReceitaModel(
            id: id ?? UUID(),
            // Converte NSDecimalNumber? para Decimal de forma segura
            valor: (valor as? NSDecimalNumber)?.decimalValue ?? 0,
            descricao: descricao ?? "",
            categoria: categoria,
            data: data ?? Date(),
            metaAssociada: metaAssociada
        )
    }
    
    /// Atualiza a entidade com dados do Model
    func update(from model: ReceitaModel) {
        self.id = model.id
        self.valor = model.valor as NSDecimalNumber
        self.descricao = model.descricao
        self.categoria = model.categoria
        self.data = model.data
        self.metaAssociada = model.metaAssociada
    }
}
