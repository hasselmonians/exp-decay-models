# exp-decay-models
find conductance-based models that satisfy exponential decay in firing rate

**Firing rate** is defined as the instantaneous estimate of the number of spikes per unit time
(usually measured in Hertz).
**Gain** is the instantaneous change in firing rate over time
(the derivative of firing rate with respect to time).
A cell is **tonically-firing** when its firing rate is near-constant
for a constant injected current.

We are looking for model cells with the following property:

When moving between two tonically-firing regimes,
the firing rate increases or decreases at an exponential rate.
Thus, we are interested in transition-state dynamics
between two steady-state tonically-firing regimes.

Cells that meet this criterion must then have a dynamic range of possible
firing rates in tonic-firing regimes.
We are not necessarily concerned with cells that are type I excitable
with near-linear F-I characteristics, but this might be a reasonable place to start.

A reasonable first step then would be to identify model cells
with the following properties:

* They are single-compartment cells.
* They have a minimal number of conductances.
* They are biologically-plausible thalamocortical or hippocampal cells.
* Their F-I characteristic is continuous, monotonically-increasing,
and has a sufficient dynamic range (e.g. is not flat).

With this subset of models, we should identify models
which exponentially increase in firing rate during transition periods.
