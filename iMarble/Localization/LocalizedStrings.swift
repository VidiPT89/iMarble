import Foundation

enum LocalizedKey: String {
    case appName
    case tagline
    case play
    case rules
    case settings
    case about
    case developedBy
    case startGame
    case numberOfPlayers
    case playerName
    case humanOrComputer
    case human
    case computer
    case aiDifficulty
    case difficultyEasy
    case difficultyNormal
    case difficultyHard
    case victoryModeLabel
    case victoryClassic
    case victoryPoints
    case palmoLabel
    case palmoOn
    case palmoOff
    case courseLabel
    case courseOneWay
    case courseRoundTrip
    case courseRoundTripPapa
    case soundLabel
    case setupTitle
    case yourTurn
    case aimAtFirstHole
    case aimAtHole
    case pullAndRelease
    case enteredHole
    case missedHole
    case dragToPalmo
    case skipPalmo
    case marbleProtected
    case missedAttack
    case hitMarble
    case keptMarble
    case gameOver
    case winnerIs
    case quickRules
    case pause
    case resume
    case restart
    case mainMenu
    case tutorialTitle
    case tutorialStep1
    case tutorialStep2
    case tutorialStep3
    case tutorialStep4
    case tutorialStep5
    case tutorialStep6
    case tutorialSkip
    case tutorialNext
    case tutorialStart
    case rulesTitle
    case rulesBody
    case settingsTitle
    case appearance
    case appearanceSystem
    case appearanceLight
    case appearanceDark
    case language
    case replayTutorial
    case reduceMotion
    case hapticsLabel
    case aboutTitle
    case aboutBody
    case close
    case score
    case captured
    case power
    case chooseTarget
    case confirmPalmo
    case palmoExplanation
    case objective
    case newRound
    case players
    case addPlayer
    case removePlayer
    case fieldTooSmallWarning
    case victoryTargetScore
    case victoryRounds
}

