//
//  LiquidComponents.swift
//  LifeOS
//
//  Componentes visuais com efeito Liquid/Glass
//

import SwiftUI

// MARK: - Liquid Glass Panel
/// Painel com efeito Glass/Liquid usando Material e gradientes
struct LiquidGlassPanel: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.15),
                    Color.purple.opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .blur(radius: 40)
            .ignoresSafeArea()
            
            Rectangle()
                .fill(.thinMaterial)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Glass Card
/// Card com efeito glassmorphism
struct GlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16
    
    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(.white.opacity(0.15))
            )
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 8)
    }
}

// MARK: - Metric Card
/// Card para exibir métricas com ícone
struct MetricCard: View {
    let titulo: String
    let valor: String
    let icone: String
    let cor: Color
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icone)
                        .font(.title2)
                        .foregroundStyle(cor)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(titulo)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(valor)
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .contentTransition(.numericText())
                }
            }
        }
    }
}

// MARK: - Progress Card
/// Card com barra de progresso
struct ProgressCard: View {
    let titulo: String
    let progresso: Double
    let valorAtual: String
    let valorTotal: String
    let cor: Color
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(titulo)
                        .font(.headline)
                    Spacer()
                    Text("\(Int(progresso * 100))%")
                        .font(.subheadline)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                
                ProgressView(value: progresso)
                    .tint(cor)
                    .animation(.easeInOut, value: progresso)
                
                HStack {
                    Text(valorAtual)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(valorTotal)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Empty State
/// Estado vazio com mensagem e ícone
struct EmptyStateView: View {
    let icone: String
    let titulo: String
    let mensagem: String
    var botaoTitulo: String?
    var botaoAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icone)
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text(titulo)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(mensagem)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let botaoTitulo = botaoTitulo, let botaoAction = botaoAction {
                Button(action: botaoAction) {
                    Label(botaoTitulo, systemImage: "plus")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Loading View
/// Indicador de carregamento
struct LoadingView: View {
    let mensagem: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text(mensagem)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Alert Badge
/// Badge para alertas (ex: despesas atrasadas)
struct AlertBadge: View {
    let texto: String
    let cor: Color
    
    var body: some View {
        Text(texto)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(cor.opacity(0.2))
            .foregroundStyle(cor)
            .clipShape(Capsule())
    }
}

// MARK: - Icon Button
/// Botão circular com ícone
struct IconButton: View {
    let icone: String
    let cor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icone)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(cor, in: Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Section Header
/// Cabeçalho de seção com título e ação opcional
struct SectionHeader: View {
    let titulo: String
    let icone: String
    var botaoTitulo: String?
    var botaoAction: (() -> Void)?
    
    var body: some View {
        HStack {
            Label(titulo, systemImage: icone)
                .font(.headline)
            
            Spacer()
            
            if let botaoTitulo = botaoTitulo, let botaoAction = botaoAction {
                Button(botaoTitulo, action: botaoAction)
                    .font(.subheadline)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Divider with Label
/// Divisor com texto
struct DividerWithLabel: View {
    let texto: String
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(.secondary.opacity(0.3))
                .frame(height: 1)
            
            Text(texto)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
            
            Rectangle()
                .fill(.secondary.opacity(0.3))
                .frame(height: 1)
        }
    }
}

// MARK: - Animated Background
/// Fundo animado com gradiente
struct AnimatedBackground: View {
    @State private var animate = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.3),
                Color.purple.opacity(0.3),
                Color.pink.opacity(0.3)
            ],
            startPoint: animate ? .topLeading : .bottomTrailing,
            endPoint: animate ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
        .blur(radius: 60)
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animate.toggle()
            }
        }
    }
}
