// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'border_radius.dart';
import 'borders.dart';
import 'color.dart';
import 'edge_insets.dart';
import 'hash_values.dart';

// Examples can assume:
// BuildContext context;

/// A border of a box, comprised of four sides: top, right, bottom, left.
///
/// The sides are represented by [BorderSide] objects.
///
/// {@tool sample}
///
/// All four borders the same, two-pixel wide solid white:
///
/// ```dart
/// Border.all(width: 2.0, color: const Color(0xFFFFFFFF))
/// ```
/// {@end-tool}
/// {@tool sample}
///
/// The border for a material design divider:
///
/// ```dart
/// Border(bottom: BorderSide(color: Theme.of(context).dividerColor))
/// ```
/// {@end-tool}
/// {@tool sample}
///
/// A 1990s-era "OK" button:
///
/// ```dart
/// Container(
///   decoration: const BoxDecoration(
///     border: Border(
///       top: BorderSide(width: 1.0, color: Color(0xFFFFFFFFFF)),
///       left: BorderSide(width: 1.0, color: Color(0xFFFFFFFFFF)),
///       right: BorderSide(width: 1.0, color: Color(0xFFFF000000)),
///       bottom: BorderSide(width: 1.0, color: Color(0xFFFF000000)),
///     ),
///   ),
///   child: Container(
///     padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
///     decoration: const BoxDecoration(
///       border: Border(
///         top: BorderSide(width: 1.0, color: Color(0xFFFFDFDFDF)),
///         left: BorderSide(width: 1.0, color: Color(0xFFFFDFDFDF)),
///         right: BorderSide(width: 1.0, color: Color(0xFFFF7F7F7F)),
///         bottom: BorderSide(width: 1.0, color: Color(0xFFFF7F7F7F)),
///       ),
///       color: Color(0xFFBFBFBF),
///     ),
///     child: const Text(
///       'OK',
///       textAlign: TextAlign.center,
///       style: TextStyle(color: Color(0xFF000000))
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [BoxDecoration], which uses this class to describe its edge decoration.
///  * [BorderSide], which is used to describe each side of the box.
///  * [Theme], from the material layer, which can be queried to obtain appropriate colors
///    to use for borders in a material app, as shown in the "divider" sample above.
class Border extends BoxBorder {
  @override
  final BorderSide top;

  /// The right side of this border.
  final BorderSide right;

  @override
  final BorderSide bottom;

  /// The left side of this border.
  final BorderSide left;

  /// Creates a border.
  ///
  /// All the sides of the border default to [BorderSide.none].
  ///
  /// The arguments must not be null.
  const Border({
    this.top = BorderSide.none,
    this.right = BorderSide.none,
    this.bottom = BorderSide.none,
    this.left = BorderSide.none,
  });

  /// A uniform border with all sides the same color and width.
  ///
  /// The sides default to black solid borders, one logical pixel wide.
  factory Border.all({
    Color color = const Color(0xFF000000),
    double width = 1.0,
    BorderStyle style = BorderStyle.solid,
  }) {
    final BorderSide side = BorderSide(color: color, width: width, style: style);
    return Border.fromBorderSide(side);
  }

