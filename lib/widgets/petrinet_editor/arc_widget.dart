import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:petricad/widgets/petrinet_editor/petrinet.dart';

class ArcWidget extends StatelessWidget {

    final PetrinetArcType type;
    final Offset from, to;
    final List<Offset>? vertices;
    final double thickness;
    final Color color;
    final Color backgroundColor;
    final double offset;
    final double minOffset;
    final double hitTestRadius;
    final bool debug;
    
    const ArcWidget(
        {
            required this.type,
            required this.from,
            required this.to,
            this.vertices,
            this.offset = 25,
            this.minOffset = 25,
            this.color = Colors.white,
            this.backgroundColor = Colors.black,
            this.thickness = 2.0,
            this.hitTestRadius = 10,
            this.debug = true,
            Key? key
        }
    ) : super(key: key);

    @override
    Widget build(BuildContext context) {
        final ArcPainter painter;

        final Offset vectorFirst;
        final Offset vectorLast;
        if(vertices != null && vertices!.isNotEmpty){                               // get first and last arc vectors
            vectorFirst = vertices!.first - from;
            vectorLast = to - vertices!.last;
        }
        else{
            vectorFirst = to - from;
            vectorLast = vectorFirst;
        }

        double arcOffset = offset;                                                  // reduce offset when nodes get too close to the arc ends 
        if(vertices == null){
            if(vectorFirst.distance < offset){
                arcOffset = minOffset;
            }
            else if(vectorFirst.distance < offset * 4){
                final a = (offset - minOffset)/(3 * offset);
                final b = minOffset - a * offset;
                arcOffset = a * vectorFirst.distance + b;
            }
        }

        final arcFrom = from + Offset.fromDirection(vectorFirst.direction, arcOffset); // get from and to points adjusted for the offset
        final arcTo = to - Offset.fromDirection(vectorLast.direction, arcOffset);

        final arcVertices = (vertices != null) ? [arcFrom, ...vertices!, arcTo] : [arcFrom, arcTo];

        switch(type){
            case PetrinetArcType.weighted:
                painter = WeightedArcPainter(
                    vertices: arcVertices,                    
                    color: color,
                    backgroundColor: backgroundColor,
                    thickness: thickness
                );
            break;

            case PetrinetArcType.negated:
                painter = NegatedArcPainter(
                    vertices: arcVertices,                    
                    color: color,
                    backgroundColor: backgroundColor,
                    thickness: thickness
                );
            break;

            case PetrinetArcType.reset:
                painter = ResetArcPainter(
                    vertices: arcVertices,                    
                    color: color,
                    backgroundColor: backgroundColor,
                    thickness: thickness
                );
            break;
        }

        return SizedBox(
            child: Builder(
                builder: (context) {

                    Widget hitbox = Container(
                        decoration: ShapeDecoration(
                            shape: CircleBorder(
                                side: debug ? 
                                    const BorderSide(
                                        color: Colors.pinkAccent,
                                        width: 5
                                    )
                                    :
                                    const BorderSide()

                            )
                        ), 
                        height: hitTestRadius * 2, 
                        width: hitTestRadius * 2
                    );
                    
                    final children = [
                        Positioned(                                                     // arc drawings
                            top: 0,
                            left: 0,
                            child: CustomPaint(
                                painter: painter
                            ),
                        ),
                        Positioned(                                                     // first hit point
                            top: arcFrom.dy - hitTestRadius,
                            left: arcFrom.dx - hitTestRadius,
                            child: hitbox
                        ),
                        Positioned(                                                     // last hitpoint
                            top: arcTo.dy - hitTestRadius,
                            left: arcTo.dx - hitTestRadius,
                            child: hitbox
                        )
                    ];
                    
                    return Stack(children: children);
                }
            ),
        );
    }
}

abstract class ArcPainter extends CustomPainter {
    final List<Offset> vertices;
    final double thickness;
    final Color color;
    final Color backgroundColor;

