//
//  ContentView.swift
//  Temporizador
//
//  Created by Jhosel Badillo Cortes on 11/07/23.
//
import AVFoundation
import AudioToolbox
import SwiftUI

struct ContentView: View {
    @State private var countdown: TimeInterval = 10 // 10 segundos
    @State private var isCountingDown = false
    @State private var showMessage = false
    @State private var isPaused = false
    @State private var timer: Timer?
    
    @State private var isMenuOpen = false
    
    @State private var showSettings = false
    @State private var showComments = false
    
    @State private var vibrateAndSound = true
    @State private var vibrateOnly = false
    @State private var soundOnly = false
    
    
    @State private var selectedSound: SoundType = .defaultSound
    @State private var selectedVibration: VibrationType = .defaultVibration
    
    enum SoundType {
        case defaultSound
        case alternativeSound
    }
    
    enum VibrationType {
        case defaultVibration
        case heavyVibration
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    Text(timeFormatted(countdown))
                        .font(.largeTitle)
                        .foregroundColor(Color.white)
                        .padding()
                    
                    if showMessage {
                        Text("Configurada. Esperando para iniciar")
                            .foregroundColor(Color.white)
                            .font(.headline)
                            .padding()
                    }
                    
                    if isCountingDown {
                        if isPaused {
                            Button(action: {
                                resumeCountdown()
                            }) {
                                Text("Reanudar")
                                    .font(.headline)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding()
                        } else {
                            Button(action: {
                                pauseCountdown()
                            }) {
                                Text("Pausar")
                                    .font(.headline)
                                    .padding()
                                    .background(Color.yellow)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding()
                        }
                    }
                    
                    Button(action: {
                        if isCountingDown {
                            cancelCountdown()
                        } else {
                            showMessage = true
                            checkVolumeContinuously()
                        }
                    }) {
                        Text(isCountingDown ? "Cancelar" : "Comenzar")
                            .font(.headline)
                            .padding()
                            .background(isCountingDown ? Color.red : Color("orange"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    .onChange(of: isCountingDown) { newValue in
                        if !newValue {
                            showMessage = false
                            updateCountdown()
                        }
                    }
                    
                    Spacer()
                }
            }
            .onAppear {
                updateCountdown()
            }
            .navigationBarItems(trailing:
                                    Button(action: {
                isMenuOpen.toggle()
            }) {
                Image(systemName: "line.3.horizontal")
                    .imageScale(.large)
                    .foregroundColor(.orange)
            }
            )
            .fullScreenCover(isPresented: $isMenuOpen) {
                NavigationView {
                    VStack {
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
                        
                        Spacer()
                    }
                    .navigationBarTitle("Configuración")
                    .navigationBarItems(trailing:
                                            Button(action: {
                        isMenuOpen = false
                    }) {
                        Text("Cerrar")
                    }
                    )
                }
            }
        }
        .onChange(of: countdown) { newValue in
            if newValue <= 0 {
                stopCountdown()
                playCompletionSound()
            }
        }
    }
    
    private func startCountdown() {
        isCountingDown = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if !isPaused {
                countdown -= 1
            }
        }
        showMessage = false // Eliminar el mensaje de "Esperando para iniciar"
    }
    
    private func stopCountdown() {
        isCountingDown = false
        timer?.invalidate()
        timer = nil
    }
    
    private func pauseCountdown() {
        isPaused = true
    }
    
    private func resumeCountdown() {
        isPaused = false
    }
    
    private func cancelCountdown() {
        stopCountdown()
        isPaused = false
        updateCountdown()
    }
    
    private func updateCountdown() {
        countdown = 10
    }
    
    private func timeFormatted(_ totalSeconds: TimeInterval) -> String {
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func checkVolumeContinuously() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            let maxVolume = 1.0
            let currentVolume = getCurrentVolume()
            if currentVolume == Float(maxVolume) {
                timer.invalidate()
                startCountdown()
            }
        }
    }
    
    private func getCurrentVolume() -> Float {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            return audioSession.outputVolume
        } catch {
            print("Error al obtener el nivel de volumen: \(error.localizedDescription)")
            return 0.0
        }
    }
    
    private func playCompletionSound() {
        let systemSoundID: SystemSoundID
        
        switch selectedSound {
        case .defaultSound:
            systemSoundID = 1005 // ID del sonido predeterminado
        case .alternativeSound:
            systemSoundID = 1006 // ID del sonido alternativo
        }
        
        if vibrateAndSound {
            AudioServicesPlayAlertSoundWithCompletion(systemSoundID, nil)
        } else if soundOnly {
            AudioServicesPlaySystemSound(systemSoundID)
        } else if vibrateOnly {
            if selectedVibration == .defaultVibration {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            } else if selectedVibration == .heavyVibration {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
