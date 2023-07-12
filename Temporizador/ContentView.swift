//
//  ContentView.swift
//  Temporizador
//
//  Created by Jhosel Badillo Cortes on 11/07/23.
//

import SwiftUI

import AVFoundation
import SwiftUI

struct ContentView: View {
    @State private var countdown: TimeInterval = 10 * 60 // 10 minutos en segundos
    @State private var isCountingDown = false
    @State private var showMessage = false
    @State private var timer: Timer?
    
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
                    
                    Button(action: {
                        if isCountingDown {
                            stopCountdown()
                        } else {
                            let maxVolume = 1.0
                            let currentVolume = getCurrentVolume()
                            if currentVolume == Float(maxVolume) {
                                showMessage = true
                                startCountdown()
                            } else {
                                // Mostrar mensaje de que el volumen no está al máximo
                            }
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
                    // Acción del botón
                }) {
                    Image(systemName: "line.3.horizontal")
                }
            )
        }
    }
    
    private func startCountdown() {
        isCountingDown = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            countdown -= 1
            if countdown <= 0 {
                stopCountdown()
            }
        }
    }
    
    private func stopCountdown() {
        isCountingDown = false
        timer?.invalidate()
        timer = nil
    }
    
    private func updateCountdown() {
        countdown = 10 * 60
    }
    
    private func timeFormatted(_ totalSeconds: TimeInterval) -> String {
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
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
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
