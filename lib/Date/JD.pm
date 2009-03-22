=head1 NAME

Date::JD - conversion between flavours of Julian Date

=head1 SYNOPSIS

	use Date::JD qw(jd_to_mjd mjd_to_cjdn cjdn_to_rd);

	$mjd = jd_to_mjd($jd);
	($cjdn, $cjdf) = mjd_to_cjdn($mjd, $tz);
	$rd = cjdn_to_rd($cjdn, $cjdf);

	# and 253 other conversion functions

=head1 DESCRIPTION

For date and time calculations it is convenient to represent dates by
a simple linear count of days, rather than in a particular calendar.
This is such a good idea that it has been invented several times.
If there were a single such linear count then it would be the obvious
data interchange format between calendar modules.  With several
versions, calendar modules can use such sensible data formats and still
have interoperability problems.  This module tackles that problem,
by performing conversions between different flavours of day count.
These day count systems are generically known as "Julian Dates", after
the most venerable of them.

Among Julian Date systems there are also some non-trivial differences
of concept.  There are systems that count only complete days, and
those that count fractional days also.  There are some that are fixed
to Universal Time (time on the prime meridian), and others that are
interpreted according to a timezone.  Some consider the day to start at
noon and others at midnight, which is semantically significant for the
complete-day counts.  The functions of this module appropriately handle
the semantics of all the non-trivial conversions.

The day count systems supported by this module are Julian Date, Reduced
Julian Date, Modified Julian Date, Dublin Julian Date, Truncated Julian
Date, Chronological Julian Date, Rata Die, and Lilian Date, each in both
integral and fractional forms.

=head2 Flavours of day count

In the interests of orthogonality, all flavours of day count come in both
integral and fractional varieties.  Generally, there is a quantity named
"XYZD" ("XYZ Date") which is a real count of days since a particular epoch
(an integer plus a fraction) and a corresponding quantity named "XYZDN"
("XYZ Day Number") which is a count of complete days since the same epoch.
XYZDN is the integral part of XYZD.  There is also a quantity named
"XYZDF" ("XYZ Day Fraction") which is a count of fractional days since the
XYZDN changed.  XYZDF is the fractional part of XYZD, in the range [0, 1).

This quantity naming pattern is derived from JD (Julian Date) and JDN
(Julian Day Number) which have the described correspondence.  Most of
the other flavours of day count listed below conventionally come in only
one of the two varieties.  The "XYZDF" name type is a neologism.

All calendar dates given are in ISO 8601 form (Gregorian calendar with
astronomical year numbering).  An hour number is appended to each date,
separated by a "T"; hour 00 is midnight at the start of the day and hour
12 is noon in the middle of the day.  An appended "Z" indicates that the
date is to be interpreted in Universal Time (the timezone of the prime
meridian), and so is absolute; where any other timezone is to be used
then this is explicitly noted.

=over

=item JD (Julian Date)

days elapsed since -4713-11-24T12Z.  This epoch is the most recent
coincidence of the first year of the Metonic cycle, indiction cycle, and
day-of-week cycle, using the Julian calendar.  It was correspondingly
named after the Julian calendar, and thus after Julius Caesar.  Some
information can be found at L<http://en.wikipedia.org/wiki/Julian_day>.

=item RJD (Reduced Julian Date)

days elapsed since 1858-11-16T12Z (JD 2400000.0).  Rarely used.

=item MJD (Modified Julian Date)

days elapsed since 1858-11-17T00Z (JD 2400000.5).  This was introduced by
the Smithsonian Astrophysical Observatory in 1957, and is recommended for
general use by the International Astronomical Union and other authorities.

=item DJD (Dublin Julian Date)

days elapsed since 1899-12-31T12Z (JD 2415020.0).  This was invented by
the International Astronomical Union, and the epoch in Terrestrial Time
is the J1900.0 epoch used in astronomy.  (Note: not B1900.0, which is
a few hours later.)  It is rarely used.

=item TJD (Truncated Julian Date)

