//
//  ContentView.swift
//  WordScramble
//
//  Created by Artem Mandych on 09.05.2023.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var numberOfWords = 0
    @State private var letterCount = 0
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    var body: some View {
        NavigationView {
                List {
                    Section {
                        TextField("Enter your word", text: $newWord)
                            .textInputAutocapitalization(.never)
                            .foregroundColor(.white)
                    }
                    Section {
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                            .listRowBackground(Color.clear)
                            
                        }
                      
                    }
                        VStack(spacing: 5) {
                            Text("Score")
                                .padding(5)
                                .background(.secondary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .font(.headline.monospaced().bold())
                                .foregroundColor(.black)
                            Text("Number of words: \(numberOfWords)")
                                .padding(5)
                                .foregroundColor(.white)
                                .background(.secondary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text("Total of letters: \(letterCount)")
                                .padding(5)
                                .foregroundColor(.white)
                                .background(.secondary)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .listRowBackground(Color.clear)
                        .frame(maxWidth: .infinity)
                        .padding()
                            .font(.headline.monospaced())
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .listStyle(.plain)
                .background(.linearGradient(colors: [.mint, .blue], startPoint: .top, endPoint: .bottom))
                .navigationTitle(rootWord)
                .onSubmit(addNewWord)
                .onAppear(perform: startGame)
                .alert(errorTitle, isPresented: $showingError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(errorMessage)
                }
                .toolbar{
                    Button("Restart", action: startGame )
                }
            }
    }
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // exit if the remaining string is empty
        guard answer.count >= 3 && answer != rootWord else { return }

        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }

        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
        numberOfWords += 1
        letterCount += answer.count
    }
    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")

                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"
                usedWords.removeAll()
                numberOfWords = 0
                letterCount = 0
                // If we are here everything has worked, so we can exit
                return
            }
        }

        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
