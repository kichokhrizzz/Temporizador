//
//  SettingsView.swift
//  Temporizador
//
//  Created by Jhosel Badillo Cortes on 12/07/23.
//

import SwiftUI

struct SettingsView: View {
    @Binding var vibrateAndSound: Bool
    @Binding var vibrateOnly: Bool
    @Binding var soundOnly: Bool
    @Binding var selectedSound: ContentView.SoundType
    @Binding var selectedVibration: ContentView.VibrationType
    
    var body: some View {
        Form {
            Section(header: Text("Configuración")) {
                Toggle(isOn: $vibrateAndSound.animation()) {
                    Text("Vibrar y Sonar")
                }
                .onChange(of: vibrateAndSound) { newValue in
                    if newValue {
                        vibrateOnly = false
                        soundOnly = false
                        
                    }
                }
                
                Toggle(isOn: $vibrateOnly.animation()) {
                    Text("Solo Vibrar")
                }
                .onChange(of: vibrateOnly) { newValue in
                    if newValue {
                        vibrateAndSound = false
                        soundOnly = false
                    } else if !newValue && !soundOnly {
                        vibrateAndSound = true
                    }
                }
                
                Toggle(isOn: $soundOnly.animation()) {
                    Text("Solo Sonar")
                }
                .onChange(of: soundOnly) { newValue in
                    if newValue {
                        vibrateAndSound = false
                        vibrateOnly = false
                    } else if !newValue && !vibrateOnly {
                        vibrateAndSound = true
                    }
                }
            }
            
            Section(header: Text("Tipo de sonido")) {
                HStack {
                    Text("Sonido predeterminado")
                    Spacer()
                    if selectedSound == .defaultSound {
                        Image(systemName: "checkmark")
                    }
                }
                .onTapGesture {
                    selectedSound = .defaultSound
                }
                
                HStack {
                    Text("Sonido alternativo")
                    Spacer()
                    if selectedSound == .alternativeSound {
                        Image(systemName: "checkmark")
                    }
                }
                .onTapGesture {
                    selectedSound = .alternativeSound
                }
            }
            
            Section(header: Text("Tipo de vibración")) {
                HStack {
                    Text("Vibración predeterminada")
                    Spacer()
                    if selectedVibration == .defaultVibration {
                        Image(systemName: "checkmark")
                    }
                }
                .onTapGesture {
                    selectedVibration = .defaultVibration
                }
                
                HStack {
                    Text("Vibración intensa")
                    Spacer()
                    if selectedVibration == .heavyVibration {
                        Image(systemName: "checkmark")
                    }
                }
                .onTapGesture {
                    selectedVibration = .heavyVibration
                }
            }
        }
        .navigationBarTitle("Configuración")
    }
}

