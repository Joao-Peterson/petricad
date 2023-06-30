import 'package:flutter/material.dart';

class TransitionWidget extends StatelessWidget {

    final String name;
    final int? delay;
    final String? inputEvt;
    final Size size;
    final double thickness;
    final double fontSize;
    final Color color;
    final Color backgroundColor;

    const TransitionWidget(
        this.name,
        this.size,
        {
            this.inputEvt,
            this.delay,
            this.fontSize = 30,
            this.thickness = 5,
            this.color = Colors.white,
            this.backgroundColor = Colors.black,
            Key? key
        }
    ) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return SizedBox(
            height: size.height,
            width: size.width,
            child: 
            CustomPaint(
                painter: TransitionPainter(
                    name: name,
                    delay: delay,
                    inputEvt: inputEvt,
                    fontSize: fontSize,
                    thickness: thickness, 
                    color: color,
                    backgroundColor: backgroundColor,
                ),
            )
        );
    }
}

class TransitionPainter extends CustomPainter {
    final double fontSize;
    final double thickness;
    final Color color;
    final Color backgroundColor;
    final String name;
    final String? inputEvt;
    final int? delay;

    TransitionPainter({
        required this.name,
        required this.thickness,
        required this.fontSize,
        required this.color,
        required this.backgroundColor,
        this.inputEvt,
        this.delay,
    });

    @override
    void paint(Canvas canvas, Size size) {
        final paint = Paint()
        ..color = color
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

        final backpaint = Paint()
        ..color = backgroundColor
        ..strokeWidth = 0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.fill;
        
        var trace = Rect.fromCenter(
            center: Offset(size.width, size.height) / 2, 
            width: size.shortestSide / 5, 
            height: size.shortestSide
        ); 

        canvas.drawRect(trace, paint);
        canvas.drawRect(trace, backpaint);

        var textstyle = TextStyle(
            fontSize: fontSize,
            color: color
        );

        var namespan = TextSpan(
            text: name,
            style: textstyle
        );

        var namepainter = TextPainter(
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            maxLines: 1,
            text: namespan
        );
        namepainter.layout(minWidth: size.width, maxWidth: size.width);
        namepainter.paint(canvas, Offset.zero);

        var instring = inputEvt ?? "";
        var delaystring = (delay != null && delay != 0) ? '$delay ms' : '';

        var infospan = TextSpan(
            text: "$instring\n$delaystring",
            style: textstyle
        );
        var infopainter = TextPainter(
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            text: infospan
        );
        infopainter.layout(minWidth: size.width, maxWidth: size.width * 2);
        infopainter.paint(canvas, Offset(0, size.height / 2 + size.shortestSide / 2 + 4));
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) {
        return false;
    }
}