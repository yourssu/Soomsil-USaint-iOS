//
//  CircleLoadingView.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

import SwiftUI

struct CircleLoadingView: View {
    @State private var isLoading = false

       var body: some View {
           ZStack {
               Color(red: 0.77, green: 0.77, blue: 0.77).opacity(0.3)
                      .edgesIgnoringSafeArea(.all)
               ZStack {
                   Circle()
                       .stroke(Color(red: 0.89, green: 0.88, blue: 0.91), lineWidth: 7)
                       .frame(width: 50, height: 50)

                   Circle()
                       .trim(from: 0, to: 0.2)
                       .stroke(
                           Color(red: 0.49, green: 0.44, blue: 0.8),
                           style: StrokeStyle(
                               lineWidth: 7,
                               lineCap: .round
                           )
                       )
                       .frame(width: 50, height: 50)
                       .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                       .animation(
                           .linear(duration: 1)
                               .repeatForever(autoreverses: false),
                           value: isLoading
                       )
                       .onAppear() {
                           self.isLoading = true
                   }
               }
               .padding(.bottom, 140)
           }
       }
}

struct loadingView_Previews: PreviewProvider {

    static var previews: some View {
        CircleLoadingView()
    }
}
