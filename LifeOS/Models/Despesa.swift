//
//  Despesa.swift
//  LifeOS
//
//  Model para Despesa (Saída financeira)
//

import Foundation
import CoreData

// MARK: - Status da Despesa
enum StatusDespesa: String, CaseIterable {
    case pago = "Pago"
    case naoPago = "Não Pago"
    case atrasado = "Atrasado"
}

// MARK: - Despesa Model
/// Representa uma despesa (saída de dinheiro)
struct DespesaModel: Identifiable {
    let id: UUID
    var valor: Decimal
    var descricao: String
    var categoria: String
    var dataVencimento: Date
    var status: StatusDespesa
    var metaAssociada: UUID?
    var dataPagamento: Date?
    
    init(id: UUID = UUID(), valor: Decimal, descricao: String, categoria: String, dataVencimento: Date, status: StatusDespesa = .naoPago, metaAssociada: UUID? = nil, dataPagamento: Date? = nil) {
        self.id = id
        self.valor = valor
        self.descricao = descricao
        self.categoria = categoria
        self.dataVencimento = dataVencimento
        self.status = status
        self.metaAssociada = metaAssociada
        self.dataPagamento = dataPagamento
    }
    
    /// Verifica se a despesa está atrasada
    var estaAtrasada: Bool {
        status == .naoPago && dataVencimento < Date()
    }
    
    /// Verifica se faltam 3 dias ou menos para o vencimento
    var proximaDoVencimento: Bool {
        guard status == .naoPago else { return false }
        let diasRestantes = Calendar.current.dateComponents([.day], from: Date(), to: dataVencimento).day ?? 0
        return diasRestantes >= 0 && diasRestantes <= 3
    }
}

// MARK: - Core Data Extensions
extension DespesaEntity {
    /// Converte a entidade Core Data para o Model
    func toModel() -> DespesaModel {
        DespesaModel(
            id: id ?? UUID(),
            // Converte NSDecimalNumber? para Decimal de forma segura
            valor: (valor as? NSDecimalNumber)?.decimalValue ?? 0,
            descricao: descricao ?? "",
            categoria: categoria ?? "",
            dataVencimento: dataVencimento ?? Date(),
            status: StatusDespesa(rawValue: status ?? "") ?? .naoPago,
            metaAssociada: metaAssociada,
            dataPagamento: dataPagamento
        )
    }
    
    /// Atualiza a entidade com dados do Model
    func update(from model: DespesaModel) {
        self.id = model.id
        self.valor = model.valor as NSDecimalNumber
        self.descricao = model.descricao
        self.categoria = model.categoria
        self.dataVencimento = model.dataVencimento
        self.status = model.status.rawValue
        self.metaAssociada = model.metaAssociada
        self.dataPagamento = model.dataPagamento
    }
}
