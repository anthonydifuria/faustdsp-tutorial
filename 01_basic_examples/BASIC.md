# Chapter 1: Signal Flow (Routing, Sequences, and Parallelism)

In Faust, you don't write step-by-step "instructions" like in other languages. You describe a **block diagram**. 
The golden rule of Faust is: **the signal always flows from left to right**.

In this chapter, we will look at the three fundamental concepts for "wiring" our blocks: the **Sequence**, the **Split/Merge** (Parallelism), and the keywords **`seq`** and **`par`**.

---

## 1. The Sequence: The `:` Operator

The most important operator in Faust is the colon `:`. It means "connect the output of what is on the left to the input of what is on the right".

**Syntax:**
```faust
process = Block_A : Block_B;
```

**Practical Example:**
Let's generate a sawtooth wave and pass it through a lowpass filter.
```faust
import("stdfaust.lib");

process = os.sawtooth(440) : fi.lowpass(2, 800);
```
*Note: If you look at the Block Diagram in the IDE, you will see an arrow going from the oscillator to the filter.*

---

## 2. Parallelism: Split `<:` and Merge `:>`

What happens if I want to send the same signal to two different filters at the same time? Or if I want to combine two signals into one?

- **`<:` (Split / Distributor)**: Takes a signal and duplicates it into multiple copies.
- **`:>` (Merge / Collector)**: Takes multiple signals and combines them (summing them, if they are audio type).
- **`,` (Comma)**: Used to separate parallel branches.

**Syntax:**
```faust
process = Source <: Branch_1 , Branch_2 :> Destination;
```

**Practical Example:**
Let's take white noise, split it into two filters (one lowpass and one highpass), and then recombine them.
```faust
import("stdfaust.lib");

process = no.noise 
    <: fi.lowpass(2, 500) , fi.highpass(2, 2000) 
    :> ba.add; 
```
*(Note: `ba.add` is a block that sums the two inputs. In many cases, the `:>` operator itself before a single-input block will perform the sum, but using `ba.add` or an explicit mixer is good practice for clarity).*

---

## 3. The Keywords `seq` and `par`

The operators `:` and `<:/,:>` are the foundation, but Faust offers "macros" (keywords) to make the code more readable when repeating patterns.

### The `seq` function
Used to apply the same block in sequence `N` times.
**Syntax:** `seq(x, n, process)`
- `x`: number of inputs/outputs of the block (usually 1 for audio).
- `n`: how many times to repeat the block.
- `process`: the block to repeat.

**Example:**
Imagine you want to pass the signal through 4 identical lowpass filters in cascade (to get a steeper filter).
```faust
import("stdfaust.lib");

// Instead of writing: filter : filter : filter : filter
// We use seq:
process = os.sawtooth(440) : seq(1, 4, fi.lowpass(2, 1000));
```

### The `par` function
Used to apply the same block in parallel `N` times.
**Syntax:** `par(x, n, process)`

**Example:**
Let's create a "super-oscillator" that sums 5 identical oscillators but with slightly different frequencies (Detune/Chorus effect).
```faust
import("stdfaust.lib");

// par creates 5 parallel branches. 
// We use ba.addn(5) at the end to sum them all.
process = par(1, 5, os.sawtooth(440 + 2)) : ba.addn(5);
```

---

## 4. The Blackhole: `_`

Sometimes, in a parallel setup, you might want to "throw away" a signal or ignore an output. In Faust, you use the underscore `_` (the blackhole).

**Example:**
Take a stereo signal and keep only the left channel.
```faust
import("stdfaust.lib");

// Conceptual example of discarding a channel
process = stereo_source <: _, _;
```

*A more realistic example: I take a signal, send it to a filter, but the filter's output has a latency parameter or a second channel I don't care about:*
```faust
import("stdfaust.lib");

process = no.noise : fi.lowpass(2, 1000) , _;
```

---

## 📝 Quick Cheatsheet

| Operator / Keyword | Name | Description |
| :--- | :--- | :--- |
| `:` | Sequence | Connects the output of A to the input of B. |
| `<:` | Split | Divides a signal into multiple branches. |
| `:>` | Merge | Combines multiple branches into a single signal. |
| `,` | Parallel | Separates parallel branches between split and merge. |
| `_` | Blackhole | Discards a signal or ignores an output. |
| `seq(x,n,P)` | Sequence Macro | Applies process `P` in cascade `n` times. |
| `par(x,n,P)` | Parallel Macro | Applies process `P` in parallel `n` times. |

---

