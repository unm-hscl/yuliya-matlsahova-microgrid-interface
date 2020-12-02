clc
clear all
%%%--------Parameters values--------------
fs=8000;
Lf1=1.35*10^-3;Lf2=Lf1;Lf3=Lf1;
Cf1=50*10^-6;Cf2=Cf1;Cf3=Cf1;
rLf1=.1;rLf2=rLf1;rLf3=rLf1;
Lc1=.35*10^-3;Lc2=Lc1;Lc3=Lc1;
rLc1=.03;rLc2=rLc1;rLc3=rLc1;
wc1=31.41;wc2=wc1;wc3=wc1;
mp1=9.4*10^-5;mp2=mp1;mp3=mp1;
nq1=1.3*10^-4;nq2=nq1;nq3=nq1;
Kpv1=.05;Kpv2=Kpv1;Kpv3=Kpv1;
Kiv1=390;Kiv2=Kiv1;Kiv3=Kiv1;
Kpc1=10.5;Kpc2=Kpc1;Kpc3=Kpc1;
Kic1=16*10^3;Kic2=Kic1;Kic3=Kic1;
F1=.75;F2=F1;F3=F1;
rN=1000;
wn=314;
%-----Network Data-------
rline1=.23;Lline1=.1/(2*pi*50);
rline2=.35;Lline2=.58/(2*pi*50);
Rload1=25;Lload1=1e-5;
Rload2=20;Lload2=1e-5;
%%%--------Initial operating point--------
Vd0_1=380.8;Vd0_2=381.8;Vd0_3=380.4;
Vq0_1=0;Vq0_2=0;Vq0_3=0;
Id0_1=11.4;Id0_2=Id0_1;Id0_3=Id0_1;
Iq0_1=.4;Iq0_2=-1.45;Iq0_3=1.25;
Ild_1=11.4;Ild_2=11.4;Ild_3=11.4;
Ilq_1=-5.5;Ilq_2=-7.3;Ilq_3=-4.6;
VbD_1=379.5;VbD_2=380.5;VbD_3=379;
VbQ_1=-6;VbQ_2=-6;VbQ_3=-5;
w0_1=314;w0_2=w0_1;w0_3=w0_1;w0=w0_1;
delta1_0=0;delta2_0=1.9*10^-3;delta3_0=-.0113;
Iline1d=-3.8;Iline1q=.4;
Iline2d=7.6;Iline2q=-1.3;
IloadD_1=Id0_1-Iline1d;IloadQ_1=Iq0_1-Iline1q;
IloadD_2=Id0_3+Iline2d;IloadQ_2=Iq0_3+Iline2q;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%----------------DG1------------
Ap_1=[0 -mp1 0; 0 -wc1 0; 0 0 -wc1];
Bpwcom_1=[-1;0;0];
Bp_1=[0 0 0 0 0 0 ;0 0 wc1*Id0_1 wc1*Iq0_1 wc1*Vd0_1 wc1*Vq0_1;0 0  wc1*Iq0_1 -wc1*Id0_1 -wc1*Vq0_1 wc1*Vd0_1];
Cpw_1=[0 -mp1 0];Cpv_1=[0 0 -nq1;0 0 0];
Bv1_1=[1 0;0 1];Bv2_1=[0 0 -1 0 0 0;0 0 0 -1 0 0];
Cv_1=[Kiv1 0; 0 Kiv1];
Dv1_1=[Kpv1 0; 0 Kpv1];
Dv2_1=[0 0 -Kpv1 -w0*Cf1 F1 0;0 0 w0*Cf1 -Kpv1 0 F1];
Bc1_1=[1 0;0 1];
Bc2_1=[-1 0 0 0 0 0;0 -1 0 0 0 0 ];
Cc_1=[Kic1 0;0 Kic1];
Dc1_1=[Kpc1 0; 0 Kpc1];
Dc2_1=[-Kpc1 -w0*Lf1 0 0 0 0;w0*Lf1 -Kpc1 0 0 0 0];
ALCL_1=[-rLf1/Lf1 w0_1 -1/Lf1 0 0 0
    -w0_1 -rLf1/Lf1 0 -1/Lf1 0 0
    1/Cf1 0 0 w0_1 -1/Cf1 0
    0 1/Cf1 -w0_1 0 0 -1/Cf1 
    0 0 1/Lc1 0 -rLc1/Lc1 w0_1
    0 0 0 1/Lc1 -w0_1 -rLc1/Lc1];
