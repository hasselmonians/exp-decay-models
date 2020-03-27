x = xolotl;

x.add('compartment', 'comp', 'Cm', 10, 'A', 1, 'vol', 1, 'Ca_out', 2e3);

x.comp.add('buchholtz/CalciumMech', 'Ca_in', 0.24, 'tau_Ca', 5, 'phi', 1);

x.comp.add('soplata/NaV', 'gbar', 900, 'E', 50);
x.comp.add('soplata/Kd', 'gbar', 100, 'E', -100);
x.comp.add('soplata/CaT', 'gbar', 20, 'E', 30);
x.comp.add('Leak', 'gbar', 0.1, 'E', -70);