enum LocalizedStrings {
    static let table: [LocalizedKey: [AppLanguage: String]] = [
        .appName: [.portuguese: "Três Covas", .english: "Three Pits"],
        .tagline: [.portuguese: "O jogo tradicional do berlinde", .english: "The traditional marble game"],
        .play: [.portuguese: "Jogar", .english: "Play"],
        .rules: [.portuguese: "Regras", .english: "Rules"],
        .settings: [.portuguese: "Definições", .english: "Settings"],
        .about: [.portuguese: "Sobre o jogo", .english: "About"],
        .developedBy: [.portuguese: "Desenvolvido por David Arsénio Martins", .english: "Developed by David Arsénio Martins"],
        .startGame: [.portuguese: "Começar jogo", .english: "Start game"],
        .numberOfPlayers: [.portuguese: "Número de jogadores", .english: "Number of players"],
        .playerName: [.portuguese: "Nome do jogador", .english: "Player name"],
        .humanOrComputer: [.portuguese: "Tipo", .english: "Type"],
        .human: [.portuguese: "Humano", .english: "Human"],
        .computer: [.portuguese: "Computador", .english: "Computer"],
        .aiDifficulty: [.portuguese: "Dificuldade da IA", .english: "AI difficulty"],
        .difficultyEasy: [.portuguese: "Fácil", .english: "Easy"],
        .difficultyNormal: [.portuguese: "Normal", .english: "Normal"],
        .difficultyHard: [.portuguese: "Difícil", .english: "Hard"],
        .victoryModeLabel: [.portuguese: "Modo de vitória", .english: "Victory mode"],
        .victoryClassic: [.portuguese: "Clássico", .english: "Classic"],
        .victoryPoints: [.portuguese: "Pontos", .english: "Points"],
        .palmoLabel: [.portuguese: "Palmo", .english: "Hand-span"],
        .palmoOn: [.portuguese: "Ligado", .english: "On"],
        .palmoOff: [.portuguese: "Desligado", .english: "Off"],
        .courseLabel: [.portuguese: "Percurso", .english: "Course"],
        .courseOneWay: [.portuguese: "Apenas ida", .english: "One way"],
        .courseRoundTrip: [.portuguese: "Ida e volta", .english: "Round trip"],
        .courseRoundTripPapa: [.portuguese: "Ida e volta com papa", .english: "Round trip with papa"],
        .soundLabel: [.portuguese: "Som", .english: "Sound"],
        .setupTitle: [.portuguese: "Configurar Partida", .english: "Game Setup"],
        .yourTurn: [.portuguese: "É a tua vez.", .english: "It's your turn."],
        .aimAtFirstHole: [.portuguese: "Aponta para a primeira cova.", .english: "Aim at the first hole."],
        .aimAtHole: [.portuguese: "Entra na cova %d", .english: "Enter hole %d"],
        .pullAndRelease: [.portuguese: "Puxa para trás e larga para lançar.", .english: "Pull back and release to launch."],
        .enteredHole: [.portuguese: "Entraste na cova!", .english: "You entered the hole!"],
        .missedHole: [.portuguese: "Falhaste a cova.", .english: "You missed the hole."],
        .dragToPalmo: [.portuguese: "Arrasta o berlinde para o aproximar, até um palmo.", .english: "Drag your marble to move it, up to one hand-span."],
        .skipPalmo: [.portuguese: "Saltar palmo", .english: "Skip hand-span"],
        .marbleProtected: [.portuguese: "Berlinde protegido.", .english: "Marble protected."],
        .missedAttack: [.portuguese: "Falhaste o ataque.", .english: "You missed the attack."],
        .hitMarble: [.portuguese: "Acertaste no berlinde!", .english: "You hit the marble!"],
        .keptMarble: [.portuguese: "Ficaste com o berlinde.", .english: "You kept the marble."],
        .gameOver: [.portuguese: "Fim do jogo.", .english: "Game over."],
        .winnerIs: [.portuguese: "O vencedor é %@", .english: "The winner is %@"],
        .quickRules: [.portuguese: "Regras rápidas", .english: "Quick rules"],
        .pause: [.portuguese: "Pausa", .english: "Pause"],
        .resume: [.portuguese: "Continuar", .english: "Resume"],
        .restart: [.portuguese: "Reiniciar", .english: "Restart"],
        .mainMenu: [.portuguese: "Menu principal", .english: "Main menu"],
        .tutorialTitle: [.portuguese: "Como jogar", .english: "How to play"],
        .tutorialStep1: [.portuguese: "Estas são as três covas: Pira, Meia e Fundo.", .english: "These are the three pits: Pira, Meia and Fundo."],
        .tutorialStep2: [.portuguese: "Faz o percurso Pira → Meia → Fundo e depois de volta até à Pira.", .english: "Run the course Pira → Meia → Fundo, then back to the Pira."],
        .tutorialStep3: [.portuguese: "Puxa o dedo para trás e larga para lançar o berlinde.", .english: "Pull your finger back and release to launch the marble."],
        .tutorialStep4: [.portuguese: "Sempre que entrares numa cova, ganhas um palmo e jogas novamente.", .english: "Every time you enter a pit, you earn a hand-span and play again."],
        .tutorialStep5: [.portuguese: "Só depois de completares o percurso podes atacar, disparando a partir de uma cova.", .english: "Only after completing the course can you attack, launching from a pit."],
        .tutorialStep6: [.portuguese: "Acertar num adversário confisca o berlinde dele para sempre.", .english: "Hitting an opponent permanently confiscates their marble."],
        .tutorialSkip: [.portuguese: "Saltar", .english: "Skip"],
        .tutorialNext: [.portuguese: "Seguinte", .english: "Next"],
        .tutorialStart: [.portuguese: "Começar", .english: "Start"],
        .rulesTitle: [.portuguese: "Regras do Jogo", .english: "Game Rules"],
        .rulesBody: [
            .portuguese: "O campo tem três covas em linha: a Pira (Cova 1), a Meia (Cova 2) e o Fundo (Cova 3). Cada jogador faz o percurso Pira → Meia → Fundo e depois de volta Fundo → Meia → Pira. Sempre que entra numa cova com sucesso, avança 1 palmo e joga novamente. Só depois de completar todo o percurso é que pode \"matar\": atacar berlindes adversários, disparando sempre a partir de uma cova. Acertar confisca o berlinde do adversário para sempre — quem fica sem berlindes é eliminado. Vence quem completar o percurso sem perder o seu berlinde; em caso de empate, vence quem tiver mais berlindes confiscados. No modo por pontos: 2 pontos por cova alcançada, 2 pontos por acertar num adversário e 3 pontos por confiscar um berlinde. Em variações tradicionais existe ainda o \"abafador\", um berlinde maior usado para empurrar berlindes para fora de um círculo.",
            .english: "The field has three pits in a line: the Pira (Pit 1), the Meia (Pit 2) and the Fundo (Pit 3). Each player runs the course Pira → Meia → Fundo and then back Fundo → Meia → Pira. Every successful hole entry earns a 1 hand-span (palmo) advance and another turn. Only after completing the full course can a player \"matar\" — attack opponents' marbles, always launching from a pit. A hit permanently confiscates the opponent's marble; a player with no marbles left is eliminated. The winner is whoever completes the course without losing their marble; ties are broken by whoever holds the most confiscated marbles. In points mode: 2 points per pit reached, 2 points per hit on an opponent, and 3 points per marble confiscated. Traditional variants also feature the \"abafador\", a larger marble used to knock others out of a circle.",
        ],
        .settingsTitle: [.portuguese: "Definições", .english: "Settings"],
        .appearance: [.portuguese: "Aparência", .english: "Appearance"],
        .appearanceSystem: [.portuguese: "Sistema", .english: "System"],
        .appearanceLight: [.portuguese: "Claro", .english: "Light"],
        .appearanceDark: [.portuguese: "Escuro", .english: "Dark"],
        .language: [.portuguese: "Idioma", .english: "Language"],
        .replayTutorial: [.portuguese: "Rever tutorial", .english: "Replay tutorial"],
        .reduceMotion: [.portuguese: "Reduzir movimento", .english: "Reduce motion"],
        .hapticsLabel: [.portuguese: "Vibração", .english: "Haptics"],
        .aboutTitle: [.portuguese: "Sobre o jogo", .english: "About"],
        .aboutBody: [.portuguese: "Três Covas é uma recriação digital do tradicional jogo português do berlinde, jogado na terra com três covas em linha.", .english: "Three Pits is a digital recreation of the traditional Portuguese marble game, played on dirt ground with three pits in a line."],
        .close: [.portuguese: "Fechar", .english: "Close"],
        .score: [.portuguese: "Pontuação", .english: "Score"],
        .captured: [.portuguese: "Capturados", .english: "Captured"],
        .power: [.portuguese: "Força", .english: "Power"],
        .chooseTarget: [.portuguese: "Escolhe um alvo", .english: "Choose a target"],
        .confirmPalmo: [.portuguese: "Confirmar palmo", .english: "Confirm hand-span"],
        .palmoExplanation: [.portuguese: "O palmo permite aproximar o berlinde da cova antes de lançar novamente.", .english: "The hand-span lets you move the marble closer to the pit before launching again."],
        .objective: [.portuguese: "Objetivo", .english: "Objective"],
        .newRound: [.portuguese: "Nova ronda", .english: "New round"],
        .players: [.portuguese: "Jogadores", .english: "Players"],
        .addPlayer: [.portuguese: "Adicionar jogador", .english: "Add player"],
        .removePlayer: [.portuguese: "Remover jogador", .english: "Remove player"],
        .fieldTooSmallWarning: [.portuguese: "Roda o dispositivo para o modo horizontal.", .english: "Rotate your device to landscape mode."],
        .victoryTargetScore: [.portuguese: "Pontuação-alvo", .english: "Target score"],
        .victoryRounds: [.portuguese: "Número de rondas", .english: "Number of rounds"],
    ]
}
