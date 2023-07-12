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
                Menu {
                    Button(action: {
                        showSettings = true
                    }) {
                        Label("Configuración", systemImage: "gear")
                    }
                    
                    Button(action: {
                        showComments = true
                    }) {
                        Label("Comentarios", systemImage: "newspaper.fill")
                    }
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .imageScale(.large)
                        .foregroundColor(.orange)
                }
            )
            .sheet(isPresented: $showSettings) {
                // Mostrar la pantalla de configuración
                SettingsView()
            }
            .sheet(isPresented: $showComments) {
                // Mostrar la pantalla de comentarios
                CommentsView()
            }
        }
    }
    
    private func startCountdown() {
        isCountingDown = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if !isPaused {
                countdown -= 1
                if countdown <= 0 {
                    stopCountdown()
                    performVibrationAndSound()
                }
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
    
    private func performVibrationAndSound() {
        // Vibrar el dispositivo
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        // Reproducir un sonido
        let systemSoundID: SystemSoundID = 1005 // Puedes cambiar el valor por el ID de otro sonido
        AudioServicesPlaySystemSound(systemSoundID)
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Pantalla de configuración")
    }
}

struct CommentsView: View {
    var body: some View {
        Text("Pantalla de comentarios")
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
