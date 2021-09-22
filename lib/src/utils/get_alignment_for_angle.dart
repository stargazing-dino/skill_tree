import 'dart:math' as math;

import 'package:flutter/rendering.dart';

/// Returns an alignment that corresponds to the direction in which the angle
/// is pointing.
Alignment getAlignmentForAngle(double angle) {
  // The angle goes clockwise starting at 0
  //
  //  -pi 3/4                   -pi/2                  -pi 1/4
  //
  //                               |
  //                     -x -y     |    +x -y
  //                               |
  //  (+/-)pi         ---------------------------            0
  //                               |
  //                     -x +y     |    +x +y
  //                               |
  //
  //  pi 3/4                     pi/2                   pi 1/4
  //

  // TODO: We should provide more arguments here to better define how we want
  // the alignment to come out.

  // Handle the corners
  // if (angle == -math.pi / 4) {
  //   return Alignment.topRight;
  // } else if (angle == -math.pi * 3 / 4) {
  //   return Alignment.topLeft;
  // } else if (angle == math.pi * 3 / 4) {
  //   return Alignment.bottomLeft;
  // } else if (angle == math.pi / 4) {
  //   return Alignment.bottomRight;
  // }

  // If we're between -pi 1/4 and pi 1/4 we're going right
  if (angle.abs() < math.pi / 4) {
    return Alignment.centerRight;
  }

  // If we're between -pi 3/4 and -pi 1/4 we're going up
  else if (angle > -math.pi * 3 / 4 && angle < -math.pi / 4) {
    return Alignment.topCenter;
  }

  // We're going left between -pi 3/4 and pi 3/4
  else if (angle.abs() > math.pi * 3 / 4) {
    return Alignment.centerLeft;
  }

  // We're going down
  else {
    return Alignment.bottomCenter;
  }
}