  /// Creates a border whose sides are all the same.
  ///
  /// The `side` argument must not be null.
  const Border.fromBorderSide(BorderSide side)
      : top = side,
        right = side,
        bottom = side,
        left = side;

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.fromLTRB(left.width, top.width, right.width, bottom.width);
  }

  @override
  int get hashCode => hashValues(top, right, bottom, left);

  @override
  bool get isUniform {
    final Color topColor = top.color;
    if (right.color != topColor || bottom.color != topColor || left.color != topColor) return false;

    final double topWidth = top.width;
    if (right.width != topWidth || bottom.width != topWidth || left.width != topWidth) return false;

    final BorderStyle topStyle = top.style;
    if (right.style != topStyle || bottom.style != topStyle || left.style != topStyle) return false;

    return true;
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final Border typedOther = other;
    return top == typedOther.top &&
        right == typedOther.right &&
        bottom == typedOther.bottom &&
        left == typedOther.left;
  }

  @override
  Border? add(ShapeBorder other, {bool reversed = false}) {
    if (other is! Border) return null;
    final Border typedOther = other;
    if (BorderSide.canMerge(top, typedOther.top) &&
        BorderSide.canMerge(right, typedOther.right) &&
        BorderSide.canMerge(bottom, typedOther.bottom) &&
        BorderSide.canMerge(left, typedOther.left)) {
      return Border.merge(this, typedOther);
    }
    return null;
  }

  @override
  ShapeBorder? lerpFrom(covariant ShapeBorder a, double t) {
    if (a is Border) return Border.lerp(a, this, t);
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(covariant ShapeBorder b, double t) {
    if (b is Border) return Border.lerp(this, b, t);
    return super.lerpTo(b, t);
  }

  @override
  Border scale(double t) {
    return Border(
      top: top.scale(t),
      right: right.scale(t),
      bottom: bottom.scale(t),
      left: left.scale(t),
    );
  }

  @override
  String toString() {
    if (isUniform) return '$runtimeType.all($top)';
    final List<String> arguments = <String>[
      if (top != BorderSide.none) 'top: $top',
      if (right != BorderSide.none) 'right: $right',
      if (bottom != BorderSide.none) 'bottom: $bottom',
      if (left != BorderSide.none) 'left: $left',
    ];
    return '$runtimeType(${arguments.join(", ")})';
  }

  /// Linearly interpolate between two borders.
  ///
  /// If a border is null, it is treated as having four [BorderSide.none]
  /// borders.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static Border? lerp(Border? a, Border? b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return b!.scale(t);
    if (b == null) return a.scale(1.0 - t);
    return Border(
      top: BorderSide.lerp(a.top, b.top, t),
      right: BorderSide.lerp(a.right, b.right, t),
      bottom: BorderSide.lerp(a.bottom, b.bottom, t),
      left: BorderSide.lerp(a.left, b.left, t),
    );
  }

  /// Creates a [Border] that represents the addition of the two given
  /// [Border]s.
  ///
  /// It is only valid to call this if [BorderSide.canMerge] returns true for
  /// the pairwise combination of each side on both [Border]s.
  ///
  /// The arguments must not be null.
  static Border merge(Border a, Border b) {
    assert(BorderSide.canMerge(a.top, b.top));
    assert(BorderSide.canMerge(a.right, b.right));
    assert(BorderSide.canMerge(a.bottom, b.bottom));
    assert(BorderSide.canMerge(a.left, b.left));
    return Border(
      top: BorderSide.merge(a.top, b.top),
      right: BorderSide.merge(a.right, b.right),
      bottom: BorderSide.merge(a.bottom, b.bottom),
      left: BorderSide.merge(a.left, b.left),
    );
  }
}

/// A border of a box, comprised of four sides, the lateral sides of which
/// flip over based on the reading direction.
///
/// The lateral sides are called [start] and [end]. When painted in
/// left-to-right environments, the [start] side will be painted on the left and
/// the [end] side on the right; in right-to-left environments, it is the
/// reverse. The other two sides are [top] and [bottom].
///
/// The sides are represented by [BorderSide] objects.
///
/// If the [start] and [end] sides are the same, then it is slightly more
/// efficient to use a [Border] object rather than a [BorderDirectional] object.
///
/// See also:
///
///  * [BoxDecoration], which uses this class to describe its edge decoration.
///  * [BorderSide], which is used to describe each side of the box.
///  * [Theme], from the material layer, which can be queried to obtain appropriate colors
///    to use for borders in a material app, as shown in the "divider" sample above.
class BorderDirectional extends BoxBorder {
  @override
  final BorderSide top;

