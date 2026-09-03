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
    case playerName
    case human
    case computer
    case aiDifficulty
    case difficultyEasy
    case difficultyNormal
    case difficultyHard
    case victoryModeLabel
    case victoryClassic
    case victoryPoints
    case courseLabel
    case courseOneWay
    case courseRoundTrip
    case courseRoundTripPapa
    case soundLabel
    case setupTitle
    case yourTurn
    case opponentTurn
    case aimAtFirstHole
    case aimAtHole
    case enteredHole
    case missedHole
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
    case aboutHistory
    case close
    case score
    case chooseTarget
    case targetSelectedPullToAttack
    case players
    case addPlayer
    case removePlayer
    case victoryTargetScore
    case playOnline
    case onlineWaitingForPlayers
    case onlineAuthenticationFailed
    case onlinePeerDisconnected
    case collectionTitle
    case collectionSkinsSection
    case collectionTerrainsSection
    case collectionAchievementsSection
    case collectionLockedWithWins
    case collectionSelected
    case collectionSelect
    case skinClassic
    case skinCatEye
    case skinOx
    case skinGrandMarble
    case achievementFirstWin
    case achievementFiveWins
    case achievementWinStreak
    case achievementFullCollection
    case terrainDirt
    case terrainSchoolyard
    case terrainBackyard
    case terrainPlaza
    case gameModeLabel
    case gameModeCovas
    case gameModeMound
    case gameModeChase
    case moundAim
    case moundShotInFlight
    case moundBurned
    case moundCaptured
    case moundMissed
    case chaseFleeAim
    case chaseChaseAim
    case chaseShotInFlight
    case chaseHit
    case chaseMissed
}

