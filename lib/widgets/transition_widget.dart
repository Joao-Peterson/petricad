import 'package:flutter/material.dart';

class TransitionWidget extends StatelessWidget {

    final String name;
    final String inputEvt;
    final int delay;
    final Size size;

    const TransitionWidget(
        this.name,
        this.inputEvt,
        this.delay,
        this.size,
        {Key? key}
    ) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return SizedBox(
            child: Column(
                children: [
                    Text(name, style: const TextStyle(fontSize: 30)),
                    const Padding(padding: EdgeInsets.all(10)),
                    SizedBox(
                        width: size.width, 
                        height: size.height,
                        child: const VerticalDivider(
                            color: Colors.white,
                            thickness: 20,
                        ),
                    ),
                    const Padding(padding: EdgeInsets.all(10)),
                    Center(child: Text(inputEvt, style: TextStyle(fontSize: 30))),
                    const Padding(padding: EdgeInsets.all(10)),
                    Center(child: Text(delay != 0 ? "$delay ms" : "", style: TextStyle(fontSize: 30))),
                ],
            ),
        );
    }
}