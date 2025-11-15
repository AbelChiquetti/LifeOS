//
//  FormatHelper.swift
//  LifeOS
//
//  Helpers para formatação de valores e datas
//

import Foundation

// MARK: - Format Helper
struct FormatHelper {
    
    // MARK: - Valor BRL
    
    /// Formata um valor Decimal para BRL
    static func formatarBRL(_ valor: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: valor as NSDecimalNumber) ?? "R$ 0,00"
    }
    
    /// Formata um valor Double para BRL
    static func formatarBRL(_ valor: Double) -> String {
        formatarBRL(Decimal(valor))
    }
    
    // MARK: - Datas
    
    /// Formata uma data no estilo curto (dd/MM/yyyy)
    static func formatarData(_ data: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: data)
    }
    
    /// Formata uma data com hora (dd/MM/yyyy HH:mm)
    static func formatarDataHora(_ data: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: data)
    }
    
    /// Formata uma data por extenso (1 de janeiro de 2024)
    static func formatarDataPorExtenso(_ data: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: data)
    }
    
    /// Retorna o nome do mês de uma data
    static func nomeDoMes(_ data: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: data).capitalized
    }
    
    // MARK: - Números
    
    /// Formata um número com separador de milhar
    static func formatarNumero(_ valor: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: valor as NSDecimalNumber) ?? "0"
    }
    
    /// Formata um percentual
    static func formatarPercentual(_ valor: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: valor)) ?? "0%"
    }
    
    // MARK: - Tempo Relativo
    
    /// Retorna o tempo relativo (ex: "há 2 dias", "em 3 dias")
    static func tempoRelativo(_ data: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: data, relativeTo: Date())
    }
    
    /// Retorna quantos dias faltam para uma data
    static func diasRestantes(_ data: Date) -> Int {
        Calendar.current.dateComponents([.day], from: Date(), to: data).day ?? 0
    }
    
    /// Retorna texto descritivo dos dias restantes
    static func textosDiasRestantes(_ data: Date) -> String {
        let dias = diasRestantes(data)
        
        if dias < 0 {
            return "Atrasado há \(abs(dias)) dia(s)"
        } else if dias == 0 {
            return "Vence hoje"
        } else if dias == 1 {
            return "Vence amanhã"
        } else {
            return "Vence em \(dias) dia(s)"
        }
    }
}

// MARK: - Extensions

extension Decimal {
    /// Converte Decimal para String formatado em BRL
    var formatadoBRL: String {
        FormatHelper.formatarBRL(self)
    }
    
    /// Converte para NSDecimalNumber para uso com Core Data
    var asNSDecimalNumber: NSDecimalNumber {
        NSDecimalNumber(decimal: self)
    }
}

extension Date {
    /// Converte Date para String formatado
    var formatado: String {
        FormatHelper.formatarData(self)
    }
    
    /// Converte Date para String com hora
    var formatadoComHora: String {
        FormatHelper.formatarDataHora(self)
    }
    
    /// Retorna o nome do mês
    var nomeDoMes: String {
        FormatHelper.nomeDoMes(self)
    }
    
    /// Retorna tempo relativo
    var tempoRelativo: String {
        FormatHelper.tempoRelativo(self)
    }
}

extension Double {
    /// Converte Double para String formatado como percentual
    var formatadoPercentual: String {
        FormatHelper.formatarPercentual(self)
    }
}

extension Optional where Wrapped == NSDecimalNumber {
    /// Converte NSDecimalNumber? em Decimal seguro
    var decimalValueOrZero: Decimal {
        self?.decimalValue ?? 0
    }
}
