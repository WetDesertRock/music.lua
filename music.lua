--
-- music.lua
--
-- The MIT License (MIT)
--
-- Copyright (c) 2014, DesertRock
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
-- Along with the above license, I'd apperciate it if you submitted any fixes/
-- changes/improvements my way so I can consider including them in this library.
--

local music = {}

music.scales = {}
music.scales.dorian =   {2,1,2,2,2,1}
music.scales.phrygian = {1,2,2,2,1,2}
music.scales.lydian = {2,2,2,1,2,2}
music.scales.mixolydian = {2,2,1,2,2,1}
music.scales.aeolian = {2,1,2,2,1,2}
music.scales.locrian = {1,2,2,1,2,2}

music.scales.major = {2,2,1,2,2,2}
music.scales.minor = music.scales.aeolian
music.scales.harmonicminor = {2,1,2,2,1,3}
music.scales.melodicminor = {2,1,2,2,2,2}

music.chords = {}
music.chords.major = {"U","M3","P5"}
music.chords.minor = {"U","m3","P5"}
music.chords.dim = {"U","m3","d5"}
music.chords.MM7 = {"U","M3","P5","M7"}
music.chords.Mm7 = {"U","M3","P5","m7"}
music.chords.mm7 = {"U","m3","P5","m7"}
music.chords.dim7 = {"U","m3","d5","M6"} -- Hm, my method for getting intervals falls apart here.
music.chords.hdim7 = {"U","m3","d5","m7"}

music.temperments = {"equal","pythagorean"}

local EQUAL_PITCHMOD = 2.0^(1/12)

local NOTES = {
    C = 0,
    D = 2,
    E = 4,
    F = 5,
    G = 7,
    A = 9,
    B = 11
}

local NOTE_INTS = {
    'C',
    'C#',
    'D',
    'D#',
    'E',
    'F',
    'F#',
    'G',
    'G#',
    'A',
    'A#',
    'B'
}

local PYTHAG_RATIOS = { -- http://en.wikipedia.org/wiki/Pythagorean_tuning
    1,
    256/243,
    9/8, -- M2
    32/27,
    81/64, -- M3
    4/3, -- P4
    729/512, -- A4
    3/2, -- P5
    128/81,
    27/16, -- M6
    16/9,
    243/128, -- M7
}

local INTERVALS = {
    0, --Unison
    2, --M2
    4, --M3
    5, --P4
    7, --P5
    9, --M6
    11 --M7
}

local INTERVALMODS = {
    d = -1,
    A = 1,
    m = -1,
    M = 0,
    P = 0
}

function music.pitchRatio(semitones,temperment)
    if temperment == "equal" or temperment == nil then
        return(EQUAL_PITCHMOD^semitones)
    elseif temperment == "pythagorean" then
        local octave = 2^math.floor(semitones / 12)
        semitones = semitones % 12
        local ratio = PYTHAG_RATIOS[semitones+1]*octave
        return(ratio)
    end
end

function music.midiToFrequency(mn,temperment,bfreq,bnote)
    if bnote == nil then
        bnote = 69
    -- else
        -- bnote = bnote
    end
    if bfreq == nil then
        bfreq = 440
    end
    local pchange = mn-bnote
    return bfreq*music.pitchRatio(pchange,temperment)
end

function music.noteToInt(note)
    local basenote = note:sub(0,1)
    local modifications = note:sub(2)

    assert(NOTES[basenote] ~= nil,"Invalid note name: "..note)

    local notenum = NOTES[basenote]

    modifications:gsub(".", function(c)
        if c == "#" then
            notenum = notenum + 1
        elseif c == "b" then
            notenum = notenum - 1
        end
        end)

    if notenum < 0 then
        notenum = notenum + 12
    elseif notenum > 11 then
        notenum = notenum - 12
    end

    return(notenum)
end

function music.intToNote(note)
    note = math.floor(note % 12) -- Idiot proofing.
    return NOTE_INTS[note+1]
end

function music.normalizeNoteName(note)
    return(music.intToNote(music.noteToInt(note)))
end

function music.interval(interval)
    if interval == "U" then return 0 end -- Unisons!

    local mod, baseint = interval:match("(%a)(%d*)")
    baseint = tonumber(baseint)
    assert(INTERVALMODS[mod] and baseint, "Invalid interval: "..interval)

    local octave = math.floor(baseint / 8)
    baseint = baseint == 0 and 1 or baseint % 8

    return INTERVALS[baseint]+INTERVALMODS[mod]+(12*octave)
end

local function wrapIndex(i,t) -- Wraps a index t
    return ((i-1)%#t)+1
end

local function invertChord(t,count)
    while count > 0 do
        local le = table.remove(t,#t)
        table.insert(t,1,le-12)
        count = count-1
    end
    return t
end

function music.diatonicChord(root,scale,ctype,inversion)
    assert(root~=0,"Root must not be zero.")
    if ctype == nil then ctype = "triad" end
    if inversion == nil then inversion = 0 end
    local chord = {}

    local nexttone = root

    table.insert(chord,scale[wrapIndex(nexttone,scale)]+(12*math.floor(nexttone / 8)))
    nexttone = wrapIndex(nexttone + 2,scale)
    table.insert(chord,scale[wrapIndex(nexttone,scale)]+(12*math.floor(nexttone / 8)))
    nexttone = wrapIndex(nexttone + 2,scale)
    table.insert(chord,scale[wrapIndex(nexttone,scale)]+(12*math.floor(nexttone / 8)))

    if ctype == "7" then
        nexttone = wrapIndex(nexttone + 2,scale)
        table.insert(chord,scale[nexttone])
    end

    invertChord(chord,inversion)

    return chord
end

function music.chord(note,chord)
    local root
    if type(note) == "string" then
        root = music.noteToInt(note)
    else
        root = key
    end

    local retchord = {}
    for _,v in ipairs(chord) do
        local int
        if type(v) == "string" then
            int = music.interval(v)
        else
            int = v
        end
        table.insert(retchord,root+int)
    end

    return retchord
end

function music.scale(key,scale)
    local tonic
    if type(key) == "string" then
        tonic = music.noteToInt(key)
    else
        tonic = key
    end

    local retscale = {tonic}
    for _,v in ipairs(scale) do
        tonic = tonic + v
        if tonic > 11 then tonic = tonic - 12 end
        table.insert(retscale,tonic)
    end

    return retscale
end

return music