days elapsed since 1968-05-24T00Z (JD 2440000.5).  This is primarily
used by NASA, who devised it during the Apollo era.  There is a
rumour that it's defined cyclically, as (JD - 0.5) mod 10000, but see
L<http://cossc.gsfc.nasa.gov/cossc/batse/hilev/TJD.TABLE>.

=item CJD (Chronological Julian Date)

days elapsed since -4713-11-24T00 in the timezone of interest.
CJD = JD + 0.5 + Zoff, where Zoff is the timezone offset in
fractional days.  This was devised by Peter Meyer, and described in
L<http://www.hermetic.ch/cal_stud/cjd.htm>.

=item RD (Rata Die)

days elapsed since 0000-12-31T00 in the timezone of interest (CJD
1721425.0).  This is defined in the book Calendrical Calculations.
Confusingly, in the book the integral form is also called "RD".
The integral form is called "RDN" by this module to avoid confusion,
reserving the name "RD" for the fractional form.  (The book is best
treated with caution due to the embarrassingly large number of errors
and instances of muddled thinking.)

=item LD (Lilian Date)

days elapsed since 1582-10-14T00 in the timezone of interest (CJD
2299160.0).  This epoch is the day before the day that the Gregorian
calendar first went into use.  It is named after Aloysius Lilius, the
inventor of the Gregorian calendar.

=back

The interesting differences between these flavours are whether the
day starts at noon or at midnight, and whether they are absolute or
timezone-relative.  Three of the four combinations of these features
exist.  There is no convention for counting days from timezone-relative
noon that the author of this module is aware of.

For more background on these day count systems,
L<http://en.wikipedia.org/wiki/Julian_Date> is a good starting place.

=head2 Meaning of the day

A day count has meaning only in the context of a particular definition
of "day".  There are two main flavours of day to consider: solar and
conventional.

A solar day is based on the apparent motion of Sol in the Terran sky (and
thus on the rotation and orbit of Terra).  The rotation of Terra is not
constant in time, so this type of day is really a measure of angle, not
of time.  This is how days have been counted since antiquity, and is still
(as of 2006) the basis of civil time.  There are two subtypes of solar
day: apparent and mean.  The apparent solar day is based on the actual
observable position of Sol in the sky from day to day, whereas the mean
solar day smooths this motion out, in time, over the course of the year.
At the sub-second level there are different types of smoothing that can
be used (UT1, UT2, et al).

A conventional day is any type of day that is not based on Terran
rotation.  The astronomical Ephemeris Time, a time scale based on the
motion of bodies in the Solar system, has a time unit that it calls
"day" which is derived from astronomical observations.  The modern
relativistic coordinate time scales such as TT have a notional "day"
of exactly 86400 SI seconds.  The atomic time scale TAI also has a "day"
which is as close to 86400 SI seconds as can be achieved.  All of these
"days" are roughly the duration of one Sol-relative rotation of Terra
during the early nineteenth century, but are not otherwise related to
planetary rotation.

Each of the day count scales handled by this module can be used with any
of these types of day.  For a day number to be meaningful it is necessary
to be aware of which kind of day it is counting.  Conversion between the
different types of day is out of scope for this module.  (See L<Time::UTC>
for TAI/UTC conversion.)

=cut

package Date::JD;

use warnings;
use strict;

use Carp qw(croak);

our $VERSION = "0.003";

use base qw(Exporter);
our @EXPORT_OK;

my %jd_flavours = (
	jd => { epoch_jd => 0 },
	rjd => { epoch_jd => 2400000.0 },
	mjd => { epoch_jd => 2400000.5 },
	djd => { epoch_jd => 2415020.0 },
	tjd => { epoch_jd => 2440000.5 },
	cjd => { epoch_jd => -0.5, zone => 1 },
	rd => { epoch_jd => 1721424.5, zone => 1 },
	ld => { epoch_jd => 2299159.5, zone => 1 },
);

=head1 FUNCTIONS

