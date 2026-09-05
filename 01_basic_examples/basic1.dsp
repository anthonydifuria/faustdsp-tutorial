import("stdfaust.lib");

// 1. Basic Sequence (:) - Oscillator to filter
ex1 = os.sawtooth(440) : fi.lowpass(2, 800);

// 2. Split and Merge (<:, :, :>) - Noise to two filters, then summed
ex2 = no.noise <: fi.lowpass(2, 500), fi.highpass(2, 2000) :> ba.add;

// 3. The Blackhole (_) - Discarding a signal branch
ex3 = os.osc(440) : fi.lowpass(2, 1000), _;

// 4. Sequence Macro (seq) - 4 cascaded lowpass filters
ex4 = os.sawtooth(440) : seq(1, 4, fi.lowpass(2, 1000));

// 5. Parallel Macro (par) - 5 detuned oscillators summed
ex5 = par(1, 5, os.sawtooth(440 + 2*i)) : ba.addn(5);

// 6. Complex Routing - Split into 3 different branches, then merge
ex6 = os.square(220) <: fi.lowpass(2, 300), fi.highpass(2, 1500), os.sawtooth(110) :> ba.addn(3);

// 7. Nested Macros - 3 parallel voices, each with 2 cascaded filters
ex7 = par(1, 3, os.sawtooth(220 + 50*i) : seq(1, 2, fi.lowpass(2, 800))) : ba.addn(3);

// Change the number below to test different examples (1 to 7)
process = ex1;