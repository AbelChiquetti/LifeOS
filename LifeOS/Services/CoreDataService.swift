//
//  CoreDataService.swift
//  LifeOS
//
//  Serviço centralizado para operações com Core Data
//

import Foundation
import CoreData

// MARK: - Core Data Service
/// Gerencia todas as operações de persistência do app
final class CoreDataService {
    
    // MARK: - Singleton
    static let shared = CoreDataService()
    private init() {}
    
    // MARK: - Contexto
    private var context: NSManagedObjectContext {
        CoreDataStack.shared.viewContext
    }
    
    // MARK: - Receitas
    
    /// Cria uma nova receita
    func criarReceita(_ model: ReceitaModel) throws {
        let entity = ReceitaEntity(context: context)
        entity.update(from: model)
        try salvarContexto()
    }
    
    /// Busca todas as receitas
    func buscarReceitas() -> [ReceitaModel] {
        let request: NSFetchRequest<ReceitaEntity> = ReceitaEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "data", ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { $0.toModel() }
        } catch {
            print("Erro ao buscar receitas: \(error)")
            return []
        }
    }
    
    /// Busca receitas do mês atual
    func buscarReceitasDoMes() -> [ReceitaModel] {
        let calendar = Calendar.current
        let inicio = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let fim = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: inicio)!
        
        let request: NSFetchRequest<ReceitaEntity> = ReceitaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "data >= %@ AND data <= %@", inicio as NSDate, fim as NSDate)
        
        do {
            let entities = try context.fetch(request)
            return entities.map { $0.toModel() }
        } catch {
            print("Erro ao buscar receitas do mês: \(error)")
            return []
        }
    }
    
    /// Atualiza uma receita existente
    func atualizarReceita(_ model: ReceitaModel) throws {
        let request: NSFetchRequest<ReceitaEntity> = ReceitaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", model.id as CVarArg)
        
        if let entity = try context.fetch(request).first {
            entity.update(from: model)
            try salvarContexto()
        }
    }
    
    /// Deleta uma receita
    func deletarReceita(id: UUID) throws {
        let request: NSFetchRequest<ReceitaEntity> = ReceitaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if let entity = try context.fetch(request).first {
            context.delete(entity)
            try salvarContexto()
        }
    }
    
    // MARK: - Despesas
    
    /// Cria uma nova despesa
    func criarDespesa(_ model: DespesaModel) throws {
        let entity = DespesaEntity(context: context)
        entity.update(from: model)
        try salvarContexto()
    }
    
    /// Busca todas as despesas
    func buscarDespesas() -> [DespesaModel] {
        let request: NSFetchRequest<DespesaEntity> = DespesaEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dataVencimento", ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { $0.toModel() }
        } catch {
            print("Erro ao buscar despesas: \(error)")
            return []
        }
    }
    
    /// Busca despesas do mês atual
    func buscarDespesasDoMes() -> [DespesaModel] {
        let calendar = Calendar.current
        let inicio = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        let fim = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: inicio)!
        
        let request: NSFetchRequest<DespesaEntity> = DespesaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "dataVencimento >= %@ AND dataVencimento <= %@", inicio as NSDate, fim as NSDate)
        
        do {
            let entities = try context.fetch(request)
            return entities.map { $0.toModel() }
        } catch {
            print("Erro ao buscar despesas do mês: \(error)")
            return []
        }
    }
    
    /// Busca despesas não pagas
    func buscarDespesasNaoPagas() -> [DespesaModel] {
        let request: NSFetchRequest<DespesaEntity> = DespesaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "status == %@", StatusDespesa.naoPago.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "dataVencimento", ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { $0.toModel() }
        } catch {
            print("Erro ao buscar despesas não pagas: \(error)")
            return []
        }
    }
    
    /// Atualiza uma despesa existente
    func atualizarDespesa(_ model: DespesaModel) throws {
        let request: NSFetchRequest<DespesaEntity> = DespesaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", model.id as CVarArg)
        
        if let entity = try context.fetch(request).first {
            entity.update(from: model)
            try salvarContexto()
        }
    }
    
    /// Deleta uma despesa
    func deletarDespesa(id: UUID) throws {
        let request: NSFetchRequest<DespesaEntity> = DespesaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if let entity = try context.fetch(request).first {
            context.delete(entity)
            try salvarContexto()
        }
    }
    
    // MARK: - Metas
    
    /// Cria uma nova meta
    func criarMeta(_ model: MetaModel) throws {
        let entity = MetaEntity(context: context)
        entity.update(from: model)
        try salvarContexto()
    }
    
    /// Busca todas as metas
    func buscarMetas() -> [MetaModel] {
        let request: NSFetchRequest<MetaEntity> = MetaEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "nome", ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { $0.toModel() }
        } catch {
            print("Erro ao buscar metas: \(error)")
            return []
        }
    }
    
    /// Atualiza uma meta existente
    func atualizarMeta(_ model: MetaModel) throws {
        let request: NSFetchRequest<MetaEntity> = MetaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", model.id as CVarArg)
        
        if let entity = try context.fetch(request).first {
            entity.update(from: model)
            try salvarContexto()
        }
    }
    
    /// Deleta uma meta
    func deletarMeta(id: UUID) throws {
        let request: NSFetchRequest<MetaEntity> = MetaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if let entity = try context.fetch(request).first {
            context.delete(entity)
            try salvarContexto()
        }
    }
    
    /// Adiciona valor ao acumulado de uma meta
    func adicionarValorMeta(id: UUID, valor: Decimal) throws {
        let request: NSFetchRequest<MetaEntity> = MetaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        if let entity = try context.fetch(request).first {
            // Converte NSDecimalNumber? para Decimal de forma segura
            let atualDecimal = (entity.valorAcumulado as? NSDecimalNumber)?.decimalValue ?? 0
            let novoValor = atualDecimal + valor
            entity.valorAcumulado = novoValor as NSDecimalNumber
            try salvarContexto()
        }
    }
    
    // MARK: - Cálculos
    
    /// Calcula o saldo total (receitas - despesas pagas)
    func calcularSaldoTotal() -> Decimal {
        let receitas = buscarReceitas()
        let despesas = buscarDespesas().filter { $0.status == .pago }
        
        let totalReceitas = receitas.reduce(Decimal(0)) { $0 + $1.valor }
        let totalDespesas = despesas.reduce(Decimal(0)) { $0 + $1.valor }
        
        return totalReceitas - totalDespesas
    }
    
    /// Calcula o total de receitas do mês atual
    func calcularTotalReceitasMes() -> Decimal {
        buscarReceitasDoMes().reduce(Decimal(0)) { $0 + $1.valor }
    }
    
    /// Calcula o total de despesas do mês atual
    func calcularTotalDespesasMes() -> Decimal {
        buscarDespesasDoMes().reduce(Decimal(0)) { $0 + $1.valor }
    }
    
    /// Busca as últimas N movimentações (receitas e despesas combinadas)
    func buscarUltimasMovimentacoes(limite: Int = 10) -> [(tipo: String, descricao: String, valor: Decimal, data: Date)] {
        var movimentacoes: [(tipo: String, descricao: String, valor: Decimal, data: Date)] = []
        
        // Adiciona receitas
        for receita in buscarReceitas() {
            movimentacoes.append(("receita", receita.descricao, receita.valor, receita.data))
        }
        
        // Adiciona despesas
        for despesa in buscarDespesas() {
            movimentacoes.append(("despesa", despesa.descricao, despesa.valor, despesa.dataVencimento))
        }
        
        // Ordena por data e limita
        return movimentacoes
            .sorted { $0.data > $1.data }
            .prefix(limite)
            .map { $0 }
    }
    
    /// Calcula percentual gasto por categoria
    func calcularPercentualPorCategoria() -> [(categoria: String, valor: Double)] {
        let despesas = buscarDespesasDoMes()
        let total = despesas.reduce(Decimal(0)) { $0 + $1.valor }
        
        guard total > 0 else { return [] }
        
        var categorias: [String: Decimal] = [:]
        for despesa in despesas {
            categorias[despesa.categoria, default: 0] += despesa.valor
        }
        
        return categorias.map { (categoria: $0.key, valor: Double(truncating: ($0.value / total * 100) as NSNumber)) }
            .sorted { $0.categoria < $1.categoria }
    }
    
    // MARK: - Persistência
    
    /// Salva o contexto
    private func salvarContexto() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