BLCL1_1=[1/Lf1 0 0 0 0 0 ; 0 1/Lf1 0 0 0 0]';
BLCL2_1=[0 0 0 0 -1/Lc1 0; 0 0 0 0 0 -1/Lc1]';
BLCL3_1=[Ilq_1 -Ild_1 Vq0_1 -Vd0_1 Iq0_1 -Id0_1]';
Ts_1=[cos(delta1_0) -sin(delta1_0);sin(delta1_0) cos(delta1_0)];
Tc_1=[(-Id0_1*sin(delta1_0))-(Iq0_1*cos(delta1_0));(Id0_1*cos(delta1_0))-(Iq0_1*sin(delta1_0))];
Tvinv_1=[-VbD_1*sin(delta1_0)+VbQ_1*cos(delta1_0);-VbD_1*cos(delta1_0)-VbQ_1*sin(delta1_0)];
%------------------------
AINV_1=[Ap_1                                                         zeros(3,2)         zeros(3,2)              Bp_1
        Bv1_1*Cpv_1                                                  zeros(2,2)         zeros(2,2)              Bv2_1
        Bc1_1*Dv1_1*Cpv_1                                            Bc1_1*Cv_1         zeros(2,2)         (Bc1_1*Dv2_1)+Bc2_1
        (BLCL1_1*Dc1_1*Dv1_1*Cpv_1)+(BLCL2_1*[Tvinv_1 zeros(2,1) zeros(2,1)])+(BLCL3_1*Cpw_1)  BLCL1_1*Dc1_1*Cv_1  BLCL1_1*Cc_1  ALCL_1+BLCL1_1*((Dc1_1*Dv2_1)+Dc2_1)];
BINV_1=[zeros(3,2);zeros(2,2);zeros(2,2);BLCL2_1*inv(Ts_1)];
Bwcom_1=[Bpwcom_1;zeros(2,1);zeros(2,1);zeros(6,1)];
CINVw_1=[Cpw_1 zeros(1,2) zeros(1,2) zeros(1,6)];
CINVc_1=[Tc_1 zeros(2,2) zeros(2,1) zeros(2,5) zeros(2,1) zeros(2,1) Ts_1];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%------------------DG2----------------------
Ap_2=[0 -mp2 0; 0 -wc2 0; 0 0 -wc2];
Bpwcom_2=[-1;0;0];
Bp_2=[0 0 0 0 0 0 ;0 0 wc2*Id0_2 wc2*Iq0_2 wc2*Vd0_2 wc2*Vq0_2;0 0  wc2*Iq0_2 -wc2*Id0_2 -wc2*Vq0_2 wc2*Vd0_2];
Cpw_2=[0 -mp2 0];Cpv_2=[0 0 -nq2;0 0 0];
Bv1_2=[1 0;0 1];Bv2_2=[0 0 -1 0 0 0;0 0 0 -1 0 0];
Cv_2=[Kiv2 0; 0 Kiv2];
Dv1_2=[Kpv2 0; 0 Kpv2];
Dv2_2=[0 0 -Kpv2 -wn*Cf2 F2 0;0 0 wn*Cf2 -Kpv2 0 F2];
Bc1_2=[1 0;0 1];
Bc2_2=[-1 0 0 0 0 0;0 -1 0 0 0 0 ];
Cc_2=[Kic2 0;0 Kic2];
Dc1_2=[Kpc2 0; 0 Kpc2];
Dc2_2=[-Kpc2 -wn*Lf2 0 0 0 0;wn*Lf2 -Kpc2 0 0 0 0];
ALCL_2=[-rLf2/Lf2 w0_2 -1/Lf2 0 0 0
    -w0_2 -rLf2/Lf2 0 -1/Lf2 0 0
    1/Cf2 0 0 w0_2 -1/Cf2 0
    0 1/Cf2 -w0_2 0 0 -1/Cf2 
    0 0 1/Lc2 0 -rLc2/Lc2 w0_2
    0 0 0 1/Lc2 -w0_2 -rLc2/Lc2 ];
BLCL1_2=[1/Lf2 0 0 0 0 0 ; 0 1/Lf2 0 0 0 0]';
BLCL2_2=[0 0 0 0 -1/Lc2 0; 0 0 0 0 0 -1/Lc2]';
BLCL3_2=[Ilq_2 -Ild_2 Vq0_2 -Vd0_2 Iq0_2 -Id0_2]';
Ts_2=[cos(delta2_0) -sin(delta2_0);sin(delta2_0) cos(delta2_0)];
Tc_2=[(-Id0_2*sin(delta2_0))-(Iq0_2*cos(delta2_0));(Id0_2*cos(delta2_0))-(Iq0_2*sin(delta2_0))];
Tvinv_2=[-VbD_2*sin(delta2_0)+VbQ_2*cos(delta2_0);-VbD_2*cos(delta2_0)-VbQ_2*sin(delta2_0)];
%------------------------
AINV_2=[Ap_2                                                         zeros(3,2)         zeros(3,2)              Bp_2
        Bv1_2*Cpv_2                                                  zeros(2,2)         zeros(2,2)              Bv2_2
        Bc1_2*Dv1_2*Cpv_2                                            Bc1_2*Cv_2         zeros(2,2)         (Bc1_2*Dv2_2)+Bc2_2
        (BLCL1_2*Dc1_2*Dv1_2*Cpv_2)+(BLCL2_2*[Tvinv_2 zeros(2,1) zeros(2,1)])+(BLCL3_2*Cpw_2)  BLCL1_2*Dc1_2*Cv_2  BLCL1_2*Cc_2  ALCL_2+BLCL1_2*((Dc1_2*Dv2_2)+Dc2_2)];
