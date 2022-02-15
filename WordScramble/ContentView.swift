//
//  ContentView.swift
//  WordScramble
//
//  Created by Dante Cesa on 1/13/22.
//

import SwiftUI

struct ContentView: View {
    @State var allWords: [String] = []
    @State private var usedWords: [String] = []
    @State private var rootWord: String = "Test"
    @State private var input: String = ""
    @FocusState private var inputFocused: Bool
    
    @State private var alertText: String = ""
    @State private var alertMessage: String = ""
    @State private var showError: Bool = false
    
    @State private var score: Int = 0
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter a word…", text: $input)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($inputFocused)
                }
                
                if usedWords.count > 0 {
                    Section("Inputted words") {
                        ForEach(usedWords, id:\.self) { word in
                            HStack {
                                Text(word)
                                Spacer()
                                Image(systemName: "\(word.count).circle")
                            }
                            .accessibilityElement()
                            .accessibilityLabel(word)
                            .accessibilityHint("\(word.count) letters")
                        }
                    }
                    Section {
                        HStack {
                            Text("Score is:")
                            Spacer()
                            Image(systemName: "\(score).circle.fill").foregroundColor(.blue)
                        }
                        .accessibilityElement()
                        .accessibilityLabel("Score is \(score)")
                    }
                }
            }
            .navigationTitle(rootWord).navigationBarTitleDisplayMode(.large)
            .onSubmit(addWord)
            .onAppear {
                startGame()
                inputFocused = true
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("New word", action: resetRootWord)
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if usedWords.count > 0 {
                        withAnimation {
                            Button("Reset", action: clearInputtedWords)
                        }
                    }
                }
            }
            .alert(alertText, isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    func addWord() {
        let sanitizedInput = input.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard wordIsntInput(word: sanitizedInput) else {
            showError(title: "Word is the same!", message: "Type in a derivative of the word.")
            return
        }
        
        guard isReal(word: sanitizedInput) else {
            showError(title: "Word not recognized", message: "This must be a real word!")
            return
        }
        
        guard isOriginal(word: sanitizedInput) else {
            showError(title: "Word already exists!", message: "You can't input the same word twice!")
            return
        }
        
        guard isPossible(word: sanitizedInput   ) else {
            showError(title: "Word not possible", message: "This word is not possible from \"\(rootWord)\"")
            return
        }
        
        withAnimation {
            usedWords.insert(sanitizedInput, at: 0)
        }
        
        score += sanitizedInput.count
        
        clearInput()
    }
    
    func clearInput() {
        input = ""
    }
    
    func resetRootWord() {
        rootWord = allWords.randomElement() ?? "silkworm"
        clearInput()
        score = 0
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                
                return
            }
        }
        fatalError("Could not load start.txt from the bundle.")
    }
    
    func clearInputtedWords() {
        usedWords.removeAll()
        clearInput()
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for char in word {
            if let position = tempWord.firstIndex(of: char)  {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        if word == "" {
            return false
        }
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return mispelledRange.location == NSNotFound
    }
    
    func wordIsntInput(word: String) -> Bool {
        rootWord != word
    }
    
    func showError(title: String, message: String) {
        alertText = title
        alertMessage = message
        
        showError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(allWords: ["word1", "word2", "word3"])
    }
}
