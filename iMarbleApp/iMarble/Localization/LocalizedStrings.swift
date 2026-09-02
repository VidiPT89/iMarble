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
    case youHavePalmo
    case marbleProtected
    case canAttackNow
    case hitMarble
    case keptMarble
    case gameOver
    case winnerIs
    case quickRules
    case pause
    case undo
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
        .youHavePalmo: [.portuguese: "Tens direito a um palmo.", .english: "You have a hand-span available."],
        .marbleProtected: [.portuguese: "Berlinde protegido.", .english: "Marble protected."],
        .canAttackNow: [.portuguese: "Agora podes atacar um adversário.", .english: "You may now attack an opponent."],
        .hitMarble: [.portuguese: "Acertaste no berlinde!", .english: "You hit the marble!"],
        .keptMarble: [.portuguese: "Ficaste com o berlinde.", .english: "You kept the marble."],
        .gameOver: [.portuguese: "Fim do jogo.", .english: "Game over."],
        .winnerIs: [.portuguese: "O vencedor é %@", .english: "The winner is %@"],
        .quickRules: [.portuguese: "Regras rápidas", .english: "Quick rules"],
        .pause: [.portuguese: "Pausa", .english: "Pause"],
        .undo: [.portuguese: "Desfazer", .english: "Undo"],
        .resume: [.portuguese: "Continuar", .english: "Resume"],
        .restart: [.portuguese: "Reiniciar", .english: "Restart"],
        .mainMenu: [.portuguese: "Menu principal", .english: "Main menu"],
        .tutorialTitle: [.portuguese: "Como jogar", .english: "How to play"],
        .tutorialStep1: [.portuguese: "Estas são as três covas.", .english: "These are the three pits."],
        .tutorialStep2: [.portuguese: "O objetivo é fazer o percurso pela ordem indicada.", .english: "The goal is to complete the course in order."],
        .tutorialStep3: [.portuguese: "Puxa o dedo para trás e larga para lançar o berlinde.", .english: "Pull your finger back and release to launch the marble."],
        .tutorialStep4: [.portuguese: "Se acertares numa cova, continuas a jogar.", .english: "If you hit a pit, you keep playing."],
        .tutorialStep5: [.portuguese: "Depois de completares o percurso, podes atacar os berlindes adversários.", .english: "After completing the course, you can attack opponents' marbles."],
        .tutorialStep6: [.portuguese: "Usa o palmo quando estiver disponível para te aproximares.", .english: "Use the hand-span when available to get closer."],
        .tutorialSkip: [.portuguese: "Saltar", .english: "Skip"],
        .tutorialNext: [.portuguese: "Seguinte", .english: "Next"],
        .tutorialStart: [.portuguese: "Começar", .english: "Start"],
        .rulesTitle: [.portuguese: "Regras do Jogo", .english: "Game Rules"],
        .rulesBody: [.portuguese: "O campo tem três covas em linha. Cada jogador lança o seu berlinde tentando entrar nas covas pela ordem definida. Ao completar o percurso, pode atacar os berlindes adversários. Vence quem permanecer em jogo ou quem atingir a pontuação-alvo.", .english: "The field has three pits in a line. Each player launches their marble trying to enter the pits in the defined order. After completing the course, they may attack opponents' marbles. The winner is whoever remains in play or reaches the target score."],
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
