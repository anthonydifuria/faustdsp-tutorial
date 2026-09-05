# Faust Routing Examples

This file contains multiple examples of the `process` definition, demonstrating the use of all basic routing operators: `:`, `<:`, `:>`, `,`, `_`, `seq`, and `par`.

You can copy and paste each `process` block individually into the [Faust Web IDE](https://faustide.grame.fr/) to test them.

---

## 1. Basic Sequence (`:`)
A simple chain: oscillator -> filter -> output.

```faust
import("stdfaust.lib");

process = os.sawtooth(440) : fi.lowpass(2, 800);
```

---

## 2. Split and Merge (`<:`, `,`, `:>` )
Splitting a noise source into two different filters and merging them back.

```faust
import("stdfaust.lib");

process = no.noise 
    <: fi.lowpass(2, 500) , fi.highpass(2, 2000) 
    :> ba.add;
```

---

## 3. The Blackhole (`_`)
Discarding the right channel of a stereo signal, keeping only the left.

```faust
import("stdfaust.lib");

// Assuming a stereo source (e.g., from a demo or file player)
// We split it, keep the left, and throw away the right.
process = _ <: _, _; 
```

---

## 4. Sequence Macro (`seq`)
Applying the same lowpass filter 4 times in cascade to create a steeper filter slope.

```faust
import("stdfaust.lib");

process = os.sawtooth(440) : seq(1, 4, fi.lowpass(2, 1000));
```

---

## 5. Parallel Macro (`par`)
Creating 5 parallel sawtooth oscillators and summing them up.

```faust
import("stdfaust.lib");

process = par(1, 5, os.sawtooth(440)) : ba.addn(5);
```

---

## 6. Complex Routing (Combining operators)
Splitting a signal into 3 parallel branches, applying a different effect to each, and merging them.

```faust
import("stdfaust.lib");

process = os.square(220) 
    <: fi.lowpass(2, 300) 
    ,  fi.highpass(2, 1500) 
    ,  os.sawtooth(110) 
    :> ba.addn(3);
```

---

## 7. Discarding an output with Blackhole (`_`) in a parallel context
Generating a stereo signal but only outputting the left channel.

```faust
import("stdfaust.lib");

// os.osc outputs 1 channel. Let's force a split to 2, then blackhole the second.
process = os.osc(440) <: _, _;
```

---

## 8. Nested Sequences and Parallels
Using `par` to create 3 voices, and `seq` to apply a filter chain to each voice.

```faust
import("stdfaust.lib");

// 3 parallel oscillators, each passing through 2 cascaded lowpass filters.
process = par(1, 3, os.sawtooth(220 + 50*i) : seq(1, 2, fi.lowpass(2, 800))) : ba.addn(3)
with {
    i = 0; // Note: in a real par macro, 'i' is the iteration index automatically.
};

// Corrected version using the automatic index 'i' of the par macro:
process = par(1, 3, os.sawtooth(220 + 50*i) : seq(1, 2, fi.lowpass(2, 800))) : ba.addn(3);
```