BINV_2=[zeros(3,2);zeros(2,2);zeros(2,2);BLCL2_2*inv(Ts_2)];
Bwcom_2=[Bpwcom_2;zeros(2,1);zeros(2,1);zeros(6,1)];
CINVw_2=[zeros(1,3) zeros(1,2) zeros(1,2) zeros(1,6)];
CINVc_2=[Tc_2 zeros(2,2) zeros(2,1) zeros(2,5) zeros(2,1) zeros(2,1) Ts_2];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%------------------DG3----------------------
Ap_3=[0 -mp3 0; 0 -wc3 0; 0 0 -wc3];
Bpwcom_3=[-1;0;0];
Bp_3=[0 0 0 0 0 0 ;0 0 wc3*Id0_3 wc3*Iq0_3 wc3*Vd0_3 wc3*Vq0_3;0 0  wc3*Iq0_3 -wc3*Id0_3 -wc3*Vq0_3 wc3*Vd0_3];
Cpw_3=[0 -mp3 0];Cpv_3=[0 0 -nq3;0 0 0];
Bv1_3=[1 0;0 1];Bv2_3=[0 0 -1 0 0 0;0 0 0 -1 0 0];
Cv_3=[Kiv3 0; 0 Kiv3];
Dv1_3=[Kpv3 0; 0 Kpv3];
Dv2_3=[0 0 -Kpv3 -wn*Cf3 F3 0;0 0 wn*Cf3 -Kpv3 0 F3];
Bc1_3=[1 0;0 1];
Bc2_3=[-1 0 0 0 0 0;0 -1 0 0 0 0 ];
Cc_3=[Kic3 0;0 Kic3];
Dc1_3=[Kpc3 0; 0 Kpc3];
Dc2_3=[-Kpc3 -wn*Lf3 0 0 0 0;wn*Lf3 -Kpc3 0 0 0 0];
ALCL_3=[-rLf3/Lf3 w0_3 -1/Lf3 0 0 0
    -w0_3 -rLf3/Lf3 0 -1/Lf3 0 0
    1/Cf3 0 0 w0_3 -1/Cf3 0
    0 1/Cf3 -w0_3 0 0 -1/Cf3 
    0 0 1/Lc3 0 -rLc3/Lc3 w0_3
    0 0 0 1/Lc3 -w0_3 -rLc3/Lc3 ];
BLCL1_3=[1/Lf3 0 0 0 0 0 ; 0 1/Lf3 0 0 0 0]';
BLCL2_3=[0 0 0 0 -1/Lc3 0; 0 0 0 0 0 -1/Lc3]';
BLCL3_3=[Ilq_3 -Ild_3 Vq0_3 -Vd0_3 Iq0_3 -Id0_3]';
Ts_3=[cos(delta3_0) -sin(delta3_0);sin(delta3_0) cos(delta3_0)];
Tc_3=[(-Id0_3*sin(delta3_0))-(Iq0_3*cos(delta3_0));(Id0_3*cos(delta3_0))-(Iq0_3*sin(delta3_0))];
Tvinv_3=[-VbD_3*sin(delta3_0)+VbQ_3*cos(delta3_0);-VbD_3*cos(delta3_0)-VbQ_3*sin(delta3_0)];
%------------------------
AINV_3=[Ap_3                                                         zeros(3,2)         zeros(3,2)              Bp_3
        Bv1_3*Cpv_3                                                  zeros(2,2)         zeros(2,2)              Bv2_3
        Bc1_3*Dv1_3*Cpv_3                                            Bc1_3*Cv_3         zeros(2,2)         (Bc1_3*Dv2_3)+Bc2_3
        (BLCL1_3*Dc1_3*Dv1_3*Cpv_3)+(BLCL2_3*[Tvinv_3 zeros(2,1) zeros(2,1)])+(BLCL3_3*Cpw_3)  BLCL1_3*Dc1_3*Cv_3  BLCL1_3*Cc_3  ALCL_3+BLCL1_3*((Dc1_3*Dv2_3)+Dc2_3)];
 
