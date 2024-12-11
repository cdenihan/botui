import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stpvelox/presentation/blocs/program_bloc.dart';
import 'package:stpvelox/presentation/widgets/top_bar.dart';

class ProgramScreen extends StatefulWidget {
  const ProgramScreen({super.key});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  String _programArg = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(title: "Program"),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.grey[850],
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Colors.white,
                              decoration: const InputDecoration(
                                labelText: "Argument",
                                labelStyle: TextStyle(color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white70),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _programArg = val;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<ProgramBloc>()
                                  .add(StartProgramEvent(arg: _programArg));
                            },
                            child: const Text("Start"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: BlocBuilder<ProgramBloc, ProgramState>(
                        builder: (context, state) {
                          if (state is ProgramInitial) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: Text(
                                  "Program not started.",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                              ),
                            );
                          } else if (state is ProgramLoading) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (state is ProgramLoaded) {
                            return Container(
                              color: Colors.grey[800],
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SingleChildScrollView(
                                  child: RichText(
                                    text: TextSpan(
                                      children: state.output
                                          .map(
                                            (line) => TextSpan(
                                              text: "$line\n",
                                              style: TextStyle(
                                                color: _getColorForLine(line),
                                                fontSize: 18,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else if (state is ProgramError) {
                            return Container(
                              color: Colors.grey[800],
                              child: Center(
                                child: Text(
                                  state.message,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 18),
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForLine(String line) {
    if (line.contains("Error")) return Colors.red;
    if (line.contains("Loading")) return Colors.yellow;
    if (line.contains("started")) return Colors.green;
    return Colors.white;
  }
}
