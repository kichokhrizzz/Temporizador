import AVFoundation
import AudioToolbox
import SwiftUI

import AVFoundation
import AudioToolbox
import SwiftUI

struct ContentView: View {
    @State private var countdown: TimeInterval = 60 // 10 segundos
    @State private var isCountingDown = false
    @State private var showMessage = false
    @State private var isPaused = false
    @State private var timer: Timer?
    @State private var timers: [Timer] = [] // Array para almacenar todas las instancias de Timer
    
    @State private var isMenuOpen = false
    
    @State private var showSettings = false
    @State private var showComments = false
    
    @State private var vibrateAndSound = true
    @State private var vibrateOnly = false
    @State private var soundOnly = false
    
    @State private var isCancelButton = false // Agregada variable para controlar el estado del botón
    @State private var isTimerRunning = false // Variable para rastrear si el temporizador está en ejecución
    
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
                            isCancelButton = true
                            checkVolumeContinuously()
                        }
                    }) {
                        Text(isCancelButton ? "Cancelar" : "Comenzar") // Cambio de etiqueta del botón
                            .font(.headline)
                            .padding()
                            .background(isCancelButton ? Color.red : Color("orange")) // Cambio de color del botón
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    .onChange(of: isCancelButton) { newValue in
                        if newValue == false {
                            resetFlow() // Reiniciar el flujo de la aplicación
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
                SettingsView(
                    vibrateAndSound: $vibrateAndSound,
                    vibrateOnly: $vibrateOnly,
                    soundOnly: $soundOnly,
                    selectedSound: $selectedSound,
                    selectedVibration: $selectedVibration
                )
            }
            .sheet(isPresented: $showComments) {
                CommentsView()
            }
        }
        .onChange(of: countdown) { newValue in
            if newValue <= 0 {
                stopCountdown()
                playCompletionSound()
                cancelAllTimers()
                isCancelButton = false // Restablecer el estado del botón
            }
        }
    }
    
    private func startCountdown() {
        isCountingDown = true
        
        if countdown > 0 { // Verificar si el tiempo restante es mayor que 0
            timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { timer in
                if !isPaused {
                    countdown -= 0.001
                }
            }
            timers.append(timer!) // Agregar el timer al array de timers
        } else {
            stopCountdown()
            playCompletionSound()
            cancelAllTimers()
            isCancelButton = false // Restablecer el estado del botón
        }
        
        showMessage = false
        isTimerRunning = true // Indicar que el temporizador está en ejecución
    }
    
    private func stopCountdown() {
        isCountingDown = false
        timer?.invalidate()
        timer = nil
        isTimerRunning = false // Indicar que el temporizador ha finalizado
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
        isCancelButton = false // Volver al flujo inicial de la aplicación
        cancelAllTimers()
    }
    
    private func cancelAllTimers() {
        for timer in timers {
            timer.invalidate() // Invalidar cada timer
        }
        
        timers.removeAll() // Limpiar el array de timers
    }
    
    private func resetFlow() {
        stopCountdown()
        isPaused = false
        updateCountdown()
        showMessage = false
        isCancelButton = false // Volver al flujo inicial de la aplicación
    }
    
    private func updateCountdown() {
        countdown = 60
    }
    
    private func timeFormatted(_ totalSeconds: TimeInterval) -> String {
        let milliseconds = Int(totalSeconds * 1000) % 1000
        let seconds = Int(totalSeconds) % 60
        let minutes = Int(totalSeconds) / 60
        
        return String(format: "%02d:%02d:%03d", minutes, seconds, milliseconds)
    }
    
    private func checkVolumeContinuously() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            let maxVolume = 1.0
            let currentVolume = getCurrentVolume()
            if currentVolume == Float(maxVolume) {
                timer.invalidate()
                startCountdown()
                isCancelButton = true // Cambiar el estado del botón a "Cancelar"
            }
        }
        timers.append(timer!) // Agregar el timer al array de timers
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
        var systemSoundID: SystemSoundID = 0 // Inicializar con valor nulo
        
        switch selectedSound {
        case .defaultSound:
            systemSoundID = SystemSoundID(1005) // ID del sonido predeterminado
        case .alternativeSound:
            systemSoundID = SystemSoundID(1006) // ID del sonido alternativo
        }
        
        if vibrateAndSound {
            switch selectedVibration {
            case .defaultVibration:
                print("Antes de reproducir la vibración default")
                // Reproducir el sonido seleccionado por el usuario y la vibración predeterminada
                AudioServicesPlayAlertSoundWithCompletion(systemSoundID) {
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                }
                print("Después de reproducir la vibración default")
            case .heavyVibration:
                // Reproducir el sonido seleccionado por el usuario y la vibración intensa
                AudioServicesPlayAlertSoundWithCompletion(systemSoundID) {
                    
                    // Reproducir la vibración intensa durante un período de tiempo más largo
                    let durationInSeconds: TimeInterval = 2.0 // Duración de la vibración en segundos
                    let endTime = Date().addingTimeInterval(durationInSeconds)
                    print("Antes de reproducir la vibración fuerte")
                    while Date() < endTime {
                        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                        usleep(50000) // Esperar 0.05 segundos entre cada vibración
                    }
                    print("Después de reproducir la vibración fuerte")
                }
            }
        } else if soundOnly {
            // Reproducir solo el sonido seleccionado por el usuario
            AudioServicesPlaySystemSound(systemSoundID)
        } else if vibrateOnly {
            switch selectedVibration {
            case .defaultVibration:
                print("Antes de reproducir la vibración default")
                // Reproducir solo la vibración predeterminada
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                print("Después de reproducir la vibración default")
            case .heavyVibration:
                // Reproducir la vibración intensa durante un período de tiempo más largo
                let durationInSeconds: TimeInterval = 2.0 // Duración de la vibración en segundos
                let endTime = Date().addingTimeInterval(durationInSeconds)
                print("Antes de reproducir la vibración fuerte")
                
                while Date() < endTime {
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    usleep(50000) // Esperar 0.05 segundos entre cada vibración
                }
                print("Después de reproducir la vibración fuerte")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
