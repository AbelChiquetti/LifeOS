# LifeOS - Aplicativo Financeiro para macOS

🚀 **Aplicativo completo de gestão financeira pessoal para macOS**, desenvolvido em Swift + SwiftUI com design moderno utilizando Liquid Glass/Acrylic.

---

## 📋 Funcionalidades

### ✅ Implementado

- **Dashboard Completo**
  - Saldo atual em tempo real
  - Total de receitas e despesas do mês
  - Gráfico mensal com Swift Charts
  - Percentual gasto por categoria
  - Últimas 10 movimentações
  - Progresso de metas em destaque

- **Receitas**
  - Cadastro completo com valor, descrição, categoria e data
  - Associação com metas financeiras
  - Busca e filtros por categoria
  - Edição e exclusão
  - Visualização detalhada

- **Despesas**
  - Cadastro com valor, descrição, categoria, data de vencimento
  - Status: Pago / Não Pago / Atrasado
  - **Notificações automáticas** (3 dias antes e no dia do vencimento)
  - Indicadores visuais de despesas atrasadas
  - Filtros por status e categoria
  - Ação rápida para marcar como paga

- **Metas Financeiras**
  - Múltiplas metas simultâneas
  - Nome, valor total, valor acumulado
  - Barra de progresso visual com percentual
  - Prazo opcional com contagem de dias
  - Cores personalizáveis para cada meta
  - Adição de valores às metas
  - Progresso geral de todas as metas

- **Relatórios em PDF**
  - Exportação completa de dados financeiros
  - Layout profissional com cabeçalho e rodapé
  - Incluí resumo, receitas, despesas e metas
  - Abertura automática no Finder

- **Widgets para macOS (WidgetKit)**
  - Widget pequeno: Saldo atual
  - Widget médio: Resumo com receitas e despesas
  - Widget grande: Resumo + Meta principal
  - Atualização automática

- **Persistência com Core Data**
  - Armazenamento local seguro
  - Entidades: ReceitaEntity, DespesaEntity, MetaEntity
  - Operações CRUD completas

- **Notificações**
  - Sistema completo de alertas para despesas
  - Notificação 3 dias antes do vencimento
  - Notificação no dia do vencimento
  - Gerenciamento automático de permissões

---

## 🏗️ Arquitetura

### **MVVM (Model-View-ViewModel)**

```
LifeOS/
├── Models/
│   ├── Receita.swift
│   ├── Despesa.swift
│   └── Meta.swift
│
├── Views/
│   ├── DashboardView.swift
│   ├── ReceitasView.swift
│   ├── DespesasView.swift
│   ├── MetasView.swift
│   └── ContentView.swift
│
├── ViewModels/
│   ├── DashboardViewModel.swift
│   ├── ReceitasViewModel.swift
│   ├── DespesasViewModel.swift
│   └── MetasViewModel.swift
│
├── Services/
│   ├── CoreDataService.swift
│   ├── NotificationService.swift
│   └── PDFExporterService.swift
│
├── Components/
│   ├── LiquidComponents.swift
│   └── FormatHelper.swift
│
├── DataModel.xcdatamodeld/
│   └── DataModel.xcdatamodel/
│       └── contents
│
└── LifeOSWidgets/
    └── LifeOSWidgets.swift
```

---

## 🎨 Design System

### **Liquid Glass / Acrylic**
- Painéis com `.ultraThinMaterial` e `.thinMaterial`
- Gradientes suaves (azul → roxo)
- Cantos arredondados com `.continuous`
- Sombras sutis para profundidade
- Animações fluidas estilo Apple

### **Componentes Reutilizáveis**
- `GlassCard`: Card com efeito glassmorphism
- `MetricCard`: Card de métricas com ícone
- `ProgressCard`: Card com barra de progresso
- `EmptyStateView`: Estado vazio elegante
- `AlertBadge`: Badge para alertas
- `IconButton`: Botão circular com ícone