Day counts in this API may be native Perl numbers or C<Math::BigRat>
objects.  Both are acceptable for all parameters, in any combination.
In all conversion functions, the result is of the same type as the
input, provided that the inputs are of consistent type.  If native Perl
numbers are supplied then the conversion is subject to floating point
rounding, and possible overflow if the numbers are extremely large.
The use of C<Math::BigRat> is recommended to avoid these problems.
With C<Math::BigRat> the results are exact.

There are conversion functions between all pairs of day count systems.
This is a total of 256 conversion functions (including 16 identity
functions).

When converting between timezone-relative counts (CJD, RD, LD) and
absolute counts (JD, RJD, MJD, DJD, TJD), the timezone that is being used must
be specified.  It is given in a ZONE argument as a fractional number of
days offset from Universal Time.  For example, US Central Standard Time,
6 hours behind UT, would be specified as a ZONE argument of -0.25.
Beware of floating point rounding when the offset does not have a
terminating binary representation (e.g., US Eastern Standard Time at
-5/24); use of C<Math::BigRat> avoids this problem.  A ZONE parameter is
not used when converting between absolute day counts (e.g., between JD
and MJD) or between timezone-relative counts (e.g., between CJD and LD).

=over

=item jd_to_jd(JD)

=item jd_to_rjd(JD)

=item jd_to_mjd(JD)

=item jd_to_djd(JD)

=item jd_to_tjd(JD)

=item jd_to_cjd(JD, ZONE)

=item jd_to_rd(JD, ZONE)

=item jd_to_ld(JD, ZONE)

=item rjd_to_jd(RJD)

=item rjd_to_rjd(RJD)

=item rjd_to_mjd(RJD)

=item rjd_to_djd(RJD)

=item rjd_to_tjd(RJD)

=item rjd_to_cjd(RJD, ZONE)

=item rjd_to_rd(RJD, ZONE)

=item rjd_to_ld(RJD, ZONE)

=item mjd_to_jd(MJD)

=item mjd_to_rjd(MJD)

=item mjd_to_mjd(MJD)

=item mjd_to_djd(MJD)

=item mjd_to_tjd(MJD)

=item mjd_to_cjd(MJD, ZONE)

=item mjd_to_rd(MJD, ZONE)

=item mjd_to_ld(MJD, ZONE)

=item djd_to_jd(DJD)

=item djd_to_rjd(DJD)

=item djd_to_mjd(DJD)

=item djd_to_djd(DJD)

=item djd_to_tjd(DJD)

=item djd_to_cjd(DJD, ZONE)

=item djd_to_rd(DJD, ZONE)

=item djd_to_ld(DJD, ZONE)

=item tjd_to_jd(TJD)

=item tjd_to_rjd(TJD)

=item tjd_to_mjd(TJD)

=item tjd_to_djd(TJD)

=item tjd_to_tjd(TJD)

=item tjd_to_cjd(TJD, ZONE)

=item tjd_to_rd(TJD, ZONE)

=item tjd_to_ld(TJD, ZONE)

=item cjd_to_jd(CJD, ZONE)

=item cjd_to_rjd(CJD, ZONE)

=item cjd_to_mjd(CJD, ZONE)

=item cjd_to_djd(CJD, ZONE)

=item cjd_to_tjd(CJD, ZONE)

=item cjd_to_cjd(CJD)

=item cjd_to_rd(CJD)

=item cjd_to_ld(CJD)

=item rd_to_jd(RD, ZONE)

=item rd_to_rjd(RD, ZONE)

=item rd_to_mjd(RD, ZONE)

=item rd_to_djd(RD, ZONE)

=item rd_to_tjd(RD, ZONE)

=item rd_to_cjd(RD)

=item rd_to_rd(RD)

=item rd_to_ld(RD)

=item ld_to_jd(LD, ZONE)

=item ld_to_rjd(LD, ZONE)

=item ld_to_mjd(LD, ZONE)

=item ld_to_djd(LD, ZONE)

=item ld_to_tjd(LD, ZONE)

=item ld_to_cjd(LD)

=item ld_to_rd(LD)

=item ld_to_ld(LD)

Conversions between fractional day counts principally involve a change
of epoch.  The input identifies a point in time, as a fractional day
count of input flavour.  The function returns the same point in time,
represented as a fractional day count of output flavour.