    ArcPainter({
        required this.vertices,
        required this.thickness,
        required this.color,
        required this.backgroundColor,
    });
}

class WeightedArcPainter extends ArcPainter {

    WeightedArcPainter({
        required vertices,
        required thickness,
        required color,
        required backgroundColor,
    }) : super(vertices: vertices, thickness: thickness, color: color, backgroundColor: backgroundColor);

    @override
    void paint(Canvas canvas, Size size) {
        if(vertices.length < 2){
            return;
        }

        final paint = Paint()
        ..color = color
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

        final fillpaint = Paint()
        ..color = color
        ..strokeWidth = 0
        ..style = PaintingStyle.fill;

        final path = Path();
        
        // arc path
        path.moveTo(vertices[0].dx, vertices[0].dy);
        for(int i = 1; i < vertices.length; i++){
            path.lineTo(vertices[i].dx, vertices[i].dy);
        }
        canvas.drawPath(path, paint);

        // arrow, 30 degrees (pi/6) for a equilateral triangle
        final delta = vertices[vertices.length - 1] - vertices[vertices.length - 2];
        final arrowSize = thickness * 7;

        final arrowOffset = Offset.fromDirection(delta.direction, arrowSize / 2);

        path.relativeMoveTo(arrowOffset.dx, arrowOffset.dy);
        var p = Offset.fromDirection(delta.direction - math.pi * 5/6, arrowSize);
        path.relativeLineTo(p.dx, p.dy);
        p = Offset.fromDirection(delta.direction + math.pi / 2, arrowSize);
        path.relativeLineTo(p.dx, p.dy);
        p = Offset.fromDirection(delta.direction - math.pi / 6, arrowSize);
        path.relativeLineTo(p.dx, p.dy);

        canvas.drawPath(path, fillpaint);
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) {
        return false;
    }
}

class ResetArcPainter extends ArcPainter {

    ResetArcPainter({
        required vertices,
        required thickness,
        required color,
        required backgroundColor,
    }) : super(vertices: vertices, thickness: thickness, color: color, backgroundColor: backgroundColor);

    @override
    void paint(Canvas canvas, Size size) {
        if(vertices.length < 2){
            return;
        }

        final paint = Paint()
        ..color = color
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

        final backpaint = Paint()
        ..color = backgroundColor
        ..strokeWidth = 0
        ..style = PaintingStyle.fill;

        final path = Path();

        // arc path
        path.moveTo(vertices[0].dx, vertices[0].dy);
        for(int i = 1; i < vertices.length; i++){
            path.lineTo(vertices[i].dx, vertices[i].dy);
        }
        canvas.drawPath(path, paint);
        final radius = thickness * 5;

        // end square
        canvas.drawRect(Rect.fromCenter(center: vertices.first, width: radius, height: radius), paint);
        canvas.drawRect(Rect.fromCenter(center: vertices.first, width: radius, height: radius), backpaint);
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) {
        return false;
    }
}

class NegatedArcPainter extends ArcPainter {

    NegatedArcPainter({
        required vertices,
        required thickness,
        required color,
        required backgroundColor,
    }) : super(vertices: vertices, thickness: thickness, color: color, backgroundColor: backgroundColor);

    @override
    void paint(Canvas canvas, Size size) {
        if(vertices.length < 2){
            return;
        }

        final paint = Paint()
        ..color = color
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

        final backpaint = Paint()
        ..color = backgroundColor
        ..strokeWidth = 0
        ..style = PaintingStyle.fill;

        final path = Path();

        // arc path
        path.moveTo(vertices[0].dx, vertices[0].dy);
        for(int i = 1; i < vertices.length; i++){
            path.lineTo(vertices[i].dx, vertices[i].dy);
        }
        canvas.drawPath(path, paint);

        final radius = thickness * 7/2;

        // endball
        canvas.drawCircle(vertices.last, radius, paint);
        canvas.drawCircle(vertices.last, radius, backpaint);
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) {
        return false;
    }
}