### **Cores e Ícones**
- SF Symbols para todos os ícones
- Tipografia San Francisco
- Paleta de cores do macOS Sonoma/Sequoia
- Suporte completo a modo escuro

---

## 🚀 Como Compilar

### **Requisitos**
- macOS 13.0 (Ventura) ou superior
- Xcode 15.0 ou superior
- Swift 5.9+

### **Passos**

1. **Abra o projeto no Xcode**
   ```bash
   cd /Users/abel/Documents/LifeOS/LifeOS
   open LifeOS.xcodeproj
   ```

2. **Configure o Target**
   - Selecione o target `LifeOS` (app principal)
   - Verifique o bundle identifier
   - Configure a equipe de desenvolvimento (se necessário)

3. **Configure o Widget Target**
   - Selecione o target `LifeOSWidgets`
   - Verifique o bundle identifier (deve ser `com.seuapp.LifeOS.LifeOSWidgets`)
   - Adicione o App Group: `group.com.seuapp.LifeOS`

4. **Adicione Capabilities (se necessário)**
   - No target do app: `Signing & Capabilities`
   - Adicione `App Groups` (para compartilhar dados com widgets)
   - Adicione `Push Notifications` (para notificações)

5. **Compile e Execute**
   - Selecione "My Mac" como destino
   - Pressione `Cmd + R` ou clique em "Run"

### **Configuração do Core Data**

O arquivo `.xcdatamodeld` já está configurado com as seguintes entidades:
- **ReceitaEntity**: id, valor, descrição, categoria, data, metaAssociada
- **DespesaEntity**: id, valor, descrição, categoria, dataVencimento, status, metaAssociada, dataPagamento
- **MetaEntity**: id, nome, valorTotal, valorAcumulado, prazo, descrição, cor

---

## 📱 Como Usar

### **Dashboard**
- Veja seu saldo, receitas e despesas do mês
- Acompanhe gráficos de evolução mensal
- Visualize o progresso das suas metas
- Acesse últimas movimentações

### **Receitas**
- Clique em "+" para adicionar nova receita
- Preencha valor, descrição, categoria e data
- Opcionalmente, associe a uma meta
- Use a busca e filtros para encontrar receitas

### **Despesas**
- Adicione despesas com data de vencimento
- Marque como paga clicando no ícone ✓
- Receba notificações automáticas antes do vencimento
- Filtre por status (Pago/Não Pago/Atrasado)

### **Metas**
- Crie quantas metas desejar
- Defina nome, valor total e prazo (opcional)
- Escolha uma cor personalizada
- Adicione valores conforme economizar
- Acompanhe o progresso em tempo real

### **Widgets**
- Adicione widgets à sua área de notificações
- Escolha entre 3 tamanhos (pequeno, médio, grande)
- Clique em "Atualizar Widgets" na toolbar para sincronizar

### **Relatórios**
- Navegue até "Relatórios" no menu lateral
- Clique em "Exportar Relatório PDF"
- O PDF será aberto automaticamente no Finder
- Compartilhe ou imprima conforme necessário

---

## 🔔 Notificações

O app solicita permissão para notificações na primeira execução.

**Notificações enviadas:**
- **3 dias antes do vencimento**: Lembrete preventivo
- **No dia do vencimento**: Alerta de pagamento

**Para desabilitar:**
- Vá em Preferências do Sistema → Notificações → LifeOS
- Ajuste as configurações conforme preferir

---

## 💾 Dados e Persistência

- **Todos os dados são armazenados localmente** usando Core Data
- **Não há sincronização com iCloud** (pode ser adicionada futuramente)
- **Backup**: Os dados ficam em `~/Library/Application Support/LifeOS/`
- **Para resetar dados**: Delete o app e reinstale

---

## 🎯 Melhorias Futuras

### **Funcionalidades Sugeridas**

1. **Sincronização iCloud**
   - Compartilhar dados entre dispositivos Mac/iOS

