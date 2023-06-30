import 'package:flutter/material.dart';

class PlaceWidget extends StatelessWidget {

    final String name;
    final int? tokens;
    final Size size;
    final double thickness;
    final double fontSize;
    final Color color;
    final Color backgroundColor;

    const PlaceWidget(
        this.name,
        this.size,
        {
            this.tokens,
            this.thickness = 5,
            this.fontSize = 30,
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
                painter: PlacePainter(
                    tokens: tokens,
                    name: name,
                    fontSize: fontSize,
                    thickness: thickness, 
                    color: color,
                    backgroundColor: backgroundColor
                ),
            )
        );
    }
}

class PlacePainter extends CustomPainter {
    final double fontSize;
    final double thickness;
    final Color color;
    final Color backgroundColor;
    final String name;
    final int? tokens;

    PlacePainter({
        required this.name,
        required this.thickness,
        required this.fontSize,
        required this.color,
        required this.backgroundColor,
        this.tokens
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
        
        canvas.drawCircle(Offset(size.width, size.height) / 2, size.shortestSide / 2, backpaint);
        canvas.drawCircle(Offset(size.width, size.height) / 2, size.shortestSide / 2, paint);

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

        var tokenspan = TextSpan(
            text: (tokens != null && tokens! > 0) ? "$tokens" : "",
            style: textstyle
        );
        var tokenpainter = TextPainter(
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            maxLines: 1,
            text: tokenspan
        );
        tokenpainter.layout(minWidth: size.width, maxWidth: size.width);
        tokenpainter.paint(canvas, Offset(0, size.height / 2 - fontSize / 2 - 4));
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) {
        return false;
    }
}