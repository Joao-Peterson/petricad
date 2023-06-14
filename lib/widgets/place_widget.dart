import 'package:flutter/material.dart';

class PlaceWidget extends StatelessWidget {

    final String name;
    final int init;

    const PlaceWidget(
        this.name,
        this.init,
        {Key? key}
    ) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return SizedBox(
            child: Column(
                children: [
                    Text(name, style: const TextStyle(fontSize: 30)),
                    const Padding(padding: EdgeInsets.all(10)),
                    Container(
                        width: 100, 
                        height: 100,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white,
                                width: 5
                            ),
                        ), 
                        child: Center(child: Text(init != 0 ? "${init}" : "", style: TextStyle(fontSize: 30),)),
                    ),
                ],
            ),
        );
    }
}