  /// The start side of this border.
  ///
  /// This is the side on the left in left-to-right text and on the right in
  /// right-to-left text.
  ///
  /// See also:
  ///
  ///  * [TextDirection], which is used to describe the reading direction.
  final BorderSide start;

  /// The end side of this border.
  ///
  /// This is the side on the right in left-to-right text and on the left in
  /// right-to-left text.
  ///
  /// See also:
  ///
  ///  * [TextDirection], which is used to describe the reading direction.
  final BorderSide end;

  @override
  final BorderSide bottom;

  /// Creates a border.
  ///
  /// The [start] and [end] sides represent the horizontal sides; the start side
  /// is on the leading edge given the reading direction, and the end side is on
  /// the trailing edge. They are resolved during [paint].
  ///
  /// All the sides of the border default to [BorderSide.none].
  ///
  /// The arguments must not be null.
  const BorderDirectional({
    this.top = BorderSide.none,
    this.start = BorderSide.none,
    this.end = BorderSide.none,
    this.bottom = BorderSide.none,
  });

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsetsDirectional.fromSTEB(start.width, top.width, end.width, bottom.width);
  }

  @override
  int get hashCode => hashValues(top, start, end, bottom);

  @override
  bool get isUniform {
    final Color topColor = top.color;
    if (start.color != topColor || end.color != topColor || bottom.color != topColor) return false;

    final double topWidth = top.width;
    if (start.width != topWidth || end.width != topWidth || bottom.width != topWidth) return false;

    final BorderStyle topStyle = top.style;
    if (start.style != topStyle || end.style != topStyle || bottom.style != topStyle) return false;

    return true;
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    final BorderDirectional typedOther = other;
    return top == typedOther.top &&
        start == typedOther.start &&
        end == typedOther.end &&
        bottom == typedOther.bottom;
  }

  @override
  BoxBorder? add(ShapeBorder other, {bool reversed = false}) {
    if (other is BorderDirectional) {
      final BorderDirectional typedOther = other;
      if (BorderSide.canMerge(top, typedOther.top) &&
          BorderSide.canMerge(start, typedOther.start) &&
          BorderSide.canMerge(end, typedOther.end) &&
          BorderSide.canMerge(bottom, typedOther.bottom)) {
        return BorderDirectional.merge(this, typedOther);
      }
      return null;
    }
    if (other is Border) {
      final Border typedOther = other;
      if (!BorderSide.canMerge(typedOther.top, top) ||
          !BorderSide.canMerge(typedOther.bottom, bottom)) return null;
      if (start != BorderSide.none || end != BorderSide.none) {
        if (typedOther.left != BorderSide.none || typedOther.right != BorderSide.none) return null;
        assert(typedOther.left == BorderSide.none);
        assert(typedOther.right == BorderSide.none);
        return BorderDirectional(
          top: BorderSide.merge(typedOther.top, top),
          start: start,
          end: end,
          bottom: BorderSide.merge(typedOther.bottom, bottom),
        );
      }
      assert(start == BorderSide.none);
      assert(end == BorderSide.none);
      return Border(
        top: BorderSide.merge(typedOther.top, top),
        right: typedOther.right,
        bottom: BorderSide.merge(typedOther.bottom, bottom),
        left: typedOther.left,
      );
    }
    return null;
  }

  @override
  ShapeBorder? lerpFrom(covariant ShapeBorder a, double t) {
    if (a is BorderDirectional) return BorderDirectional.lerp(a, this, t);
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(covariant ShapeBorder b, double t) {
    if (b is BorderDirectional) return BorderDirectional.lerp(this, b, t);
    return super.lerpTo(b, t);
  }

  @override
  BorderDirectional scale(double t) {
    return BorderDirectional(
      top: top.scale(t),
      start: start.scale(t),
      end: end.scale(t),
      bottom: bottom.scale(t),
    );
  }

  @override
  String toString() {
    final List<String> arguments = <String>[
      if (top != BorderSide.none) 'top: $top',
      if (start != BorderSide.none) 'start: $start',
      if (end != BorderSide.none) 'end: $end',
      if (bottom != BorderSide.none) 'bottom: $bottom',
    ];
    return '$runtimeType(${arguments.join(", ")})';
  }

  /// Linearly interpolate between two borders.
  ///
  /// If a border is null, it is treated as having four [BorderSide.none]
  /// borders.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static BorderDirectional? lerp(BorderDirectional? a, BorderDirectional? b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return b!.scale(t);
    if (b == null) return a.scale(1.0 - t);
    return BorderDirectional(
      top: BorderSide.lerp(a.top, b.top, t),
      end: BorderSide.lerp(a.end, b.end, t),
      bottom: BorderSide.lerp(a.bottom, b.bottom, t),
      start: BorderSide.lerp(a.start, b.start, t),
    );
  }

  /// Creates a [BorderDirectional] that represents the addition of the two
  /// given [BorderDirectional]s.
  ///
  /// It is only valid to call this if [BorderSide.canMerge] returns true for
  /// the pairwise combination of each side on both [BorderDirectional]s.
  ///
  /// The arguments must not be null.
  static BorderDirectional merge(BorderDirectional a, BorderDirectional b) {
    assert(BorderSide.canMerge(a.top, b.top));
    assert(BorderSide.canMerge(a.start, b.start));
    assert(BorderSide.canMerge(a.end, b.end));
    assert(BorderSide.canMerge(a.bottom, b.bottom));
    return BorderDirectional(
      top: BorderSide.merge(a.top, b.top),
      start: BorderSide.merge(a.start, b.start),
      end: BorderSide.merge(a.end, b.end),
      bottom: BorderSide.merge(a.bottom, b.bottom),
    );
  }
}