=item jd_to_jdn(JD)

=item jd_to_rjdn(JD)

=item jd_to_mjdn(JD)

=item jd_to_djdn(JD)

=item jd_to_tjdn(JD)

=item jd_to_cjdn(JD, ZONE)

=item jd_to_rdn(JD, ZONE)

=item jd_to_ldn(JD, ZONE)

=item rjd_to_jdn(RJD)

=item rjd_to_rjdn(RJD)

=item rjd_to_mjdn(RJD)

=item rjd_to_djdn(RJD)

=item rjd_to_tjdn(RJD)

=item rjd_to_cjdn(RJD, ZONE)

=item rjd_to_rdn(RJD, ZONE)

=item rjd_to_ldn(RJD, ZONE)

=item mjd_to_jdn(MJD)

=item mjd_to_rjdn(MJD)

=item mjd_to_mjdn(MJD)

=item mjd_to_djdn(MJD)

=item mjd_to_tjdn(MJD)

=item mjd_to_cjdn(MJD, ZONE)

=item mjd_to_rdn(MJD, ZONE)

=item mjd_to_ldn(MJD, ZONE)

=item djd_to_jdn(DJD)

=item djd_to_rjdn(DJD)

=item djd_to_mjdn(DJD)

=item djd_to_djdn(DJD)

=item djd_to_tjdn(DJD)

=item djd_to_cjdn(DJD, ZONE)

=item djd_to_rdn(DJD, ZONE)

=item djd_to_ldn(DJD, ZONE)

=item tjd_to_jdn(TJD)

=item tjd_to_rjdn(TJD)

=item tjd_to_mjdn(TJD)

=item tjd_to_djdn(TJD)

=item tjd_to_tjdn(TJD)

=item tjd_to_cjdn(TJD, ZONE)

=item tjd_to_rdn(TJD, ZONE)

=item tjd_to_ldn(TJD, ZONE)

=item cjd_to_jdn(CJD, ZONE)

=item cjd_to_rjdn(CJD, ZONE)

=item cjd_to_mjdn(CJD, ZONE)

=item cjd_to_djdn(CJD, ZONE)

=item cjd_to_tjdn(CJD, ZONE)

=item cjd_to_cjdn(CJD)

=item cjd_to_rdn(CJD)

=item cjd_to_ldn(CJD)

=item rd_to_jdn(RD, ZONE)

=item rd_to_rjdn(RD, ZONE)

=item rd_to_mjdn(RD, ZONE)

=item rd_to_djdn(RD, ZONE)

=item rd_to_tjdn(RD, ZONE)

=item rd_to_cjdn(RD)

=item rd_to_rdn(RD)

=item rd_to_ldn(RD)

=item ld_to_jdn(LD, ZONE)

=item ld_to_rjdn(LD, ZONE)

=item ld_to_mjdn(LD, ZONE)

=item ld_to_djdn(LD, ZONE)

=item ld_to_tjdn(LD, ZONE)

=item ld_to_cjdn(LD)

=item ld_to_rdn(LD)

=item ld_to_ldn(LD)

These conversion functions go from a fractional count to an integral
count.  The input identifies a point in time, as a fractional day count
of input flavour.  The function determines the day number of output
flavour that applies at that instant.  In scalar context only this
integral day number is returned.  In list context a list of two values
is returned: the integral day number and the day fraction in the range
[0, 1).  The day fraction, representing the time of day, is relative to
the instant that the integral day number started to apply, whether that
is noon or midnight.

=item jdn_to_jd(JDN, JDF)

=item jdn_to_rjd(JDN, JDF)

=item jdn_to_mjd(JDN, JDF)

=item jdn_to_djd(JDN, JDF)

=item jdn_to_tjd(JDN, JDF)

=item jdn_to_cjd(JDN, JDF, ZONE)

=item jdn_to_rd(JDN, JDF, ZONE)

=item jdn_to_ld(JDN, JDF, ZONE)

=item rjdn_to_jd(RJDN, RJDF)

=item rjdn_to_rjd(RJDN, RJDF)

