# yuliya_microgridinterface

Code for GreenTech submission "Trust-based User Interface for Islanded Alternating Current Microgrids"

1. In folder "MG_Model" - original dynamcis (Microgrid_Original.m) provided,  along with dynamics where first state is removed (Microgrid_reduce.m).
2. In folder "ReducedDynamics" - SSordering.m produces reduced order model used in optimization (A_0 and B_0)
3. Load reduced dynamcis in "IEEE118_1.m"
4. Run "runall.m" for results.