/// Base class for box borders that can paint as rectangles, circles, or rounded
/// rectangles.
///
/// This class is extended by [Border] and [BorderDirectional] to provide
/// concrete versions of four-sided borders using different conventions for
/// specifying the sides.
///
/// The only API difference that this class introduces over [ShapeBorder] is
/// that its [paint] method takes additional arguments.
///
/// See also:
///
///  * [BorderSide], which is used to describe each side of the box.
///  * [RoundedRectangleBorder], another way of describing a box's border.
///  * [CircleBorder], another way of describing a circle border.
///  * [BoxDecoration], which uses a [BoxBorder] to describe its borders.
abstract class BoxBorder extends ShapeBorder {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const BoxBorder();

  /// The bottom side of this border.
  BorderSide get bottom;

  /// Whether all four sides of the border are identical. Uniform borders are
  /// typically more efficient to paint.
  ///
  /// A uniform border by definition has no text direction dependency and
  /// therefore could be expressed as a [Border], even if it is currently a
  /// [BorderDirectional]. A uniform border can also be expressed as a
  /// [RoundedRectangleBorder].
  bool get isUniform;

  /// The top side of this border.
  ///
  /// This getter is available on both [Border] and [BorderDirectional]. If
  /// [isUniform] is true, then this is the same style as all the other sides.
  BorderSide get top;

  // We override this to tighten the return value, so that callers can assume
  // that we'll return a [BoxBorder].
  @override
  BoxBorder? add(ShapeBorder other, {bool reversed = false}) => null;

