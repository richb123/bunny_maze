import SwiftUI

struct ContentView: View {
    @State private var steps: [String] = []
    @State private var bunnyPosition: (x: Int, y: Int) = (0, 0)
    @State private var nextPosition: (x: Int, y: Int)? = nil
    @State private var message: String = ""
    @State private var maze: [[Bool]] = Array(repeating: Array(repeating: false, count: 8), count: 8)
    @State private var path: [(x: Int, y: Int)] = []
    @State private var mazeSize: Int = 8
    @State private var isDarkMode: Bool = true // Start in dark mode
    @State private var showVictoryScreen: Bool = false // Show victory screen
    @AppStorage("totalWins") private var totalWins: Int = 0 // Store total wins persistently

    var body: some View {
        VStack {
            if showVictoryScreen {
                VictoryView(totalWins: totalWins, onDismiss: {
                    showVictoryScreen = false
                    resetGame()
                })
            } else {
                MazeView(bunnyPosition: bunnyPosition, nextPosition: nextPosition, maze: maze, mazeSize: mazeSize, path: path)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                ControlPanelView(steps: $steps, onRun: runSteps, onClear: clearSteps, onGenerate: generateMaze)
                Image(systemName: "message.fill")
                    .padding()
                Slider(value: Binding(get: {
                    Double(mazeSize)
                }, set: { newValue in
                    mazeSize = Int(newValue)
                    generateMaze()
                }), in: 5...15, step: 1)
                .padding()
                Image(systemName: "square.grid.2x2.fill")
                    .padding()
                Toggle(isOn: $isDarkMode) {
                    Image(systemName: "moon.fill")
                }
                .padding()
            }
        }
        .padding()
        .onAppear(perform: generateMaze)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }

    func runSteps() {
        var position = (x: 0, y: 0)
        path = [position]
        for step in steps {
            switch step {
            case "U": position.y = max(position.y - 1, 0)
            case "D": position.y = min(position.y + 1, mazeSize - 1)
            case "L": position.x = max(position.x - 1, 0)
            case "R": position.x = min(position.x + 1, mazeSize - 1)
            default: break
            }
            if maze[position.y][position.x] {
                message = "Bunny hit an obstacle!"
                animateBunny()
                return
            }
            path.append(position)
        }
        bunnyPosition = position
        if position == (mazeSize - 1, mazeSize - 1) {
            message = "Bunny reached the goal!"
            totalWins += 1 // Increment total wins
            animateBunny(resetAfter: true)
        } else {
            message = "Bunny did not reach the goal."
            animateBunny(resetAfter: false)
        }
    }

    func clearSteps() {
        steps.removeAll()
    }

    func generateMaze() {
        // Clear the maze
        maze = Array(repeating: Array(repeating: false, count: mazeSize), count: mazeSize)
        
        // Create a guaranteed path from start to end
        var path = [(x: Int, y: Int)]()
        var position = (x: 0, y: 0)
        path.append(position)
        
        while position != (mazeSize - 1, mazeSize - 1) {
            let direction = Int.random(in: 0...1)
            if direction == 0 && position.x < mazeSize - 1 {
                position.x += 1
            } else if position.y < mazeSize - 1 {
                position.y += 1
            } else {
                position.x += 1
            }
            path.append(position)
        }
        
        // Place obstacles randomly, ensuring the path remains clear
        for row in 0..<mazeSize {
            for col in 0..<mazeSize {
                if !path.contains(where: { $0 == (col, row) }) {
                    maze[row][col] = Bool.random()
                }
            }
        }
    }

    func resetGame() {
        bunnyPosition = (0, 0)
        steps.removeAll()
        generateMaze()
    }

    func animateBunny(resetAfter: Bool = false) {
        for (index, position) in path.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                withAnimation {
                    bunnyPosition = position
                    nextPosition = index < path.count - 1 ? path[index + 1] : nil
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(path.count) * 0.5 + 2) {
            withAnimation {
                if resetAfter {
                    bunnyPosition = (0, 0)
                    nextPosition = nil
                    path.removeAll() // Clear the path after reaching the goal
                    showVictoryScreen = true // Show victory screen
                } else {
                    bunnyPosition = (0, 0)
                    nextPosition = nil
                    path.removeAll() // Clear the path if not reaching the goal
                }
            }
        }
    }
}

struct MazeView: View {
    let bunnyPosition: (x: Int, y: Int)
    let nextPosition: (x: Int, y: Int)?
    let maze: [[Bool]]
    let mazeSize: Int
    let path: [(x: Int, y: Int)]

    var body: some View {
        GeometryReader { geometry in
            let cellSize = min(geometry.size.width, geometry.size.height) / CGFloat(mazeSize)
            VStack(spacing: 2) {
                ForEach(0..<mazeSize, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<mazeSize, id: \.self) { col in
                            Text(bunnyPosition == (col, row) ? "🐰" : (maze[row][col] ? "🪨" : (row == mazeSize - 1 && col == mazeSize - 1 ? "🥕" : "🌿")))
                                .frame(width: cellSize, height: cellSize)
                                .background {
                                    if let nextPos = nextPosition, nextPos == (col, row) {
                                        Color.yellow.opacity(0.5)
                                    } else if row == mazeSize - 1 && col == mazeSize - 1 {
                                        Color.blue.opacity(0.5)
                                    } else {
                                        Color.gray.opacity(0.2)
                                    }
                                }
                                .border(Color.black, width: 1) // Add border to make walls visible
                                .cornerRadius(5)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
    }
}

struct ControlPanelView: View {
    @Binding var steps: [String]
    var onRun: () -> Void
    var onClear: () -> Void
    var onGenerate: () -> Void

    var body: some View {
        VStack {
            HStack {
                Button(action: { steps.append("U") }) {
                    Image(systemName: "arrow.up")
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                }
                Button(action: { steps.append("D") }) {
                    Image(systemName: "arrow.down")
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                }
                Button(action: { steps.append("L") }) {
                    Image(systemName: "arrow.left")
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                }
                Button(action: { steps.append("R") }) {
                    Image(systemName: "arrow.right")
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                }
            }
            .padding()
            HStack {
                Button(action: onRun) {
                    Image(systemName: "play.fill")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                Button(action: onClear) {
                    Image(systemName: "trash.fill")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
                Button(action: onGenerate) {
                    Image(systemName: "arrow.clockwise")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
            }
            .padding()
            HStack {
                ForEach(steps, id: \.self) { step in
                    Text(stepIcon(for: step))
                }
            }
            .padding()
        }
    }

    func stepIcon(for step: String) -> String {
        switch step {
        case "U": return "⬆️"
        case "D": return "⬇️"
        case "L": return "⬅️"
        case "R": return "➡️"
        default: return ""
        }
    }
}

struct VictoryView: View {
    var totalWins: Int
    var onDismiss: () -> Void

    var body: some View {
        VStack {
            Image(systemName: "star.fill")
                .font(.system(size: 100))
                .foregroundColor(.yellow)
                .padding()
            Image(systemName: "trophy.fill")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
                .padding()
            Text("Total Wins: \(totalWins)")
                .font(.title)
                .padding()
            Button(action: onDismiss) {
                Image(systemName: "arrow.clockwise")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
        .foregroundColor(.white)
        .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}