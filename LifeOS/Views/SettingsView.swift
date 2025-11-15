//
//  SettingsView.swift
//  LifeOS
//
//  Tela de preferências do usuário.
//

import SwiftUI

struct SettingsView: View {
    @Binding var usuarioNome: String
    @AppStorage("mostrarAlertas") private var mostrarAlertas: Bool = true
    @AppStorage("sincronizarWidgetsAutomaticamente") private var sincronizarWidgetsAutomaticamente: Bool = true
    
    var body: some View {
        Form {
            Section("Perfil") {
                TextField("Seu nome", text: $usuarioNome)
                    .textFieldStyle(.roundedBorder)
                Text("Usado para saudar você no topo do app.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Section("Preferências") {
                Toggle("Mostrar alertas de erros", isOn: $mostrarAlertas)
                Toggle("Atualizar widgets automaticamente", isOn: $sincronizarWidgetsAutomaticamente)
            }
            
            Section("Sobre o LifeOS") {
                LabeledContent("Criador", value: "Abel Chiquetti")
                LabeledContent("Repositório", value: "github.com/AbelChiquetti/LifeOS")
                LabeledContent("Licença", value: "CC BY-NC 4.0 (uso não comercial)")
                LabeledContent("Status", value: "Em desenvolvimento")
            }
        }
        .padding(20)
        .frame(minWidth: 400, minHeight: 300)
    }
}

#Preview {
    SettingsView(usuarioNome: .constant("Abel"))
}
