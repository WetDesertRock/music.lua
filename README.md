#Music

A library to aid the use of musical concepts in lua projects.

This library expects that you have some basis and understand of music theory. It
is after all a library implementing music theory! If you need help, feel free to
contact me.


##Installation
This music.lua can be dropped into a project, and required as thus:
`music = require "music"`

##Examples

###Transposing a frequency up a fifth.
```lua
    local freq = 634
    print(freq * music.pitchRatio(music.interval("P5")))
    -- 949.92668673982
```

###Testing if two notes are enharmonic
```lua
    local CSharp = "C#"
    local BSharps = "B##"
    local FNatural = "F"

    print(music.noteToInt(CSharp) == music.noteToInt(BSharps))
    print(music.noteToInt(CSharp) == music.noteToInt(FNatural))
    print(music.noteToInt(BSharps) == music.noteToInt(FNatural))
    -- true
    -- false
    -- false
```

###Printing out the pitches for a G# harmonic minor scale:
```lua
    local GSMinor = music.scale("G#",music.scales.harmonic)
    local outtable = {}
    for _,n in ipairs(GSMinor) do
        table.insert(outtable,music.intToNote(n))
    end
    print(table.concat(outtable,","))
    -- G#,A#,B,C#,D#,E,F#
```

##Function Reference

###music.pitchRatio(semitones,temperment)
Returns a ratio that will modify a sound by `semitones` in equal temperment. If
a different temperment is given then it is used instead. Avaliable temperments
can be found in the table `music.temperments`.

###music.midiToFrequency(midinote [, temperment [, bfreq [, bnote]]])
Returns the frequency value of a midi note using `temperment` (defaults to
equal). If `bfreq` (base frequency) is given it will use that as the frequency
to base calculations on. If you want to use a different note to tune your inequal
temperments, use `bnote` (midi note) to sepecify which frequency you are using.
```lua
    local D = math.floor(music.midiToFrequency(62))
    print(music.midiToFrequency(69,"pythagorean"))
    print(music.midiToFrequency(69,"pythagorean",D,62))
    print(music.midiToFrequency(69,"equal"))
    print(music.midiToFrequency(69,"equal",D,62))
```


###music.noteToInt(notename)
Given a valid `note` (as a string), returns an integer value describing the notes
pitch in relation to a C. Returns an integer between 0 and 11.

A valid note pitch is one where the first character is the base note, and every
character after it is either a # or b, that will raise or lower the pitch. For
instance, `C` is the same as `Dbb` or even `Ebbbb`.

###music.intToNote(noteint)
Does the reverse of music.noteAsInt. Returns a notestring.

###music.normalizeNoteName(notename)
Given a note string, returns a sane version of the notestring.
```lua
    local crazynote = "Cbb#b#bbb##"
    print(music.normalizeNoteName(crazynote))
    -- A#
```

###music.interval(interval)
Gives the number of semi tones needed to aquire the specified `interval`. A
valid interval will always have a quality, and then a number specifying the
interval. Valid qualities are `P` for perfect, `M` for major, `m` for minor, `d`
for diminished, and `A for augmented.

###music.chord(root,chord)
Gets a chord `chord` built off of `root`. Chord is a table with intervals inside.
Example:
`d_minor_chord = music.chord("D",music.chords.minor) -- Result: {2, 5, 9}`

###music.diatonicChord(root,scale [, ctype [, inversion]])
Gets a diatonic chord built off of `root` in the specified scale (key) Note that
`root` is the position in the scale, so the fifth scale degree would be a 5. If
`ctype` can be used to change what kind of chord you get. Avaliable options are
"triad" and "7", for a triad and seventh chords. `inversion` is the inversion
number of the chord, 0 is root position, 1 is the first inversion, 2 the second
and so on.
``` lua
local scale = music.scale("D",music.scales.major)
music.diatonicChord(5,scale,"7",3) -- Gets a V4-2 chord.

```


###music.scale(key,scale)
Given a key and scale, returns a table of the pitches in a scale. Example:
`local DMaj = music.scale("D",music.scales.major)`


##Variable Reference

###Scales
####Major
`music.scales.major`  

####Minor
`music.scales.minor`  
`music.scales.harmonicminor`  
`music.scales.melodicminor`  

####Other modes
`music.scales.dorian`  
`music.scales.phrygian`  
`music.scales.lydian`  
`music.scales.mixolydian`  
`music.scales.aeolian`  
`music.scales.locrian`  

###Chords
`music.chords.major`  
`music.chords.minor`  
`music.chords.dim`  
`music.chords.MM7`  
`music.chords.Mm7`  
`music.chords.mm7`  
`music.chords.dim7`  
`music.chords.hdim7`  

###Misc
`music.temperments` - List of the avaliable temperments.

##TODO
* Fix intervals so you can have a dim 7. Perhaps just use a simple table look up?
  No fancy trickery?