  /// Linearly interpolate between two borders.
  ///
  /// If a border is null, it is treated as having four [BorderSide.none]
  /// borders.
  ///
  /// This supports interpolating between [Border] and [BorderDirectional]
  /// objects. If both objects are different types but both have sides on one or
  /// both of their lateral edges (the two sides that aren't the top and bottom)
  /// other than [BorderSide.none], then the sides are interpolated by reducing
  /// `a`'s lateral edges to [BorderSide.none] over the first half of the
  /// animation, and then bringing `b`'s lateral edges _from_ [BorderSide.none]
  /// over the second half of the animation.
  ///
  /// For a more flexible approach, consider [ShapeBorder.lerp], which would
  /// instead [add] the two sets of sides and interpolate them simultaneously.
  ///
  /// {@macro dart.ui.shadow.lerp}
  static BoxBorder? lerp(BoxBorder? a, BoxBorder? b, double t) {
    if ((a is Border || a == null) && (b is Border || b == null))
      return Border.lerp(a as Border, b as Border, t);
    if ((a is BorderDirectional || a == null) && (b is BorderDirectional || b == null))
      return BorderDirectional.lerp(a as BorderDirectional, b as BorderDirectional, t);
    if (b is Border && a is BorderDirectional) {
      final BoxBorder c = b;
      b = a;
      a = c;
      t = 1.0 - t;
      // fall through to next case
    }
    if (a is Border && b is BorderDirectional) {
      if (b.start == BorderSide.none && b.end == BorderSide.none) {
        // The fact that b is a BorderDirectional really doesn't matter, it turns out.
        return Border(
          top: BorderSide.lerp(a.top, b.top, t),
          right: BorderSide.lerp(a.right, BorderSide.none, t),
          bottom: BorderSide.lerp(a.bottom, b.bottom, t),
          left: BorderSide.lerp(a.left, BorderSide.none, t),
        );
      }
      if (a.left == BorderSide.none && a.right == BorderSide.none) {
        // The fact that a is a Border really doesn't matter, it turns out.
        return BorderDirectional(
          top: BorderSide.lerp(a.top, b.top, t),
          start: BorderSide.lerp(BorderSide.none, b.start, t),
          end: BorderSide.lerp(BorderSide.none, b.end, t),
          bottom: BorderSide.lerp(a.bottom, b.bottom, t),
        );
      }
      // Since we have to swap a visual border for a directional one,
      // we speed up the horizontal sides' transitions and switch from
      // one mode to the other at t=0.5.
      if (t < 0.5) {
        return Border(
          top: BorderSide.lerp(a.top, b.top, t),
          right: BorderSide.lerp(a.right, BorderSide.none, t * 2.0),
          bottom: BorderSide.lerp(a.bottom, b.bottom, t),
          left: BorderSide.lerp(a.left, BorderSide.none, t * 2.0),
        );
      }
      return BorderDirectional(
        top: BorderSide.lerp(a.top, b.top, t),
        start: BorderSide.lerp(BorderSide.none, b.start, (t - 0.5) * 2.0),
        end: BorderSide.lerp(BorderSide.none, b.end, (t - 0.5) * 2.0),
        bottom: BorderSide.lerp(a.bottom, b.bottom, t),
      );
    }
    throw Exception();
  }
}

/// The shape to use when rendering a [Border] or [BoxDecoration].
///
/// Consider using [ShapeBorder] subclasses directly (with [ShapeDecoration]),
/// instead of using [BoxShape] and [Border], if the shapes will need to be
/// interpolated or animated. The [Border] class cannot interpolate between
/// different shapes.
enum BoxShape {
  /// An axis-aligned, 2D rectangle. May have rounded corners (described by a
  /// [BorderRadius]). The edges of the rectangle will match the edges of the box
  /// into which the [Border] or [BoxDecoration] is painted.
  ///
  /// See also:
  ///
  ///  * [RoundedRectangleBorder], the equivalent [ShapeBorder].
  rectangle,

  /// A circle centered in the middle of the box into which the [Border] or
  /// [BoxDecoration] is painted. The diameter of the circle is the shortest
  /// dimension of the box, either the width or the height, such that the circle
  /// touches the edges of the box.
  ///
  /// See also:
  ///
  ///  * [CircleBorder], the equivalent [ShapeBorder].
  circle,

  // Don't add more, instead create a new ShapeBorder.
}
