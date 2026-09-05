import("stdfaust.lib");

// 1. Basic Sequence (:) - Oscillator to filter
ex1 = os.sawtooth(440) : fi.lowpass(2, 800);

// Change the number below to test different examples (1 to 7)
process = ex1;
