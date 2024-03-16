/* Copyright (C) Brett Sutton - All Rights Reserved
 * Released under the MIT license.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

/// The Fixed package allows you to store and perform maths on decimal numbers
/// with a fixed scale (fixed number of decimal places).
/// All amounts are stored using the Decimal package to allow precision maths
/// to be performed.
///
/// Conversion from a number of other numberic formats is supported
/// as well as parsing and formatting Fixed scale no.s
///
/// Fixed uses the Decimal package to store the underlying values so
/// the precision is only limited by the size of memory.
///
/// A range of mathematical comparision operations are supported.
library fixed;

export 'src/exceptions.dart';
export 'src/fixed.dart';
