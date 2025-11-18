//
//  Astrolog-Bridging-Header.h
//  Astrolog
//
//  Bridging header for integrating C libraries with Swift
//

#ifndef Astrolog_Bridging_Header_h
#define Astrolog_Bridging_Header_h

// MARK: - Swiss Ephemeris Integration
// Uncomment when Swiss Ephemeris C library is added to project

/*
#import "swephexp.h"

// Swiss Ephemeris Constants
// These will be available in Swift after bridging

// Flags for swe_calc() and swe_calc_ut()
#define SEFLG_JPLEPH    1       // use JPL ephemeris
#define SEFLG_SWIEPH    2       // use SWISSEPH ephemeris
#define SEFLG_MOSEPH    4       // use Moshier ephemeris
#define SEFLG_HELCTR    8       // return heliocentric position
#define SEFLG_TRUEPOS   16      // return true positions, not apparent
#define SEFLG_J2000     32      // no precession, i.e. give J2000 equinox
#define SEFLG_NONUT     64      // no nutation, i.e. mean equinox of date
#define SEFLG_SPEED3    128     // speed from 3 positions (do not use it, SEFLG_SPEED is faster and more precise.)
#define SEFLG_SPEED     256     // high precision speed
#define SEFLG_NOGDEFL   512     // turn off gravitational deflection
#define SEFLG_NOABERR   1024    // turn off 'annual' aberration of light
#define SEFLG_ASTROMETRIC (SEFLG_NOABERR|SEFLG_NOGDEFL) // astrometric position
#define SEFLG_EQUATORIAL (2*1024)   // equatorial positions are wanted
#define SEFLG_XYZ       (4*1024)    // cartesian, not polar, coordinates
#define SEFLG_RADIANS   (8*1024)    // coordinates in radians, not degrees
#define SEFLG_BARYCTR   (16*1024)   // barycentric positions
#define SEFLG_TOPOCTR   (32*1024)   // topocentric positions
#define SEFLG_SIDEREAL  (64*1024)   // sidereal positions

// Planet numbers for swe_calc()
#define SE_ECL_NUT      -1
#define SE_SUN          0
#define SE_MOON         1
#define SE_MERCURY      2
#define SE_VENUS        3
#define SE_MARS         4
#define SE_JUPITER      5
#define SE_SATURN       6
#define SE_URANUS       7
#define SE_NEPTUNE      8
#define SE_PLUTO        9
#define SE_MEAN_NODE    10
#define SE_TRUE_NODE    11
#define SE_MEAN_APOG    12
#define SE_OSCU_APOG    13
#define SE_EARTH        14
#define SE_CHIRON       15

// House system codes
#define SE_HS_PLACIDUS      'P'
#define SE_HS_KOCH          'K'
#define SE_HS_PORPHYRIUS    'O'
#define SE_HS_REGIOMONTANUS 'R'
#define SE_HS_CAMPANUS      'C'
#define SE_HS_EQUAL         'A'
#define SE_HS_VEHLOW        'V'
#define SE_HS_WHOLE_SIGN    'W'

// Calendar types
#define SE_JUL_CAL  0
#define SE_GREG_CAL 1

// Indexes for ascmc array
#define SE_ASC      0
#define SE_MC       1
#define SE_ARMC     2
#define SE_VERTEX   3
#define SE_EQUASC   4
#define SE_COASC1   5
#define SE_COASC2   6
#define SE_POLASC   7
*/

// MARK: - Other C Libraries
// Add imports for other C libraries here if needed

#endif /* Astrolog_Bridging_Header_h */
