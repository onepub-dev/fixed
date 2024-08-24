# 5.0.1
- Fixed a bug where we didn't allow a decimal number to start with dot - e.g. 0.1 == .1
- added unit tests for constant values.

# 5.0.0
- BREAKING: Changed Fixed.one, Fixed.zero, Fixed.two and Fixed.ten to be 'scale:0' when previously there were scale 16.  This means the display as an integer value (more in line with what is expected) and when combined with other values that have a larger scale then the other value will dictate the scale rather then forcing scale 16 on the results.

- Fixed a bug in tryParse where it would throw rather than returning null on some input (such as an empty string).

# 4.3.0
- renamed IllegalPatternException to IllegalFitxedPatternException as the original name was colliding
with an exception on Money2 with the same name. Used a minor version so that users would automatically get
this fix. 4.2 probably should have been a major version no.


# 4.2.0
- moved all exceptions into exceptions.dart. Exported exceptions.dart so users can explicitly catch each of these exceptions. Change the exception hierarcy so all exceptions derive from FixedException which was the documented  and inteneded heirarchy.

# 4.1.1
- updated the doco for fixed constancts (one, zero, two, ten) to reflect that they actually have a scale of 16 not 2.

# 4.1.0
- upgraded to intl 0.19

# 4.0.1
- fixed link to onepub image.

# 4.0.0
- moved the min sdk version to dart 3.x

# 3.0.1
- fixes #13 toInt was not returning the expected value.
- thanks to flodiebold for raising the issue and providing the solution.

# 3.0.0
- updated to dart 3.x

# 2.4.0
- Updated version of intl and meta to latest. 
# 2.3.3
- Fixed: #11 - zero divide when calling Fixed.toInt when Fixed is zero. Thanks to dmitry-kotorov for reporting this bug. Z
- Removed the 'Unauthorized copying of this file' notice that had incorrectly been applied to some files. The code is fully MIT.

# 2.3.2
- Fixed for #10 as reported b7 @oakstair. Trunction of decimals rather than the required rounding when the calling tryParse with a string with scale larger than the passed scale.

# 2.3.0
- updated min sdk to 2.14 as latest version of decimal requires 2.14.
- Applied lint_hard rules.
- upgrade to decimal-2.3.0 to resolve breaking change between decimal 2.2 and 2.3
  Thanks to Alexandre Ardhuin @a14n for the patch.

# 2.2.1
- Fixed rouding problem when multiplying -ve numbers.

# 2.2.0
- BREAKING: change the default toString format to include a leading zero for numbers less than 1.  This is inline with user expectations but a change for the prior releases.

# 2.1.1
- Fixed a bug in the encoder when the value is less than 1.
  This was causing an array out of bounds when formatting small amounts.

# 2.1.0
- upgraded to decimal 2.2.
- made takeMinorDigits private as its not part of the public api.

# 2.0.0-beta.1
- updated the home/repository links to onepub-dev.
- Breaking: Change the default scale when creating a Fixed from a 'num' from 2 to 16.  This is an attempt to make Fixed values built from a num work as the user expects it to. 
- Rewrote the formatter to remove its reliance on NumberFormat as  it can't handle large BigInts.
- Internal storage has moved from Decimal to BigInt to make support easier. Possible performance gain as well.

# 1.1.0
- Fixed #7 We now include platform specific defs of max and min ints as the web version of dart ints are only 53 bits.
# 1.0.3
- reduce the dart minimum version from 2.14 to 2.12
- formatting

# 1.0.2
- Fixed a bug in Fixed.copyWith where if the scale wasn't passed the existing scale wasn't retained.

# 1.0.1
- spelling grammar and formatting.

# 1.0.1
 - change Fixed() to Fixed.copyWith


# 1.0.0-beta4
- Renamed Fixed.from to Fixed.fromNum for consistency with other ctor names. 
- Fixed.fromNum now throws an AmountTooLargeException. 
- Fixed.fromMinorUnits has been renamed Fixed.fromInt
- Added tests for rescaling and rounding when rescaling.
- change rescale to round rather than truncate as the truncation was causing unexpected results (e.g. rounding errors).
- fix issue with decimal without precision

# 1.0.0-beta3
- changes the underlying implementation to use the decimal package
  Thanks to Alexandre Ardhuin for the significant contribution that made this possible :)
- Created statics for one, two and zero. Created consts for maxInt and minInt. Added ~/, %, remainder, abs, sign, pow, toInt
- change thousandSeparator to groupSeparator as this is the more generally used term
- Changed Fixed.fromBigInt to take minor units rather than major units as I found I was constantly misusing it. I think actually makes more sense you can always BigInt.toInt and Fixed.from to create a fixed from a BigInt.
- Fixed the formatter for small -ve numbers. Added a 'decimalPart' method to return just the decimal component of the fixed no. Renamed majorUnits to 'integerPart'

# 1.0.0-beta2
Improved the documentation.

# 1.0.0-beta1
First release of Fixed.