2. **Categorias Personalizadas**
   - Criar e gerenciar categorias próprias
   - Ícones personalizados para categorias

3. **Gráficos Avançados**
   - Gráficos de pizza interativos
   - Comparação ano a ano
   - Projeções futuras

4. **Importação/Exportação**
   - Importar extratos bancários (CSV, OFX)
   - Exportar dados para Excel

5. **Orçamento Mensal**
   - Definir limites por categoria
   - Alertas de gastos excessivos

6. **Recorrência**
   - Despesas recorrentes (assinaturas, contas fixas)
   - Receitas recorrentes (salário)

7. **Multi-moeda**
   - Suporte a múltiplas moedas
   - Conversão automática

8. **Tags e Filtros Avançados**
   - Sistema de tags personalizadas
   - Filtros complexos e salvos

9. **Compartilhamento Familiar**
   - Gerenciar finanças em conjunto
   - Permissões por usuário

10. **Widgets para iOS/iPadOS**
    - Versão do app para iPhone e iPad
    - Widgets para tela inicial

---

## 🐛 Troubleshooting

### **O app não compila**
- Verifique se todos os arquivos estão no target correto
- Limpe o build folder: `Cmd + Shift + K`
- Delete Derived Data: `Cmd + Option + Shift + K`

### **Notificações não aparecem**
- Verifique as permissões em Preferências do Sistema
- Certifique-se de que "Não Perturbe" está desativado

### **Widgets não atualizam**
- Clique em "Atualizar Widgets" na toolbar
- Remova e adicione o widget novamente
- Reinicie o app

### **Dados não salvam**
- Verifique se o Core Data foi inicializado corretamente
- Confira os logs do console para erros

---

## 📄 Licença

Projeto pessoal desenvolvido para estudo e uso pessoal.

---

## 👨‍💻 Desenvolvedor

**Abel Chiquetti**
- Criado em: 15 de novembro de 2025
- Plataforma: macOS exclusivo
- Framework: Swift + SwiftUI
- Arquitetura: MVVM

---

## 🙏 Agradecimentos

- Apple por Swift, SwiftUI e WidgetKit
- Comunidade Swift por recursos e documentação
- Design inspirado no macOS Sonoma/Sequoia

---

**Versão**: 1.0.0  
**Build**: 2025.11.15

---

## 🗂️ Estrutura de Arquivos

```
LifeOS/
│
├── LifeOS/                          # App Principal
│   │
│   ├── AppMain.swift                # ⭐ Ponto de entrada do app
│   ├── ContentView.swift            # Shell principal com NavigationSplitView
│   │
│   ├── Models/                      # 📦 Modelos de dados
│   │   ├── Receita.swift            # Model de Receita + Extensions Core Data
│   │   ├── Despesa.swift            # Model de Despesa + Extensions Core Data
│   │   └── Meta.swift               # Model de Meta + Extensions Core Data
│   │
│   ├── Views/                       # 🖼️ Interfaces do usuário
│   │   ├── DashboardView.swift      # Dashboard com métricas e gráficos
│   │   ├── ReceitasView.swift       # Listagem e gerenciamento de receitas
│   │   ├── DespesasView.swift       # Listagem e gerenciamento de despesas
│   │   └── MetasView.swift          # Listagem e gerenciamento de metas
│   │
│   ├── ViewModels/                  # 🧠 Lógica de negócio
│   │   ├── DashboardViewModel.swift # ViewModel do Dashboard
│   │   ├── ReceitasViewModel.swift  # ViewModel de Receitas
│   │   ├── DespesasViewModel.swift  # ViewModel de Despesas
│   │   └── MetasViewModel.swift     # ViewModel de Metas
│   │
│   ├── Services/                    # ⚙️ Serviços e utilitários
│   │   ├── CoreDataService.swift    # CRUD e operações Core Data
│   │   ├── NotificationService.swift # Gerenciamento de notificações
│   │   └── PDFExporterService.swift # Exportação de relatórios PDF
│   │
│   ├── Components/                  # 🎨 Componentes reutilizáveis
│   │   ├── LiquidComponents.swift   # Componentes visuais Liquid/Glass
│   │   └── FormatHelper.swift       # Helpers de formatação (BRL, datas)
│   │
│   ├── DataModel.xcdatamodeld/      # 💾 Core Data Model
│   │   └── DataModel.xcdatamodel/
│   │       └── contents             # Schema XML das entidades
│   │
│   └── Assets.xcassets/             # 🎨 Assets e recursos visuais
│       ├── AppIcon.appiconset/
│       └── AccentColor.colorset/
│
├── LifeOSWidgets/                   # 📊 Widget Extension
│   └── LifeOSWidgets.swift          # Widgets para macOS (pequeno, médio, grande)
│
├── LifeOS.xcodeproj/                # 🔧 Projeto Xcode
│
├── README.md                        # 📖 Documentação principal
└── ESTRUTURA_PROJETO.md             # 📁 Este arquivo
```