=item rjdn_to_mjd(RJDN, RJDF)

=item rjdn_to_djd(RJDN, RJDF)

=item rjdn_to_tjd(RJDN, RJDF)

=item rjdn_to_cjd(RJDN, RJDF, ZONE)

=item rjdn_to_rd(RJDN, RJDF, ZONE)

=item rjdn_to_ld(RJDN, RJDF, ZONE)

=item mjdn_to_jd(MJDN, MJDF)

=item mjdn_to_rjd(MJDN, MJDF)

=item mjdn_to_mjd(MJDN, MJDF)

=item mjdn_to_djd(MJDN, MJDF)

=item mjdn_to_tjd(MJDN, MJDF)

=item mjdn_to_cjd(MJDN, MJDF, ZONE)

=item mjdn_to_rd(MJDN, MJDF, ZONE)

=item mjdn_to_ld(MJDN, MJDF, ZONE)

=item djdn_to_jd(DJDN, DJDF)

=item djdn_to_rjd(DJDN, DJDF)

=item djdn_to_mjd(DJDN, DJDF)

=item djdn_to_djd(DJDN, DJDF)

=item djdn_to_tjd(DJDN, DJDF)

=item djdn_to_cjd(DJDN, DJDF, ZONE)

=item djdn_to_rd(DJDN, DJDF, ZONE)

=item djdn_to_ld(DJDN, DJDF, ZONE)

=item tjdn_to_jd(TJDN, TJDF)

=item tjdn_to_rjd(TJDN, TJDF)

=item tjdn_to_mjd(TJDN, TJDF)

=item tjdn_to_djd(TJDN, TJDF)

=item tjdn_to_tjd(TJDN, TJDF)

=item tjdn_to_cjd(TJDN, TJDF, ZONE)

=item tjdn_to_rd(TJDN, TJDF, ZONE)

=item tjdn_to_ld(TJDN, TJDF, ZONE)

=item cjdn_to_jd(CJDN, CJDF, ZONE)

=item cjdn_to_rjd(CJDN, CJDF, ZONE)

=item cjdn_to_mjd(CJDN, CJDF, ZONE)

=item cjdn_to_djd(CJDN, CJDF, ZONE)

=item cjdn_to_tjd(CJDN, CJDF, ZONE)

=item cjdn_to_cjd(CJDN, CJDF)

=item cjdn_to_rd(CJDN, CJDF)

=item cjdn_to_ld(CJDN, CJDF)

=item rdn_to_jd(RDN, RDF, ZONE)

=item rdn_to_rjd(RDN, RDF, ZONE)

=item rdn_to_mjd(RDN, RDF, ZONE)

=item rdn_to_djd(RDN, RDF, ZONE)

=item rdn_to_tjd(RDN, RDF, ZONE)

=item rdn_to_cjd(RDN, RDF)

=item rdn_to_rd(RDN, RDF)

=item rdn_to_ld(RDN, RDF)

=item ldn_to_jd(LDN, LDF, ZONE)

=item ldn_to_rjd(LDN, LDF, ZONE)

=item ldn_to_mjd(LDN, LDF, ZONE)

=item ldn_to_djd(LDN, LDF, ZONE)

=item ldn_to_tjd(LDN, LDF, ZONE)

=item ldn_to_cjd(LDN, LDF)

=item ldn_to_rd(LDN, LDF)

=item ldn_to_ld(LDN, LDF)

These conversion functions go from an integral count to a fractional
count.  The input identifies a point in time, as an integral day number of
input flavour plus day fraction in the range [0, 1).  The day fraction,
representing the time of day, is relative to the instant that the
integral day number started to apply, whether that is noon or midnight.
The identified point in time is returned in the form of a fractional
day number of output flavour.

=item jdn_to_jdn(JDN[, JDF])

=item jdn_to_rjdn(JDN[, JDF])

=item jdn_to_mjdn(JDN, JDF)

=item jdn_to_djdn(JDN[, JDF])

=item jdn_to_tjdn(JDN, JDF)

=item jdn_to_cjdn(JDN, JDF, ZONE)

