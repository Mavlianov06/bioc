import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class RocketEvent {}
class StartIncrement extends RocketEvent {}
class StopIncrement extends RocketEvent {}
class StartDecrement extends RocketEvent {}
class UpdateState extends RocketEvent {
  final int result;
  final double rocketSpeed;
  final double rocketPosition;
  UpdateState({required this.result, required this.rocketSpeed, required this.rocketPosition});
}

// State
class RocketState {
  final int result;
  final double rocketSpeed;
  final double rocketPosition;

  RocketState({
    required this.result,
    required this.rocketSpeed,
    required this.rocketPosition,
  });

  factory RocketState.initial() {
    return RocketState(result: 0, rocketSpeed: 1.0, rocketPosition: 0.0);
  }
}

// Bloc
class RocketBloc extends Bloc<RocketEvent, RocketState> {
  Timer? holdTimer;
  Timer? decrementTimer;

  RocketBloc() : super(RocketState.initial()) {
    on<StartIncrement>((event, emit) {
      holdTimer?.cancel();
      holdTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        int newResult = state.result + 1;
        double newSpeed = 1 + newResult / 100;
        double newPosition = state.rocketPosition - 5;
        emit(RocketState(result: newResult, rocketSpeed: newSpeed, rocketPosition: newPosition));
      });
    });

    on<StopIncrement>((event, emit) {
      holdTimer?.cancel();
      add(StartDecrement());
    });

    on<StartDecrement>((event, emit) {
      decrementTimer?.cancel();
      decrementTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        int newResult = state.result > 1000 ? state.result - 1000 : 0;
        double newSpeed = 1 + newResult / 100;
        emit(RocketState(result: newResult, rocketSpeed: newSpeed, rocketPosition: 0));
      });
    });
  }

  @override
  Future<void> close() {
    holdTimer?.cancel();
    decrementTimer?.cancel();
    return super.close();
  }
}

// UI
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RocketBloc(),
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BlocBuilder<RocketBloc, RocketState>(
                  builder: (context, state) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 100),
                          transform: Matrix4.translationValues(0, state.rocketPosition, 0),
                          child: const Icon(
                            Icons.rocket_launch,
                            size: 50,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                BlocBuilder<RocketBloc, RocketState>(
                  builder: (context, state) {
                    return Text(
                      '${state.result}',
                      style: const TextStyle(fontSize: 30),
                    );
                  },
                ),
                GestureDetector(
                  onLongPress: () => context.read<RocketBloc>().add(StartIncrement()),
                  onLongPressUp: () => context.read<RocketBloc>().add(StopIncrement()),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () => context.read<RocketBloc>().add(StartIncrement()),
                    child: const Text(
                      '+',
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