---

## 📋 Detalhamento dos Arquivos

### **🎯 App Principal**

#### `AppMain.swift`
- Ponto de entrada com `@main`
- Configuração de notificações
- AppDelegate para gerenciar eventos do app
- Definição de tamanho mínimo da janela

#### `ContentView.swift`
- Shell principal do app
- NavigationSplitView com sidebar e detalhe
- Roteamento entre telas (Dashboard, Receitas, Despesas, Metas, Relatórios)
- Toolbar com ações de exportação e sincronização
- Core Data Stack integrado

---

### **📦 Models**

#### `Receita.swift`
```swift
struct ReceitaModel {
    - id: UUID
    - valor: Decimal
    - descrição: String
    - categoria: String?
    - data: Date
    - metaAssociada: UUID?
}
```

#### `Despesa.swift`
```swift
struct DespesaModel {
    - id: UUID
    - valor: Decimal
    - descrição: String
    - categoria: String
    - dataVencimento: Date
    - status: StatusDespesa (Pago/Não Pago/Atrasado)
    - metaAssociada: UUID?
    - dataPagamento: Date?
    
    Computed Properties:
    - estaAtrasada: Bool
    - proximaDoVencimento: Bool
}
```

#### `Meta.swift`
```swift
struct MetaModel {
    - id: UUID
    - nome: String
    - valorTotal: Decimal
    - valorAcumulado: Decimal
    - prazo: Date?
    - descrição: String?
    - cor: String (hex)
    
    Computed Properties:
    - progresso: Double (0.0 a 1.0)
    - percentual: Int (0 a 100)
    - valorRestante: Decimal
    - completa: Bool
    - diasRestantes: Int?
}
```

---

### **🖼️ Views**

#### `DashboardView.swift`
- Métricas principais (Saldo, Receitas, Despesas)
- Gráfico mensal com Swift Charts
- Percentual por categoria (gráfico de pizza)
- Últimas movimentações
- Cards de progresso das metas
- Design Liquid Glass com gradientes animados

#### `ReceitasView.swift`
- Lista de receitas com filtros
- Campo de busca
- Filtro por categoria
- Formulário de criação/edição
- Detalhes completos de receita
- Context menu (editar, deletar)

#### `DespesasView.swift`
- Lista de despesas com status visual
- Alertas de despesas atrasadas
- Filtros por status e categoria
- Ação rápida "Marcar como Paga"
- Badges de status coloridos
- Formulário com categorias pré-definidas

#### `MetasView.swift`
- Cards visuais com progresso
- Progresso geral de todas as metas
- Cores personalizáveis
- Modal para adicionar valores
- Detalhes com círculo de progresso grande
- Grid de seleção de cores

---

### **🧠 ViewModels**

Todos seguem o padrão MVVM com `@Published` properties:

#### `DashboardViewModel.swift`
- Agrega dados de receitas, despesas e metas
- Gera séries para gráficos
- Calcula percentuais por categoria
- Função de exportação PDF
- Sincronização de widgets

#### `ReceitasViewModel.swift`
- CRUD de receitas
- Filtros e busca
- Associação com metas
- Cálculo de totais

#### `DespesasViewModel.swift`
- CRUD de despesas
- Gerenciamento de status
- Integração com NotificationService
- Identificação de despesas atrasadas
- Filtros avançados

#### `MetasViewModel.swift`
- CRUD de metas
- Adição de valores ao acumulado
- Cálculo de progresso geral
- Filtros e busca

---

### **⚙️ Services**

#### `CoreDataService.swift`
**Singleton** que gerencia todas as operações de persistência:

**Receitas:**
- `criarReceita(_:)`
- `buscarReceitas()`
- `buscarReceitasDoMes()`
- `atualizarReceita(_:)`
- `deletarReceita(id:)`

**Despesas:**
- `criarDespesa(_:)`
- `buscarDespesas()`
- `buscarDespesasDoMes()`
- `buscarDespesasNaoPagas()`
- `atualizarDespesa(_:)`
- `deletarDespesa(id:)`

**Metas:**
- `criarMeta(_:)`
- `buscarMetas()`
- `atualizarMeta(_:)`
- `deletarMeta(id:)`
- `adicionarValorMeta(id:valor:)`

**Cálculos:**
- `calcularSaldoTotal()`
- `calcularTotalReceitasMes()`
- `calcularTotalDespesasMes()`
- `buscarUltimasMovimentacoes(limite:)`
- `calcularPercentualPorCategoria()`

#### `NotificationService.swift`
**Singleton** para gerenciamento de notificações:

- `solicitarPermissao()` - Pede autorização ao usuário
- `verificarAutorizacao()` - Checa status da permissão
- `agendarNotificacoesDespesa(_:)` - Agenda 2 notificações (3 dias antes + dia do vencimento)
- `removerNotificacoesDespesa(id:)` - Remove notificações de uma despesa
- `atualizarTodasNotificacoes()` - Atualiza todas as notificações pendentes

#### `PDFExporterService.swift`
**Singleton** para geração de PDFs:

- `gerarRelatorioFinanceiro()` - Cria PDF completo com:
  - Cabeçalho com logo e data
  - Resumo financeiro (Saldo, Receitas, Despesas)
  - Lista de receitas do mês
  - Lista de despesas do mês
  - Status de todas as metas
  - Rodapé
- Usa `PDFKit` e `CGContext` para renderização

---

### **🎨 Components**

#### `LiquidComponents.swift`
Componentes visuais reutilizáveis:

- `LiquidGlassPanel` - Fundo com efeito glass
- `GlassCard` - Card genérico com glassmorphism
- `MetricCard` - Card de métrica com ícone
- `ProgressCard` - Card com barra de progresso
- `EmptyStateView` - Estado vazio elegante
- `LoadingView` - Indicador de carregamento
- `AlertBadge` - Badge colorido para status
- `IconButton` - Botão circular com ícone
- `SectionHeader` - Cabeçalho de seção
- `AnimatedBackground` - Gradiente animado

#### `FormatHelper.swift`
Helpers de formatação:

**Valores:**
- `formatarBRL(_:)` - Formata Decimal para R$ X.XXX,XX
- `formatarNumero(_:)` - Formata número com separadores
- `formatarPercentual(_:)` - Formata percentual

**Datas:**
- `formatarData(_:)` - dd/MM/yyyy
- `formatarDataHora(_:)` - dd/MM/yyyy HH:mm
- `formatarDataPorExtenso(_:)` - "1 de janeiro de 2024"
- `nomeDoMes(_:)` - Nome do mês
- `tempoRelativo(_:)` - "há 2 dias", "em 3 dias"
- `diasRestantes(_:)` - Quantos dias faltam
- `textosDiasRestantes(_:)` - Texto descritivo