=item jdn_to_rdn(JDN, JDF, ZONE)

=item jdn_to_ldn(JDN, JDF, ZONE)

=item rjdn_to_jdn(RJDN[, RJDF])

=item rjdn_to_rjdn(RJDN[, RJDF])

=item rjdn_to_mjdn(RJDN, RJDF)

=item rjdn_to_djdn(RJDN[, RJDF])

=item rjdn_to_tjdn(RJDN, RJDF)

=item rjdn_to_cjdn(RJDN, RJDF, ZONE)

=item rjdn_to_rdn(RJDN, RJDF, ZONE)

=item rjdn_to_ldn(RJDN, RJDF, ZONE)

=item mjdn_to_jdn(MJDN, MJDF)

=item mjdn_to_rjdn(MJDN, MJDF)

=item mjdn_to_mjdn(MJDN[, MJDF])

=item mjdn_to_djdn(MJDN, MJDF)

=item mjdn_to_tjdn(MJDN[, MJDF])

=item mjdn_to_cjdn(MJDN, MJDF, ZONE)

=item mjdn_to_rdn(MJDN, MJDF, ZONE)

=item mjdn_to_ldn(MJDN, MJDF, ZONE)

=item djdn_to_jdn(DJDN[, DJDF])

=item djdn_to_rjdn(DJDN[, DJDF])

=item djdn_to_mjdn(DJDN, DJDF)

=item djdn_to_djdn(DJDN[, DJDF])

=item djdn_to_tjdn(DJDN, DJDF)

=item djdn_to_cjdn(DJDN, DJDF, ZONE)

=item djdn_to_rdn(DJDN, DJDF, ZONE)

=item djdn_to_ldn(DJDN, DJDF, ZONE)

=item tjdn_to_jdn(TJDN, TJDF)

=item tjdn_to_rjdn(TJDN, TJDF)

=item tjdn_to_mjdn(TJDN[, TJDF])

=item tjdn_to_djdn(TJDN, TJDF)

=item tjdn_to_tjdn(TJDN[, TJDF])

=item tjdn_to_cjdn(TJDN, TJDF, ZONE)

=item tjdn_to_rdn(TJDN, TJDF, ZONE)

=item tjdn_to_ldn(TJDN, TJDF, ZONE)

=item cjdn_to_jdn(CJDN, CJDF, ZONE)

=item cjdn_to_rjdn(CJDN, CJDF, ZONE)

=item cjdn_to_mjdn(CJDN, CJDF, ZONE)

=item cjdn_to_djdn(CJDN, CJDF, ZONE)

=item cjdn_to_tjdn(CJDN, CJDF, ZONE)

=item cjdn_to_cjdn(CJDN[, CJDF])

=item cjdn_to_rdn(CJDN[, CJDF])

=item cjdn_to_ldn(CJDN[, CJDF])

=item rdn_to_jdn(RDN, RDF, ZONE)

=item rdn_to_rjdn(RDN, RDF, ZONE)

=item rdn_to_mjdn(RDN, RDF, ZONE)

=item rdn_to_djdn(RDN, RDF, ZONE)

=item rdn_to_tjdn(RDN, RDF, ZONE)

=item rdn_to_cjdn(RDN[, RDF])

=item rdn_to_rdn(RDN[, RDF])

=item rdn_to_ldn(RDN[, RDF])

=item ldn_to_jdn(LDN, LDF, ZONE)

=item ldn_to_rjdn(LDN, LDF, ZONE)

=item ldn_to_mjdn(LDN, LDF, ZONE)

=item ldn_to_djdn(LDN, LDF, ZONE)

=item ldn_to_tjdn(LDN, LDF, ZONE)

=item ldn_to_cjdn(LDN[, LDF])

=item ldn_to_rdn(LDN[, LDF])

=item ldn_to_ldn(LDN[, LDF])

These conversion functions go from an integral count to another integral
count.  They can be used either to convert only a day number or to
convert a point in time using integer-plus-fraction form.  The output
convention is identical to that for C<jd_to_jdn> et al, including the
variation depending on calling context.

