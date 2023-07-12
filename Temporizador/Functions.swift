//
//  Functions.swift
//  Temporizador
//
//  Created by Jhosel Badillo Cortes on 12/07/23.
//

import Foundation


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
        switch selectedVibration {
        case .defaultVibration:
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        case .heavyVibration:
            // Reproducir la vibración intensa por un período de tiempo más largo
            let durationInSeconds: TimeInterval = 2.0 // Duración de la vibración en segundos
            let endTime = Date().addingTimeInterval(durationInSeconds)
            
            while Date() < endTime {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                usleep(50000) // Esperar 0.05 segundos entre cada vibración
            }
        }
    }
}
