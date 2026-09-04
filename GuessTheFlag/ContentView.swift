//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Ruvaid on 03/08/26.
//

import SwiftUI

struct FlagImage: View {
    var imageName: String

    var body: some View {
        Image(imageName)
            .clipShape(.capsule)
            .shadow(radius: 5)
    }
}

struct LargeWhiteTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundStyle(.white)
    }
}

extension View {
    func largeWhiteTitle() -> some View {
        modifier(LargeWhiteTitle())
    }
}

struct ContentView: View {
    @State private var countries = [
        "Estonia", "France", "Germany", "Ireland",
        "Italy", "Nigeria", "Poland", "Spain",
        "UK", "Ukraine", "US"
    ].shuffled()

    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var score = 0
    @State private var questionCount = 0
    @State private var showingFinalScore = false
    @State private var selectedFlag: Int?

    var body: some View {
        ZStack {
            RadialGradient(
                stops: [
                    .init(
                        color: Color(red: 0.22, green: 0.8, blue: 0.6),
                        location: 0.3
                    ),
                    .init(
                        color: Color(red: 0.1, green: 0.52, blue: 0.42),
                        location: 0.7
                    )
                ],
                center: .top,
                startRadius: 200,
                endRadius: 700
            )
            .ignoresSafeArea()

            VStack {
                Spacer()

                Text("Guess the Flag")
                    .largeWhiteTitle()

                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))

                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }

                    ForEach(0..<3) { number in
                        Button {
                            flagTapped(number)
                        } label: {
                            FlagImage(imageName: countries[number])
                                .rotation3DEffect(
                                    .degrees(
                                        selectedFlag == number ? 360 : 0
                                    ),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                                .scaleEffect(
                                    selectedFlag == number ? 1.05 : selectedFlag == nil ? 1 : 0.8
                                )
                                .opacity(
                                    selectedFlag == nil || selectedFlag == number ? 1 : 0.25
                                )
                        }
                        .disabled(selectedFlag != nil)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))

                Spacer()
                Spacer()

                Text("Score: \(score)")
                    .foregroundStyle(.white)
                    .font(.title.bold())

                Spacer()
            }
            .padding()
        }
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        } message: {
            Text("Your score is \(score)")
        }
        .alert("Game Over", isPresented: $showingFinalScore) {
            Button("Restart", action: restartGame)
        } message: {
            Text("You scored \(score) out of 8.")
        }
    }

    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            scoreTitle = "Correct!"
            score += 1
        } else {
            scoreTitle = "Wrong! That's the flag of \(countries[number])."
            score -= 1
        }

        questionCount += 1

        withAnimation(.easeInOut(duration: 1.1)) {
            selectedFlag = number
        }

        Timer.scheduledTimer(withTimeInterval: 1.1, repeats: false) { _ in
            if questionCount == 8 {
                showingFinalScore = true
            } else {
                showingScore = true
            }
        }
    }

    func askQuestion() {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedFlag = nil
        }

        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
    }

    func restartGame() {
        score = 0
        questionCount = 0
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)

        withAnimation(.easeInOut(duration: 0.3)) {
            selectedFlag = nil
        }
    }
}

#Preview {
    ContentView()
}
