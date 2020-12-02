# yuliya_microgridinterface

Code for GreenTech submission "Trust-based User Interface for Islanded Alternating Current Microgrids"

1. Microgrid_MG folder - original microgrid dynamics (Microgrid_Original.m), and dynamics with first state removed (Microgrid_reduce.m)
2. Use NEW_Amg.mat from Micogrid_reduce.m and Bmg_phase for next step
3. ReducedDynamics folder - SSorderng.m produces reduced order model dynamics (A_0 and B_0)
4. cases folder - load A_0 and B_0 in IEEE118_1.m
4. Run runall.m for results
