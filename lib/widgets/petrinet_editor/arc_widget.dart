import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:petricad/widgets/petrinet_editor/petrinet.dart';

class ArcWidget extends StatelessWidget {

    final PetrinetArcType type;
    final Offset from, to;
    final double thickness;
    final Color color;
    final Color backgroundColor;
    final double offset;
    
    const ArcWidget(
        {
            required this.type,
            required this.from,
            required this.to,
            this.offset = 0,
            this.color = Colors.white,
            this.backgroundColor = Colors.black,
            this.thickness = 2.0,
            Key? key
        }
    ) : super(key: key);

    @override
    Widget build(BuildContext context) {
        switch(type){
            case PetrinetArcType.weighted:
                return CustomPaint(
                    painter: WeightedArcPainter(
                        from: from,
                        to: to,
                        offset: offset,
                        color: color,
                        backgroundColor: backgroundColor,
                        thickness: thickness
                    ),
                );
            case PetrinetArcType.negated:
                return CustomPaint(
                    painter: NegatedArcPainter(
                        from: from,
                        to: to,
                        offset: offset,
                        color: color,
                        backgroundColor: backgroundColor,
                        thickness: thickness
                    ),
                );
            case PetrinetArcType.reset:
                return CustomPaint(
                    painter: ResetArcPainter(
                        from: from,
                        to: to,
                        offset: offset,
                        color: color,
                        backgroundColor: backgroundColor,
                        thickness: thickness
                    ),
                );
            
        }
    }
}

class WeightedArcPainter extends CustomPainter {
    final Offset from;
    final Offset to;
    final double offset;
    final double thickness;
    final Color color;
    final Color backgroundColor;

    WeightedArcPainter({
        required this.from,
        required this.to,
        required this.offset,
        required this.thickness,
        required this.color,
        required this.backgroundColor,
    });

    @override
    void paint(Canvas canvas, Size size) {
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

        // Calculate the angle between the two points
        final delta = to - from;
        final arrowSize = thickness * 5;

        var offStart = Offset.fromDirection(delta.direction, offset);
        var offEnd = Offset.fromDirection(delta.direction, delta.distance - 2 * offset);
        var offEndShy = Offset.fromDirection(delta.direction, thickness);

        // Calculate the arrow points
        // final arrowPoint1 = Offset((from + to - offStart).dx - arrowSize * math.cos(delta.direction - math.pi / 6), (from + to - offStart).dy - arrowSize * math.sin(delta.direction - math.pi / 6));
        // final arrowPoint2 = Offset((from + to - offStart).dx - arrowSize * math.cos(delta.direction + math.pi / 6), (from + to - offStart).dy - arrowSize * math.sin(delta.direction + math.pi / 6));

        // Draw the line
        path.moveTo(from.dx, from.dy);
        path.relativeMoveTo(offStart.dx, offStart.dy);
        path.relativeLineTo(offEnd.dx, offEnd.dy);
        path.relativeMoveTo(offEndShy.dx, offEndShy.dy);
        canvas.drawPath(path, paint);

        // arrow, 30 degrees (pi/6) for a equilateral triangle
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

class ResetArcPainter extends CustomPainter {
    final Offset from;
    final Offset to;
    final double offset;
    final double thickness;
    final Color color;
    final Color backgroundColor;

    ResetArcPainter({
        required this.from,
        required this.to,
        required this.offset,
        required this.thickness,
        required this.color,
        required this.backgroundColor,
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
        ..style = PaintingStyle.fill;

        final path = Path();

        // Calculate the angle between the two points
        final delta = to - from;
        final radius = thickness * 5;

        var offStart = Offset.fromDirection(delta.direction, offset);
        var offEnd = Offset.fromDirection(delta.direction, delta.distance - 2 * offset);
        var offEndShy = Offset.fromDirection(delta.direction, radius / 2);

        // Draw the line
        path.moveTo(from.dx, from.dy);
        path.relativeMoveTo(offStart.dx, offStart.dy);
        path.relativeLineTo(offEnd.dx, offEnd.dy);
        path.relativeMoveTo(offEndShy.dx, offEndShy.dy);
        canvas.drawPath(path, paint);

        var p = from + offStart + offEndShy;
        canvas.drawRect(Rect.fromCenter(center: p, width: radius, height: radius), paint);
        canvas.drawRect(Rect.fromCenter(center: p, width: radius, height: radius), backpaint);
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) {
        return false;
    }
}

class NegatedArcPainter extends CustomPainter {
    final Offset from;
    final Offset to;
    final double offset;
    final double thickness;
    final Color color;
    final Color backgroundColor;

    NegatedArcPainter({
        required this.from,
        required this.to,
        required this.offset,
        required this.thickness,
        required this.color,
        required this.backgroundColor,
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
        ..style = PaintingStyle.fill;

        final path = Path();

        // Calculate the angle between the two points
        final delta = to - from;
        final radius = thickness * 5 / 2;

        var offStart = Offset.fromDirection(delta.direction, offset);
        var offEnd = Offset.fromDirection(delta.direction, delta.distance - 2 * offset);
        var offEndShy = Offset.fromDirection(delta.direction, radius / 2);

        // Calculate the arrow points
        // final arrowPoint1 = Offset((from + to - offStart).dx - arrowSize * math.cos(delta.direction - math.pi / 6), (from + to - offStart).dy - arrowSize * math.sin(delta.direction - math.pi / 6));
        // final arrowPoint2 = Offset((from + to - offStart).dx - arrowSize * math.cos(delta.direction + math.pi / 6), (from + to - offStart).dy - arrowSize * math.sin(delta.direction + math.pi / 6));

        // Draw the line
        path.moveTo(from.dx, from.dy);
        path.relativeMoveTo(offStart.dx, offStart.dy);
        path.relativeLineTo(offEnd.dx, offEnd.dy);
        path.relativeMoveTo(offEndShy.dx, offEndShy.dy);
        canvas.drawPath(path, paint);

        // endball
        var p = from + offStart + offEnd;
        canvas.drawCircle(p, radius, paint);
        canvas.drawCircle(p, radius, backpaint);
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) {
        return false;
    }
}