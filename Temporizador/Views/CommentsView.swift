//
//  CommentsView.swift
//  Temporizador
//
//  Created by Jhosel Badillo Cortes on 12/07/23.
//

import SwiftUI

struct CommentsView: View {
    var body: some View {

        VStack {
            Spacer()
            
            Image("profile")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .clipShape(Circle())
            
            HStack{
                Text("Nombre: ")
                    .fontWeight(.bold)
                Text("Jhosel Badillo Cortes")
            }
            
            Text("Comentarios: ")
                .fontWeight(.bold)
            
            Text("En mi caso lo que sentí más fácil de este proyecto fue la realización del temporizador, ya que su lógica es bastante sencilla usando un timer e intervalos de tiempo para así verificar cuando llega a 0. También para llamar a las funciones que se realizan fue bastante fácil. Lo complicado fue buscar otra manera de iniciar la cuenta regresiva, porque el simulador del iPhone no permite detectar si está en una superficie plana, por lo que opte por usar una opción del simulador y en este caso fue verificar el nivel de volumen del dispositivo, en caso de que este al máximo el volumen comienza la cuenta regresiva. También lo que sentí un poco complejo fue la configuración del sonido y vibración. De ahí en fuera fue un proyecto interesante y lleno de retos.").padding()
            Spacer()
        }
    }
}
