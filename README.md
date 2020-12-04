# yuliya_microgridinterface

Code for GreenTech submission "Trust-based User Interface for Islanded Alternating Current Microgrids"

1. Microgrid_MG folder - original microgrid model is given in Microgrid_Original.m, and the microgrid model where we removed the pole at the origin is given in Microgrid_reduce.m
2. Use A matrix (labeled as NEW_Amg.mat) from Micogrid_reduce.m and Bmg_phase saved in ReducedDynamcis folder for next step
3. ReducedDynamics folder - SSorderng.m uses NEW_Amg.mat and Bmg_phase for reduced model dynamics (labeled A_0 and B_0)
4. cases folder - load A_0 and B_0 into IEEE118_1.m
5. Run runall.m for results
