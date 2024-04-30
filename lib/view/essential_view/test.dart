import 'package:flutter/material.dart';

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  int countOne = 1;
  int countTwo = 2;

  int countThree = 3;

  int countFour = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            Builder(
              builder: (context) {
                print('rebuild 1');
                return Expanded(
                  child: Card(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            '$countOne',
                            // style: context.textTheme.displayMedium,
                          ),
                          FloatingActionButton(
                            onPressed: () {
                              setState(() {
                                countOne++;
                              });
                            },
                            child: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const RebuildTwo(),
            const Rebuild3(),
            const Rebuild4(),
          ],
        ),
      ),
    );
  }
}

class Rebuild3 extends StatelessWidget {
  const Rebuild3({super.key});
  final int countFive = 5;
  @override
  Widget build(BuildContext context) {
    print('rebuild 3');
    return Expanded(
      child: Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                '$countFive',
                // style: context.textTheme.displayMedium,
              ),
              FloatingActionButton(
                onPressed: () {},
                child: const Icon(
                  Icons.add,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RebuildTwo extends StatelessWidget {
  const RebuildTwo({super.key});

  @override
  Widget build(BuildContext context) {
    print('rebuild 2');
    return Expanded(
      child: Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                '2',
                // style: context.textTheme.displayMedium,
              ),
              FloatingActionButton(
                onPressed: () {
                  // countTwo++;
                },
                child: const Icon(
                  Icons.add,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Rebuild4 extends StatelessWidget {
  const Rebuild4({super.key});
  final int countFive = 5;
  @override
  Widget build(BuildContext context) {
    print('rebuild 4');
    return Expanded(
      child: Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                '$countFive',
                // style: context.textTheme.displayMedium,
              ),
              FloatingActionButton(
                onPressed: () {},
                child: const Icon(
                  Icons.add,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
