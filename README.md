# yuliya_microgridinterface

Code for GreenTech submission "Trust-based User Interface for Islanded Alternating Current Microgrids"

1. Microgrid_MG folder - original microgrid dynamics (Microgrid_Original.m), and dynamics where first state is removed (Microgrid_reduce.m)
2. Use A matrix (labeled as NEW_Amg.mat) from Micogrid_reduce.m and Bmg_phase for next step
3. ReducedDynamics folder - SSorderng.m uses NEW_Amg.mat and Bmg_phase to produce reduced model dynamics (labeled as A_0 and B_0)
4. cases folder - load A_0 and B_0 into IEEE118_1.m
5. Run runall.m for results
