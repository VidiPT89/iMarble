import SwiftUI

struct SetupGameView: View {
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var settings: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var setup = SetupViewModel()
    @State private var startGame = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient.ignoresSafeArea()
                Form {
                    Section(localization.string(.players)) {
                        ForEach($setup.players) { $player in
                            HStack {
                                Circle().fill(AppTheme.color(named: player.colorName)).frame(width: 16, height: 16)
                                TextField(localization.string(.playerName), text: $player.name)
                                Spacer()
                                Toggle(isOn: Binding(
                                    get: { player.isHuman },
                                    set: { player.isHuman = $0 }
                                )) {
                                    Text(player.isHuman ? localization.string(.human) : localization.string(.computer))
                                        .font(.caption)
                                }
                                .labelsHidden()
                            }
                            if !player.isHuman {
                                Picker(localization.string(.aiDifficulty), selection: $player.aiDifficulty) {
                                    Text(localization.string(.difficultyEasy)).tag(AIDifficulty.easy)
                                    Text(localization.string(.difficultyNormal)).tag(AIDifficulty.normal)
                                    Text(localization.string(.difficultyHard)).tag(AIDifficulty.hard)
                                }
                            }
                        }
                        HStack {
                            Button(localization.string(.addPlayer)) { setup.addPlayer() }
                                .disabled(setup.players.count >= 4)
                            Spacer()
                            Button(localization.string(.removePlayer)) { setup.removePlayer() }
                                .disabled(setup.players.count <= 2)
                        }
                    }

                    Section(localization.string(.courseLabel)) {
                        Picker(localization.string(.courseLabel), selection: $setup.courseType) {
                            Text(localization.string(.courseOneWay)).tag(CourseType.oneWay)
                            Text(localization.string(.courseRoundTrip)).tag(CourseType.roundTrip)
                            Text(localization.string(.courseRoundTripPapa)).tag(CourseType.roundTripWithPapa)
                        }
                    }

                    Section(localization.string(.victoryModeLabel)) {
                        Picker(localization.string(.victoryModeLabel), selection: $setup.victoryMode) {
                            Text(localization.string(.victoryClassic)).tag(VictoryMode.classic)
                            Text(localization.string(.victoryPoints)).tag(VictoryMode.points)
                        }
                        .pickerStyle(.segmented)
                        if setup.victoryMode == .points {
                            Stepper("\(localization.string(.victoryTargetScore)): \(setup.targetScore)", value: $setup.targetScore, in: 5...50, step: 5)
                        }
                    }

                    Section {
                        Toggle(localization.string(.soundLabel), isOn: $setup.soundEnabled)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(localization.string(.setupTitle))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localization.string(.close)) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(localization.string(.startGame)) { startGame = true }
                        .accessibilityIdentifier("startGameButton")
                }
            }
            .fullScreenCover(isPresented: $startGame) {
                GameView(viewModel: GameViewModel(players: setup.players, rules: setup.buildRules()))
            }
        }
    }
}

#Preview {
    SetupGameView()
        .environmentObject(SettingsViewModel())
        .environmentObject(LocalizationManager.shared)
}
