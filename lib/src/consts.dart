/* Copyright (C) Brett Sutton - All Rights Reserved
 * Released under the MIT license.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'consts_native.dart' if (dart.library.html) 'consts_js.dart'
    as platform_consts;

const int maxInt = platform_consts.maxInt;
const int minInt = platform_consts.minInt;
