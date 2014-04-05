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

music = {}

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

local pitchmod = 2.0^(1/12)

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

function music.pitchRatio(semitones)
    return(pitchmod^semitones)
end

function music.midiToFrequency(mn,afreq)
    local a = 69
    if afreq == nil then
        afreq = 440
    end
    local pchange = mn-69
    return afreq*music.pitchRatio(pchange)
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
    note = math.floor(note) -- Idiot proofing.
    while note > 11 do
        note = note - 12
    end
    while note < 0 do
        note = note + 12
    end

    return NOTE_INTS[note+1]
end

function music.normalizeNoteName(note)
    return(music.intAsNote(music.noteAsInt(note)))
end

function music.interval(interval)
    if interval == "U" then return 0 end -- Unisons!

    local mod = interval:sub(0,1)
    local baseint = tonumber(interval:sub(2))
    assert(INTERVALMODS[mod] ~= nil and mod ~= "" and baseint ~= nil, "Invalid interval: "..interval)

    local octave = 0
    while baseint > 7 do
        baseint = baseint - 8
        octave = octave+1
    end
    if baseint == 0 then
        baseint = 1
    end

    return INTERVALS[baseint]+INTERVALMODS[mod]+(12*octave)
end

function music.chord(note,chord)
    local root
    if type(note) == "string" then
        root = music.noteAsInt(note)
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
        tonic = music.noteAsInt(key)
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