**Extensions:**
- `Decimal.formatadoBRL`
- `Date.formatado`
- `Date.nomeDoMes`
- `Double.formatadoPercentual`

---

### **💾 Core Data**

#### `DataModel.xcdatamodeld`
Schema com 3 entidades:

**ReceitaEntity:**
- `id: UUID` (required)
- `valor: Decimal` (required)
- `descricao: String` (required)
- `categoria: String` (optional)
- `data: Date` (required)
- `metaAssociada: UUID` (optional)

**DespesaEntity:**
- `id: UUID` (required)
- `valor: Decimal` (required)
- `descricao: String` (required)
- `categoria: String` (required)
- `dataVencimento: Date` (required)
- `status: String` (required, default: "Não Pago")
- `metaAssociada: UUID` (optional)
- `dataPagamento: Date` (optional)

**MetaEntity:**
- `id: UUID` (required)
- `nome: String` (required)
- `valorTotal: Decimal` (required)
- `valorAcumulado: Decimal` (required, default: 0)
- `prazo: Date` (optional)
- `descricao: String` (optional)
- `cor: String` (optional, default: "#007AFF")

---

### **📊 Widgets**

#### `LifeOSWidgets.swift`
Widget Extension com 3 tamanhos:

**Small Widget:**
- Saldo atual
- Data

**Medium Widget:**
- Saldo atual
- Receitas do mês
- Despesas do mês

**Large Widget:**
- Resumo completo (Saldo, Receitas, Despesas)
- Progresso da meta principal
- Data

**Timeline Provider:**
- Busca dados do Core Data
- Atualiza automaticamente
- Placeholder para preview

---

## 🔄 Fluxo de Dados

```
User Input
    ↓
View (SwiftUI)
    ↓
ViewModel (@Published)
    ↓
Service (CoreDataService)
    ↓
Core Data (Persistent Store)
    ↓
Timeline Provider (Widgets)
    ↓
Widget (macOS)
```

---

## 🎨 Design Tokens

### Cores
- **Primary**: Blue (#007AFF)
- **Success**: Green
- **Warning**: Orange
- **Danger**: Red
- **Secondary**: Gray

### Tipografia
- **Headline**: .headline
- **Title**: .title, .title2, .title3
- **Body**: .body, .subheadline
- **Caption**: .caption, .caption2
- **Monospaced**: Para valores numéricos

### Espaçamento
- **Extra Small**: 4pt
- **Small**: 8pt
- **Medium**: 12-16pt
- **Large**: 20-24pt
- **Extra Large**: 32-40pt

### Corner Radius
- **Small**: 8-10pt
- **Medium**: 12-14pt
- **Large**: 16pt
- **Style**: .continuous (mais suave)

---

## 🧪 Como Testar

1. **Receitas**: Adicione algumas receitas e veja os valores atualizarem no dashboard
2. **Despesas**: Crie despesas com datas futuras e passadas para testar notificações
3. **Metas**: Crie uma meta e adicione valores via receitas associadas
4. **Widgets**: Adicione widgets e teste a sincronização
5. **PDF**: Exporte um relatório e verifique o conteúdo
6. **Filtros**: Teste busca e filtros em todas as telas

---

## 📝 Checklist de Implementação

- [x] Models (Receita, Despesa, Meta)
- [x] Core Data Schema
- [x] Services (CoreData, Notification, PDF)
- [x] ViewModels (Dashboard, Receitas, Despesas, Metas)
- [x] Views completas com formulários
- [x] Dashboard com Swift Charts
- [x] Sistema de notificações
- [x] Exportação PDF
- [x] Widgets (Small, Medium, Large)
- [x] Componentes reutilizáveis
- [x] Helpers de formatação
- [x] Design Liquid Glass/Acrylic
- [x] Modo escuro
- [x] Documentação completa
