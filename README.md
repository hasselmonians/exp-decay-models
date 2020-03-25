# exp-decay-models
find conductance-based models that satisfy exponential decay in firing rate

## Definitions

**Firing rate** is defined as the instantaneous estimate of the number of spikes per unit time
(usually measured in Hertz).
**Gain** is the instantaneous change in firing rate over time
(the derivative of firing rate with respect to time).
A cell is **tonically-firing** when its firing rate is near-constant
for a constant injected current.

## Targets

We are looking for model cells with the following property:

> When moving between two tonically-firing regimes,
the firing rate increases or decreases at an exponential rate.
Thus, we are interested in transition-state dynamics
between two steady-state tonically-firing regimes.

Cells that meet this criterion must then have a dynamic range of possible
firing rates in tonic-firing regimes.
We are not necessarily concerned with cells that are type I excitable
with near-linear F-I characteristics, but that might be a reasonable place to start.

### First-Pass

A reasonable first step then would be to identify model cells
with the following properties:

1. They are single-compartment cells.
2. They have a minimal number of conductances.
3. They are biologically-plausible thalamocortical or hippocampal cells.
4. Their F-I characteristic is continuous, monotonically-increasing,
and has a sufficient dynamic range (i.e. is not flat).

With regard to (1), (2), and (3),
[Dextexhe *et al.* 1994](https://www.ncbi.nlm.nih.gov/pubmed/7527077),
[Traub *et al.* 1991](https://www.researchgate.net/publication/21491281_A_Model_of_CA3_Hippocampal_Pyramidal_Neuron_Incorporating_Voltage-Clamp_Data_on_Intrinsic_Conductances),
[Giovannini *et al.* 2015](https://hal.archives-ouvertes.fr/hal-01426362/file/Giovannini-ICAN-Hippocampus_submittedRev.pdf),
[Jochems & Yoshida 2015](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4406621/),
and [Soplata *et al.* 2017](https://www.ncbi.nlm.nih.gov/pubmed/29227992)
are probably good places to start.

### Second-Pass

Within this subset of models, we should identify models
which exponentially increase in firing rate during transition periods.