enum LocalizedStrings {
    static let table: [LocalizedKey: [AppLanguage: String]] = [
        .appName: [.portuguese: "iMarble", .english: "iMarble"],
        .tagline: [.portuguese: "O jogo tradicional do berlinde", .english: "The traditional marble game"],
        .play: [.portuguese: "Jogar", .english: "Play"],
        .rules: [.portuguese: "Regras", .english: "Rules"],
        .settings: [.portuguese: "Definições", .english: "Settings"],
        .about: [.portuguese: "Sobre o jogo", .english: "About"],
        .developedBy: [.portuguese: "Desenvolvido por David Arsénio Martins", .english: "Developed by David Arsénio Martins"],
        .startGame: [.portuguese: "Começar jogo", .english: "Start game"],
        .playerName: [.portuguese: "Nome do jogador", .english: "Player name"],
        .human: [.portuguese: "Humano", .english: "Human"],
        .computer: [.portuguese: "Computador", .english: "Computer"],
        .aiDifficulty: [.portuguese: "Dificuldade da IA", .english: "AI difficulty"],
        .difficultyEasy: [.portuguese: "Fácil", .english: "Easy"],
        .difficultyNormal: [.portuguese: "Normal", .english: "Normal"],
        .difficultyHard: [.portuguese: "Difícil", .english: "Hard"],
        .victoryModeLabel: [.portuguese: "Modo de vitória", .english: "Victory mode"],
        .victoryClassic: [.portuguese: "Clássico", .english: "Classic"],
        .victoryPoints: [.portuguese: "Pontos", .english: "Points"],
        .courseLabel: [.portuguese: "Percurso", .english: "Course"],
        .courseOneWay: [.portuguese: "Apenas ida", .english: "One way"],
        .courseRoundTrip: [.portuguese: "Ida e volta", .english: "Round trip"],
        .courseRoundTripPapa: [.portuguese: "Ida e volta com papa", .english: "Round trip with papa"],
        .soundLabel: [.portuguese: "Som", .english: "Sound"],
        .setupTitle: [.portuguese: "Configurar Partida", .english: "Game Setup"],
        .yourTurn: [.portuguese: "É a tua vez.", .english: "It's your turn."],
        .opponentTurn: [.portuguese: "Vez do adversário.", .english: "Opponent's turn."],
        .aimAtFirstHole: [.portuguese: "Aponta para a primeira cova.", .english: "Aim at the first hole."],
        .aimAtHole: [.portuguese: "Entra na cova %d", .english: "Enter hole %d"],
        .enteredHole: [.portuguese: "Entraste na cova!", .english: "You entered the hole!"],
        .missedHole: [.portuguese: "Falhaste a cova.", .english: "You missed the hole."],
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
        .tutorialStep3: [.portuguese: "Puxa o dedo para trás e larga para lançar o berlinde. Uma seta mostra a direção e muda de cor consoante a força.", .english: "Pull your finger back and release to launch the marble. An arrow shows the direction and changes color with the power."],
        .tutorialStep4: [.portuguese: "Sempre que entrares numa cova, jogas novamente.", .english: "Every time you enter a pit, you play again."],
        .tutorialStep5: [.portuguese: "Quem completar o percurso primeiro, ganha o jogo.", .english: "Whoever completes the course first wins the game."],
        .tutorialStep6: [.portuguese: "No modo por pontos, também podes atacar berlindes adversários depois de completares o percurso, disparando a partir de uma cova.", .english: "In points mode, you can also attack opponents' marbles after completing the course, launching from a pit."],
        .tutorialSkip: [.portuguese: "Saltar", .english: "Skip"],
        .tutorialNext: [.portuguese: "Seguinte", .english: "Next"],
        .tutorialStart: [.portuguese: "Começar", .english: "Start"],
        .rulesTitle: [.portuguese: "Regras do Jogo", .english: "Game Rules"],
        .rulesBody: [
            .portuguese: "O campo tem três covas em linha: a Pira (Cova 1), a Meia (Cova 2) e o Fundo (Cova 3). Cada jogador faz o percurso Pira → Meia → Fundo e depois de volta Fundo → Meia → Pira. Sempre que entra numa cova com sucesso, joga novamente. No modo clássico, vence quem completar todo o percurso primeiro. No modo por pontos, depois de completar o percurso um jogador pode ainda \"matar\": atacar berlindes adversários, disparando sempre a partir de uma cova — acertar confisca o berlinde do adversário para sempre. Pontuação: 2 pontos por cova alcançada, 2 pontos por acertar num adversário e 3 pontos por confiscar um berlinde; vence quem atingir primeiro a pontuação-alvo.\n\nNo modo Monte do Tesouro, os berlindes de todos os jogadores começam num monte dentro de um círculo; à vez, cada jogador lança um berlinde maior a partir de fora, tentando expulsar berlindes do círculo — quem os expulsa, fica com eles. Se o teu berlinde ficar dentro do círculo, \"queimas-te\" e perdes o turno seguinte. Vence quem tiver mais berlindes capturados quando o monte esvaziar.\n\nNo modo Perseguição (2 jogadores), um foge lançando o seu berlinde para a frente; o outro tenta acertar-lhe. Se acertar, ganha um ponto; se falhar, passa a ser ele o perseguido na jogada seguinte. Vence quem atingir primeiro a pontuação-alvo.",
            .english: "The field has three pits in a line: the Pira (Pit 1), the Meia (Pit 2) and the Fundo (Pit 3). Each player runs the course Pira → Meia → Fundo and then back Fundo → Meia → Pira. Every successful hole entry earns another turn. In classic mode, whoever completes the full course first wins. In points mode, after completing the course a player can still \"matar\" — attack opponents' marbles, always launching from a pit — a hit permanently confiscates the opponent's marble. Scoring: 2 points per pit reached, 2 points per hit on an opponent, and 3 points per marble confiscated; the winner is whoever reaches the target score first.\n\nIn Treasure Mound mode, every player's marbles start in a pile inside a circle; in turn, each player launches a larger shooter marble from outside, trying to knock marbles out of the circle — whoever knocks one out keeps it. If your own marble stays inside the circle, you \"burn\" and lose your next turn. Whoever has captured the most marbles once the pile is empty wins.\n\nIn Chase mode (2 players), one player flees by launching their marble forward; the other tries to hit it. A hit scores a point; a miss makes you the one being chased next round. The winner is whoever reaches the target score first.",
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
        .aboutBody: [.portuguese: "iMarble é uma recriação digital do tradicional jogo português do berlinde, jogado na terra com três covas em linha.", .english: "iMarble is a digital recreation of the traditional Portuguese marble game, played on dirt ground with three pits in a line."],
        .aboutHistory: [
            .portuguese: "O berlinde foi, durante gerações, um dos passatempos mais populares nas ruas, pátios de escola e quintais de Portugal — muito antes das consolas e dos telemóveis. Com uma pequena bola de vidro e três covas cavadas na terra, bastava um recreio para se organizar um torneio. Este jogo guarda essa memória: o som seco do berlinde a entrar na cova, a tensão de calcular a força certa, a alegria de completar o percurso primeiro.",
            .english: "For generations, marbles were one of the most popular pastimes in the streets, schoolyards and backyards of Portugal — long before consoles and phones. With a small glass ball and three pits dug into the ground, a single break was enough to start a tournament. This game keeps that memory alive: the sharp sound of the marble dropping into the pit, the tension of judging the right force, the joy of finishing the course first.",
        ],
        .close: [.portuguese: "Fechar", .english: "Close"],
        .score: [.portuguese: "Pontuação", .english: "Score"],
        .chooseTarget: [.portuguese: "Percurso completo! Toca num berlinde adversário para o escolheres como alvo.", .english: "Course complete! Tap an opponent's marble to choose it as your target."],
        .targetSelectedPullToAttack: [.portuguese: "Alvo escolhido. Puxa o TEU berlinde para trás e larga para atacares.", .english: "Target chosen. Pull back YOUR marble and release to attack."],
        .players: [.portuguese: "Jogadores", .english: "Players"],
        .addPlayer: [.portuguese: "Adicionar jogador", .english: "Add player"],
        .removePlayer: [.portuguese: "Remover jogador", .english: "Remove player"],
        .victoryTargetScore: [.portuguese: "Pontuação-alvo", .english: "Target score"],
        .playOnline: [.portuguese: "Jogar online", .english: "Play online"],
        .onlineWaitingForPlayers: [.portuguese: "À espera dos jogadores…", .english: "Waiting for players…"],
        .onlineAuthenticationFailed: [.portuguese: "Não foi possível autenticar no Game Center.", .english: "Could not authenticate with Game Center."],
        .onlinePeerDisconnected: [.portuguese: "Um jogador desligou-se. Partida em pausa.", .english: "A player disconnected. Match paused."],
        .collectionTitle: [.portuguese: "Coleção", .english: "Collection"],
        .collectionSkinsSection: [.portuguese: "Berlindes", .english: "Marbles"],
        .collectionTerrainsSection: [.portuguese: "Terrenos", .english: "Terrains"],
        .collectionAchievementsSection: [.portuguese: "Conquistas", .english: "Achievements"],
        .collectionLockedWithWins: [.portuguese: "Desbloqueia com %d vitórias", .english: "Unlocks at %d wins"],
        .collectionSelected: [.portuguese: "Selecionado", .english: "Selected"],
        .collectionSelect: [.portuguese: "Selecionar", .english: "Select"],
        .skinClassic: [.portuguese: "Clássico", .english: "Classic"],
        .skinCatEye: [.portuguese: "Olho de gato", .english: "Cat's eye"],
        .skinOx: [.portuguese: "Boi", .english: "Ox"],
        .skinGrandMarble: [.portuguese: "Berlindão", .english: "Grand marble"],
        .achievementFirstWin: [.portuguese: "Primeira Vitória", .english: "First Victory"],
        .achievementFiveWins: [.portuguese: "5 Vitórias", .english: "5 Victories"],
        .achievementWinStreak: [.portuguese: "10 Vitórias Seguidas", .english: "10 Wins in a Row"],
        .achievementFullCollection: [.portuguese: "Coleção Completa", .english: "Full Collection"],
        .terrainDirt: [.portuguese: "Terra batida", .english: "Dirt ground"],
        .terrainSchoolyard: [.portuguese: "Pátio de escola", .english: "Schoolyard"],
        .terrainBackyard: [.portuguese: "Quintal", .english: "Backyard"],
        .terrainPlaza: [.portuguese: "Praça de aldeia", .english: "Village square"],
        .gameModeLabel: [.portuguese: "Modo de jogo", .english: "Game mode"],
        .gameModeCovas: [.portuguese: "Três covas", .english: "Three pits"],
        .gameModeMound: [.portuguese: "Monte do Tesouro", .english: "Treasure Mound"],
        .moundAim: [.portuguese: "Lança o teu boi para expulsar berlindes do círculo.", .english: "Launch your shooter to knock marbles out of the circle."],
        .moundShotInFlight: [.portuguese: "A resolver o lançamento…", .english: "Resolving the shot…"],
        .moundBurned: [.portuguese: "Queimaste-te! O teu berlinde ficou dentro do círculo.", .english: "You burned! Your shooter stayed inside the circle."],
        .moundCaptured: [.portuguese: "Expulsaste berlindes do círculo!", .english: "You knocked marbles out of the circle!"],
        .moundMissed: [.portuguese: "Não expulsaste nenhum berlinde.", .english: "You didn't knock any marbles out."],
        .gameModeChase: [.portuguese: "Perseguição", .english: "Chase"],
        .chaseFleeAim: [.portuguese: "Lança o teu berlinde para fugir.", .english: "Launch your marble to flee."],
        .chaseChaseAim: [.portuguese: "Persegue e acerta no berlinde adversário.", .english: "Chase and hit the opponent's marble."],
        .chaseShotInFlight: [.portuguese: "A resolver o lançamento…", .english: "Resolving the shot…"],
        .chaseHit: [.portuguese: "Acertaste! Ganhas um ponto.", .english: "You hit it! You score a point."],
        .chaseMissed: [.portuguese: "Falhaste — agora és perseguido.", .english: "You missed — now you're the one being chased."],
    ]
}