BINV_3=[zeros(3,2);zeros(2,2);zeros(2,2);BLCL2_3*inv(Ts_3)];
Bwcom_3=[Bpwcom_3;zeros(2,1);zeros(2,1);zeros(6,1)];
CINVw_3=[zeros(1,3) zeros(1,2) zeros(1,2) zeros(1,6)];
CINVc_3=[Tc_3 zeros(2,2) zeros(2,1) zeros(2,5) zeros(2,1) zeros(2,1) Ts_3];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%-----------Combination of Inverter Models------------
AINV=[AINV_1+Bwcom_1*CINVw_1    zeros(13,13)             zeros(13,13)
        Bwcom_2*CINVw_1         AINV_2                   zeros(13,13)
        Bwcom_3*CINVw_1            zeros(13,13)             AINV_3  ];

%AINV(14,2)=9.4e-5;AINV(27,2)=9.4e-5;

BINV=[BINV_1 zeros(13,2) zeros(13,2);zeros(13,2) BINV_2 zeros(13,2);zeros(13,2) zeros(13,2) BINV_3];%---Modified by myself
CINVw=[  CINVw_1      CINVw_2     CINVw_3];%---written by myself
CINVc=[  CINVc_1    zeros(2,13)  zeros(2,13)
       zeros(2,13)   CINVc_2     zeros(2,13)
       zeros(2,13)  zeros(2,13)   CINVc_3];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%-----------Network Model------------------
ANET_1=[-rline1/Lline1 w0;-w0 -rline1/Lline1];
B1NET_1=[1/Lline1 0 -1/Lline1 0 0 0 ;0 1/Lline1 0 -1/Lline1 0 0];
B2NET_1=[Iline1q;-Iline1d];
%---------
ANET_2=[-rline2/Lline2 w0;-w0 -rline2/Lline2];
B1NET_2=[0 0 1/Lline2 0 -1/Lline2 0;0 0 0 1/Lline2 0 -1/Lline2];
B2NET_2=[Iline2q;-Iline2d];
%%----------
ANET=[ANET_1 zeros(2,2);zeros(2,2) ANET_2];
B1NET=[B1NET_1;B1NET_2];
B2NET=[B2NET_1;B2NET_2];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%-----------Load Model------------------
Aload_1=[-Rload1/Lload1 w0;-w0 -Rload1/Lload1];
B1load_1=[1/Lload1 0 0 0 0 0;0 1/Lload1 0 0 0 0];
B2load_1=[IloadQ_1;-IloadD_1];
%-------
Aload_2=[-Rload2/Lload2 w0;-w0 -Rload2/Lload2];
B1load_2=[0 0 0 0 1/Lload2 0;0 0 0 0 0 1/Lload2];
B2load_2=[IloadQ_2;-IloadD_2];
%------
Aload=[Aload_1 zeros(2,2);zeros(2,2) Aload_2];
B1load=[B1load_1;B1load_2];
B2load=[B2load_1;B2load_2];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%----------------------Complete Microgrid Model--------
rr=[rN rN rN rN rN rN];RN=diag(rr);
MINV=[eye(6,6)];%???
Mload=[-1 0 0 0;0 -1 0 0;zeros(2,4);0 0 -1 0;0 0 0 -1 ];
MNET=[-1 0 0 0;0 -1 0 0;1 0 -1 0 ;0 1 0 -1 ;0 0 1 0;0 0 0 1];%???
%----------------
Amg=[      AINV+(BINV*RN*MINV*CINVc)               BINV*RN*MNET            BINV*RN*Mload
      (B1NET*RN*MINV*CINVc)+(B2NET*CINVw)       ANET+(B1NET*RN*MNET)      B1NET*RN*Mload
      (B1load*RN*MINV*CINVc)+(B2load*CINVw)       B1load*RN*MNET      Aload+(B1load*RN*Mload) ];
Amg=Amg(2:47,2:47);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-----------Dynamic Analysis----------------
sss=length(Amg);
% det(lambda*eye(ss,ss)-Amg)
format('short','g');
ev=eig(Amg)
plot(ev,'x','MarkerSize',10,'color','blue')
xlim([-4000 3]);ylim([-8000 8000]);
grid on
for i=1:sss
damp(i)=-real(ev(i))/abs(ev(i));
end
for i=1:sss
freq_osc(i)=abs(imag(ev(i)))/(2*pi);
end
[phi,DD]=eig(Amg);
phi;           %Right eigen-vector
sai=inv(phi);  %Left  eigen-vector
%-----Participation Matrix-------
for j=1:sss
    for i=1:sss
        pp(i,j)=phi(i,j)*sai(j,i);
    end
end
PP=abs(pp);
for i=1:sss
    for j=1:sss
        P(i,j)=PP(i,j)/max(PP(i,:));
    end
end
% xlswrite('green.xlsx',P,'Sheet1','B2')
% xlswrite('green.xlsx',real(ev),'Sheet2','A1')
% xlswrite('green.xlsx',imag(ev),'Sheet2','B1')