If converting a point in time, the input identifies it as an integral
day number of input flavour plus day fraction in the range [0, 1).
The day fraction, representing the time of day, is relative to the
instant that the integral day number started to apply, whether that is
noon or midnight.  The same point in time is (in list context) returned
as a list of integral day number of output flavour and the day fraction
in the range [0, 1).

If it is desired only to convert integral day numbers, it is still
necessary to consider time of day, because in the general case the days
are delimited differently by the input and output day count flavours.
A day fraction must be specified if there is such a difference, and
the conversion is calculated for the point in time thus identified.
To perform a conversion for a large part of the day, give a representative
time of day within it.  If converting between systems that delimit days
identically (e.g., between JD and RJD), the day fraction is optional
and defaults to zero.

=cut

eval { local $SIG{__DIE__};
	require POSIX;
	*_floor = \&POSIX::floor;
};
if($@ ne "") {
	*_floor = sub($) {
		my $i = int($_[0]);
		return $i == $_[0] || $_[0] > 0 ? $i : $i - 1;
	}
}

sub _check_dn($$) {
	croak "purported day number $_[0] is not an integer"
		unless ref($_[0]) ? $_[0]->is_int : $_[0] == int($_[0]);
	croak "purported day fraction $_[1] is out of range [0, 1)"
		unless $_[1] >= 0 && $_[1] < 1;
}

sub _ret_dn($) {
	my $dn = ref($_[0]) eq "Math::BigRat" ?
			$_[0]->copy->bfloor : _floor($_[0]);
	return wantarray ? ($dn, $_[0] - $dn) : $dn;
}

foreach my $src (keys %jd_flavours) { foreach my $dst (keys %jd_flavours) {
	my $ediff = $jd_flavours{$src}->{epoch_jd} -
			$jd_flavours{$dst}->{epoch_jd};
	my $ediffh = $ediff == int($ediff) ? 0 : 0.5;
	my $ediffi = $ediff - $ediffh;
	my $src_zone = !!$jd_flavours{$src}->{zone};
	my $dst_zone = !!$jd_flavours{$dst}->{zone};
	my($zp, $z1, $z2);
	if($src_zone == $dst_zone) {
		$zp = $z1 = $z2 = "";
	} else {
		$zp = "\$";
		my $zsign = $src_zone ? "-" : "+";
		$z1 = "$zsign \$_[1]";
		$z2 = "$zsign \$_[2]";
	}
	eval "sub ${src}_to_${dst}(\$${zp}) { \$_[0] + (${ediff}) ${z1} }";
	push @EXPORT_OK, "${src}_to_${dst}";
	eval "sub ${src}_to_${dst}n(\$${zp}) {
		_ret_dn(\$_[0] + (${ediff}) ${z1})
	}";
	push @EXPORT_OK, "${src}_to_${dst}n";
	eval "sub ${src}n_to_${dst}(\$\$${zp}) {
		_check_dn(\$_[0], \$_[1]);
		\$_[0] + \$_[1] + (${ediff}) ${z2}
	}";
	push @EXPORT_OK, "${src}n_to_${dst}";
	my($tp, $tc);
	if($ediffh == 0 && $src_zone == $dst_zone) {
		$tp = ";";
		$tc = "push \@_, 0 if \@_ == 1;";
	} else {
		$tp = $tc = "";
	}
	eval "sub ${src}n_to_${dst}n(\$${tp}\$${zp}) { $tc
		_check_dn(\$_[0], \$_[1]);
		_ret_dn(\$_[0] + \$_[1] + ($ediff) ${z2})
	}";
	push @EXPORT_OK, "${src}n_to_${dst}n";
} }

=back

=head1 SEE ALSO

L<Date::ISO8601>,
L<Date::MSD>,
L<DateTime>,
L<Time::UTC>

=head1 AUTHOR

Andrew Main (Zefram) <zefram@fysh.org>

=head1 COPYRIGHT

Copyright (C) 2006, 2007, 2009 Andrew Main (Zefram) <zefram@fysh.org>

=head1 LICENSE

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
