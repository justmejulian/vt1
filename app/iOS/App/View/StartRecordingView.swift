//
//  Created by Julian Visser on 27.10.2023.
//

import Foundation
import SwiftUI

struct StartRecordingView: View {

    @State private var text: String = ""
    @StateObject private var networkViewModel = NetworkViewModel()
    @State private var isRequestCompleted = true

    var body: some View {
        VStack(content: {
            Text("VT1 2023")
                .font(.largeTitle)
                .padding(.all)
            VStack(content: {
                Spacer()
                Text("Exercise")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                TextField("Squat", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .multilineTextAlignment(.center)
                    .padding(.all)

                Spacer()
            })
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity)
                .padding(.all)
            Button(action: start) {
                Text("Start Recording")
                    .font(.title2)
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
            }
                .buttonStyle(.borderedProminent)
                .disabled(!isRequestCompleted)
                .padding(.all)
        })
    }

    private func start() {
        isRequestCompleted = false
    }
}

#Preview {
    StartRecordingView()
}
