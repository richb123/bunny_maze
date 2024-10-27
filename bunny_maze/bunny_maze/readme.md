# Bunny Maze App Documentation

## Overview

The Bunny Maze app is a simple game where a bunny navigates through a maze to reach a carrot located at the bottom-right corner. The user can control the bunny's movements using directional buttons and can generate new mazes of varying sizes.

## Components

### ContentView

The main view that contains the maze and control panel.

#### Properties

- `@State private var steps: [String]`: Stores the sequence of steps for the bunny to follow.
- `@State private var bunnyPosition: (x: Int, y: Int)`: Stores the current position of the bunny.
- `@State private var nextPosition: (x: Int, y: Int)?`: Stores the next position of the bunny.
- `@State private var message: String`: Stores messages to be displayed to the user.
- `@State private var maze: [[Bool]]`: Represents the maze grid.
- `@State private var path: [(x: Int, y: Int)]`: Stores the path taken by the bunny.
- `@State private var mazeSize: Int`: Stores the size of the maze.
- `@State private var isDarkMode: Bool`: Toggles between light and dark mode.

#### Methods

- `runSteps()`: Executes the sequence of steps to move the bunny through the maze.
- `clearSteps()`: Clears the sequence of steps.
- `generateMaze()`: Generates a new maze with random obstacles.
- `resetGame()`: Resets the game to the initial state.
- `animateBunny(resetAfter: Bool)`: Animates the bunny's movement through the maze.

### MazeView

A subview that displays the maze grid, bunny, and carrot.

#### Properties

- `let bunnyPosition: (x: Int, y: Int)`: The current position of the bunny.
- `let nextPosition: (x: Int, y: Int)?`: The next position of the bunny.
- `let maze: [[Bool]]`: The maze grid.
- `let mazeSize: Int`: The size of the maze.
- `let path: [(x: Int, y: Int)]`: The path taken by the bunny.

#### Body

Displays the maze grid with the bunny, obstacles, path, and carrot.

### ControlPanelView

A subview that contains the directional buttons and control buttons (run, clear, generate).

#### Properties

- `@Binding var steps: [String]`: Binds to the sequence of steps for the bunny to follow.
- `var onRun: () -> Void`: Callback for the run button.
- `var onClear: () -> Void`: Callback for the clear button.
- `var onGenerate: () -> Void`: Callback for the generate button.

#### Body

Displays directional buttons (up, down, left, right) to add steps. Displays control buttons (run, clear, generate) to manage the maze and bunny's movements. Displays the sequence of steps as icons.

#### Methods

- `stepIcon(for step: String) -> String`: Returns the appropriate icon for a given step.

### ContentView_Previews

Provides a preview of the `ContentView` for SwiftUI previews.

## Example Code Snippet

Here is the provided code snippet for the `ControlPanelView` and `ContentView_Previews`:

```swift
struct ControlPanelView: View {
    @Binding var steps: [String]
    var onRun: () -> Void
    var onClear: () -> Void
    var onGenerate: () -> Void

    var body: some View {
        VStack {
            HStack {
                Button("⬆️") { steps.append("U") }
                Button("⬇️") { steps.append("D") }
                Button("⬅️") { steps.append("L") }
                Button("➡️") { steps.append("R") }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}