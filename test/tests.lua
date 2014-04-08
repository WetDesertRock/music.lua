local tester = require "tester"

package.path = "../?.lua;" .. package.path

local music = require "music"

local tests = {}
local testeq = tester.test.equal

-- music.pitchRatio(semitones,temperment)
tests["music.pitchRatio"] = function()
    testeq( music.pitchRatio(12, "equal"),  2  )
    testeq( music.pitchRatio(24, "equal"),  4  )
    testeq( music.pitchRatio(12, "pythagorean"),  2  )
    testeq( music.pitchRatio(24, "pythagorean"),  4  )
    testeq( music.pitchRatio(19, "pythagorean"),  3  )
end

-- music.midiToFrequency(midinote [, temperment [, bfreq [, bnote]]])
tests["music.midiToFrequency"] = function()
    testeq( music.midiToFrequency(69, "equal"),           440  )
    testeq( music.midiToFrequency(69, "equal", 220, 57),  440  )

    testeq( music.midiToFrequency(69, "pythagorean"),           440  )
    testeq( music.midiToFrequency(69, "pythagorean", 220, 57),  440  )
end

-- music.noteToInt(notename)
tests["music.noteToInt"] = function()
    testeq( music.noteToInt("C"),  0 )
    testeq( music.noteToInt("C############"), 0 )
    testeq( music.noteToInt("C############bbbbbbbbbbbb"), 0 )

    testeq( music.noteToInt("B"), 11 )
    testeq( music.noteToInt("B#"), 0 )
    testeq( music.noteToInt("F"),  5 )
end

-- music.intToNote(noteint)
tests["music.intToNote"] = function()
    testeq( music.intToNote(0),   "C" )
    testeq( music.intToNote(11),  "B" )
    testeq( music.intToNote(5),   "F" )
    testeq( music.intToNote(6),  "F#" )
end

-- music.normalizeNoteName(notename)
tests["music.normalizeNoteName"] = function()
    testeq( music.normalizeNoteName("C"),  "C" )
    testeq( music.normalizeNoteName("C############"), "C" )
    testeq( music.normalizeNoteName("C############bbbbbbbbbbbb"), "C" )
    testeq( music.normalizeNoteName("Fb"), "E" )
    testeq( music.normalizeNoteName("Eb"), "D#" )
end

-- music.interval(interval)
tests["music.interval"] = function()
    testeq( music.interval("M2"),   2 )
    testeq( music.interval("m2"),   1 )
    testeq( music.interval("A7"),  12 )
    testeq( music.interval("U"),    0 )
    testeq( music.interval("d0"),  -1 )
end

-- music.chord(root,chord)
tests["music.chord"] = function()
    testeq( music.chord("C",music.chords.major),   {0,4,7} )
    testeq( music.chord("C#",music.chords.major),  {1,5,8} )
    testeq( music.chord("C",music.chords.minor),   {0,3,7} )
    testeq( music.chord("C",music.chords.dim),     {0,3,6} )

    testeq( music.chord("C",music.chords.MM7),      {0,4,7,11} )
    testeq( music.chord("C",music.chords.Mm7),      {0,4,7,10} )
    testeq( music.chord("C",music.chords.mm7),      {0,3,7,10} )
    testeq( music.chord("C",music.chords.dim7),      {0,3,6,9} )
    testeq( music.chord("C",music.chords.hdim7),      {0,3,6,10} )
end

-- music.scale(key,scale)
tests["music.scale"] = function()
    testeq( music.scale("C",music.scales.major),        {0,2,4,5,7,9,11} )
    testeq( music.scale("D",music.scales.dorian),       {2,4,5,7,9,11,0} )
    testeq( music.scale("E",music.scales.phrygian),     {4,5,7,9,11,0,2} )
    testeq( music.scale("F",music.scales.lydian),       {5,7,9,11,0,2,4} )
    testeq( music.scale("G",music.scales.mixolydian),   {7,9,11,0,2,4,5} )
    testeq( music.scale("A",music.scales.aeolian),      {9,11,0,2,4,5,7} )
    testeq( music.scale("B",music.scales.locrian),      {11,0,2,4,5,7,9} )

    testeq( music.scale("C",music.scales.minor),        {0,2,3,5,7,8,10} )
end

-- music.diatonicChord(root,scale,ctype,inversion)
tests["music.diatonicChord"] = function()
    local scale = music.scale(0,music.scales.major)
    testeq( music.diatonicChord(1,scale,"triad",0),    {0,4,7} )
    testeq( music.diatonicChord(1,scale,"triad",1),    {4,7,12} )
    testeq( music.diatonicChord(1,scale,"triad",2),    {7,12,16} )
end

tester.dotests(tests)
tester.test.global()
tester.printresults()
