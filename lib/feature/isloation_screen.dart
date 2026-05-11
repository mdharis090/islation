
// import 'dart:async';
// import 'package:flutter/material.dart';

// class TweenAnimationScreen extends StatefulWidget {
//   const TweenAnimationScreen({super.key});

//   @override
//   State<TweenAnimationScreen> createState() => _TweenAnimationScreenState();
// }

// class _TweenAnimationScreenState extends State<TweenAnimationScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//   late Timer timer;

//   double currentSize = 50;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 1),
//     );

//     _animation = Tween<double>(begin: 50, end: 400).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     )
//       ..addListener(() {
//         setState(() {
//           currentSize = _animation.value;
//         });
//       });

//     //  Auto animation using Timer
//     timer = Timer.periodic(const Duration(seconds: 2), (timer) {
//       if (_controller.isCompleted) {
//         _controller.reverse();
//       } else {
//         _controller.forward();
//       }
//     });
//   }

//   //  Heavy loop (freeze UI)
//   void heavyLoop() {
//     int sum = 0;
//     for (int i = 0; i < 1000000000; i++) {
//       sum += i;
//     }
//     print("Done: $sum");
//   }

//   @override
//   void dispose() {
//     timer.cancel();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Auto Tween Freeze UI ")),

//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Center(
//           child: Container(
//             height: currentSize,
//             width: currentSize,
//             decoration: BoxDecoration(
//               color: Colors.blue,
//               borderRadius: BorderRadius.circular(20),
//             ),
//           ),
//         ),
//       ),

//       // 🟢 FAB → trigger heavy loop (freeze)
//       floatingActionButton: FloatingActionButton(
//         onPressed: heavyLoop,
//         child: Text('Get'),
//      //   child: const Icon(Icons.warning),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';

class TweenAnimationScreen extends StatefulWidget {
  const TweenAnimationScreen({super.key});

  @override
  State<TweenAnimationScreen> createState() => _TweenAnimationScreenState();
}

class _TweenAnimationScreenState extends State<TweenAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Timer timer;

  double currentSize = 50;
  String result = "No result yet";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 50, end: 400).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
        setState(() {
          currentSize = _animation.value;
        });
      });

    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_controller.isCompleted) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    });
  }

  //  ISOLATE ENTRY POINT (must be static or top-level)
  static void heavyLoopIsolate(SendPort sendPort) {
    int sum = 0;

    for (int i = 0; i < 1000000000; i++) {
      sum += i;
    }

    sendPort.send("Done: $sum");
  }

  //  RUN ISOLATE
  Future<void> runHeavyTask() async {
    ReceivePort receivePort = ReceivePort();

    await Isolate.spawn(heavyLoopIsolate, receivePort.sendPort);

    receivePort.listen((message) {
      setState(() {
        result = message.toString();
      });

      receivePort.close();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Isolate Animation Demo")),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                height: currentSize,
                width: currentSize,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          Text(
            result,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),

      //  Now runs in isolate (no freeze)
      floatingActionButton: FloatingActionButton(
        onPressed: runHeavyTask,
        child: Text('Get')
      ),
    );
  }
}