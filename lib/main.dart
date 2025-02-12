import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

enum Ability {
  culture,
  trade,
  technology,
  industry,
  harvesting,
  military,
  defense,
  other,
}

class Player {
  Map<Ability, int> abilities = {
    Ability.culture: 0,
    Ability.trade: 0,
    Ability.technology: 0,
    Ability.industry: 0,
    Ability.harvesting: 0,
    Ability.military: 0,
    Ability.defense: 0,
    Ability.other: 0,
  };
  Map<Ability, IconData> icons = {
    Ability.culture: Icons.account_balance,
    Ability.trade: Icons.currency_exchange,
    Ability.technology: Icons.lightbulb,
    Ability.industry: Icons.build,
    Ability.harvesting: Icons.grass,
    Ability.military: Icons.handyman,
    Ability.defense: Icons.fort,
    Ability.other: Icons.terrain,
  };
  Color color = Colors.deepOrange.shade700;
  Player(this.color);
  void incrementAbility(Ability ability) {
    abilities[ability] = (abilities[ability] ?? 0) + 1;
  }
  void decrementAbility(Ability ability) {
    abilities[ability] = (abilities[ability] ?? 0) - 1;
  }
  int totalScore() {
    int culture = abilities[Ability.culture] ?? 0;
    int other = abilities[Ability.other] ?? 0;
    return (abilities.values.reduce((a, b) => a + b) - culture - other) ~/ 2 + culture + other;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: '歴史悠久',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  List<Player> players = [
    Player(Colors.orange.shade600),
    Player(Colors.blue.shade400),
    Player(Colors.green.shade400),
    Player(Colors.red.shade400),
    Player(Colors.yellow.shade700),
  ];
  void incrementAbility(int i, Ability ability) {
    players[i].incrementAbility(ability);
    notifyListeners();
  }

  void decrementAbility(int i, Ability ability) {
    players[i].decrementAbility(ability);
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    final height = (deviceHeight - 8 * 9 - 32) / 9.5;
    final width = (deviceWidth - 24 * 6) / 5;

    var appState = context.watch<MyAppState>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Wrap(
          direction: Axis.horizontal,
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            for (int i = 0; i < appState.players.length; i++) ...{
              Wrap(
                direction: Axis.vertical,
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  ScorePanel(
                    score: appState.players[i].totalScore(),
                    icon: Icons.emoji_events,
                    color: appState.players[i].color,
                    onTapLeft: () {},
                    onTapRight: () {},
                    width: width,
                    height: height * 1.5,
                  ),
                  for (Ability ability in Ability.values) ...{
                    ScorePanel(
                      score: appState.players[i].abilities[ability] ?? 0,
                      icon: appState.players[i].icons[ability]!,
                      color: appState.players[i].color,
                      onTapLeft: () => appState.decrementAbility(i, ability),
                      onTapRight: () => appState.incrementAbility(i, ability),
                      width: width,
                      height: height,
                    ),
                  }
                ],
              ),
            }
          ],
        ),
      ),
    );
  }
}

enum Direction { left, right}

class ScoreButton extends StatefulWidget {
  const ScoreButton({
    super.key,
    required this.width,
    required this.height,
    required this.onTap,
    required this.direction,
  });

  final double width;
  final double height;
  final VoidCallback onTap;
  final Direction direction;

  @override
  State<ScoreButton> createState() => _ScoreButtonState();
}

class _ScoreButtonState extends State<ScoreButton> {
  double _opacity = 0.0;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onTapDown: (_) {
        setState(() {
          _opacity = 0.4;
        });
      },
      onTapUp: (_) {
        setState(() {
          _opacity = 0.0;
        });
      },
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 10),
        opacity: _opacity,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: widget.direction == Direction.left ?
              BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ) :
              BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              )
          ),
        ),
      ),
    );
  }
}

class ScorePanel extends StatelessWidget {
  const ScorePanel({
    super.key,
    required this.score,
    required this.icon,
    required this.color,
    required this.onTapLeft,
    required this.onTapRight,
    required this.width,
    required this.height,
  });

  final int score;
  final IconData icon;
  final Color color;
  final VoidCallback onTapLeft;
  final VoidCallback onTapRight;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayLarge!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Stack(alignment: Alignment.center, children: [
      Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              score.toString(),
              style: style,
            ),
          )),
      Positioned(
        top: 10,
        left: 10,
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
      Positioned(
        left: 0,
        child: ScoreButton(
          width: width / 2,
          height: height,
          onTap: onTapLeft,
          direction: Direction.left,
        ),
      ),
      Positioned(
        right: 0,
        child: ScoreButton(
          width: width / 2,
          height: height,
          onTap: onTapRight,
          direction: Direction.right,
        ),
      ),
    ]);
  }
}
