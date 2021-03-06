clear all;
close all;
clc;
E0=36;
L1=1.56e-3;
L2=3.24e-3;
R0=50;
R1=0.3;
R2=0.3;
C1=2.2e-3;
C2=2.2e-3;
V0=120;


E0=20;
L1=2.3e-3;
L2=330e-6;
R0=44;
R1=2.134;
R2=0.234;
C1=190e-6;
C2=190e-6;
V0=20;

R11=0.3;
R21=0.3;
syms l1 l2 r1 r2 r0 i1p i1 i2 i2p  E v1p v1 v2p v2 D c1 c2; 

eq1=-l1*i1p+E-i1*r1-(1-D)*(v1+v2)==0;
eq2=-l2*i2p-v1*D+(1-D)*v2-i2*r2==0;
eq3=-c1*v1p+i2*D+i1*(1-D)==0;
eq4=-c2*v2p-v2/r0+(1-D)*(i1-i2)==0;

eq1=subs(eq1,[E l1 l2 c1 c2 r0],[E0 L1 L2 C1 C2 R0 ]);
eq2=subs(eq2,[E l1 l2 c1 c2 r0],[E0 L1 L2 C1 C2 R0 ]);
eq3=subs(eq3,[E l1 l2 c1 c2 r0],[E0 L1 L2 C1 C2 R0 ]);
eq4=subs(eq4,[E l1 l2 c1 c2 r0],[E0 L1 L2 C1 C2 R0 ]);

sol=solve([subs(eq1,i1p,0),subs(eq2,i2p,0),subs(eq3,v1p,0),subs(eq4,v2p,0)],[i1,i2,v1,D]);
sol2=solve([subs(eq1,i1p,0),subs(eq2,i2p,0),subs(eq3,v1p,0),subs(eq4,v2p,0)],[i1,i2,v1,v2]);
sol.i1;
sol.i2;
sol.v1;
sol2.v2;
D_=0:0.001:1;
Vo_=subs(sol2.v2,[D],[D_]);
Vo_1=subs(Vo_,[r1 r2],[R1 R2]);
Vo_2=subs(Vo_,[r1 r2],[R11 R21]);

figure();
plot(D_,Vo_1,D_,Vo_2,D_,(D_.^-1+1).^-1);
ylabel('Voltaje V0(V)');
xlabel('Tiempo(s)');
title('Perdidas Referencia 1 vs Comerciales vs Sin perdidas');
legend('R1=2.1340 R2=0.2340','R1=0.3 R2=0.3','Sin Perdidas');
grid on;

%Eficiencia 
nE=((Vo_1.*Vo_1)/R0)./(subs(subs(sol2.i1,[D],[D_]),[r1 r2],[R1 R2])*E0);

figure();
subplot(2,1,1)
plot(D_,Vo_1);
ylabel('Voltaje Salida(V)');
xlabel('Ciclo util');
title('Voltaje Salida(V) vs Ciclo util');
subplot(2,1,2)
plot(D_,nE)
ylabel('Eficiencia');
xlabel('Ciclo util');
title('Eficiencia vs Ciclo util');

%Ciclo util
d1=double(subs(sol.D(1),[v2 r1 r2],[V0 R1 R2]));
d2=double(subs(sol.D(2),[v2 r1 r2],[V0 R1 R2]));
alpha=min(d1,d2)

%Vc1
Vc1=subs(sol2.v1,[D r1 r2],[alpha R1 R2]);
Vc1=double(subs(Vc1,'D',alpha))

%I1
il1=subs(sol2.i1,[D r1 r2],[alpha R1 R2]);
il1=double(subs(il1,'D',alpha))

%I2
il2=subs(sol2.i2,[D r1 r2],[alpha R1 R2]);
il2=double(subs(il2,'D',alpha))


eq1_=solve(eq1,i1p);
eq2_=solve(eq2,i2p);
eq3_=solve(eq3,v1p);
eq4_=solve(eq4,v2p);

i1p_A=[diff(eq1_,i1) diff(eq1_,i2) diff(eq1_,v1) diff(eq1_,v2)];
i2p_A=[diff(eq2_,i1) diff(eq2_,i2) diff(eq2_,v1) diff(eq2_,v2)];
v1p_A=[diff(eq3_,i1) diff(eq3_,i2) diff(eq3_,v1) diff(eq3_,v2)];
v2p_A=[diff(eq4_,i1) diff(eq4_,i2) diff(eq4_,v1) diff(eq4_,v2)];

i1p_B=[diff(eq1_,D) ];
i2p_B=[diff(eq2_,D) ];
v1p_B=[diff(eq3_,D) ];
v2p_B=[diff(eq4_,D) ];

A=[i1p_A; i2p_A; v1p_A; v2p_A];
B=[i1p_B; i2p_B; v1p_B; v2p_B];
A=[subs(i1p_A,[r1 r2 D],[R1 R2 alpha]); subs(i2p_A,[r1 r2 D],[R1 R2 alpha]);subs(v1p_A,[r1 r2 D],[R1 R2 alpha]) ; ;subs(v2p_A,[r1 r2 D],[R1 R2 alpha])];
B=[(subs(i1p_B,[r1 r2 D v1 v2],[R1 R2 alpha Vc1 V0])); subs(i2p_B,[r1 r2 D v1 v2],[R1 R2 alpha Vc1 V0]);subs(v1p_B,[r1 r2 D i1 i2],[R1 R2 alpha il1 il2]);subs(v2p_B,[r1 r2 D i1 i2],[R1 R2 alpha il1 il2])];

for i=1:size(A,1)
    for j=1:size(A,2)
        A1(i,j)=double(A(i,j));
    end
     B1(i,1)=double(B(i,1));
end
A=A1
B=B1
C=[0 0 0 1];
D=0;
Ri=.01;
Qi=[.01 0 0 0 0; 0 .01 0 0 0;0 0 .01 0 0;0 0 0 .01 0;0 0 0 0 250];
sys_=ss(A,B,C,D);
Ki_=lqi(sys_,Qi,Ri);
Ki_=Ki_';
ks=[Ki_(1,1) Ki_(2,1) Ki_(3,1) Ki_(4,1) ]'
ki=Ki_(5,1)


%Calcular Observador KALMA
f0=50e3;%conmutacion;
w0=2*pi*f0;
% figure();
% s = tf([1],[1 w0]);
% bode(s);
Aa= -w0;
Ba= 1; 
Ca= 1;
Da=0;
Rww =0.1;%Ruido de medida
Bw= [ 0.01 0.01 .1 .1 ]' ;%Ruido parametrico
Rvv= (Rww/3)^2*eye(4);%Que tan importante es el ruido para los estados
Bwaum= [ B zeros(size(B,1),1);0 Ba];
Aaum = [ A Bw*Ca;zeros(1,4) Aa];
Baum = [ B; 0];
Caum= [ C 0];
Daum=0;
Rvvaum= (1e-3)^2;
Cy=[eye(4) zeros(4,1)];
L=lqr(Aaum',Caum',Bwaum*Rww*Bwaum',Rvvaum);
L=L'
Ao=Aaum-L*Caum
Bo=[Baum L]
Co=[eye(size(Ao,1)-1) zeros(size(Ao,1)-1,1)]
Do=zeros(size(Ao,1)-1,2)

%close all;

%MPC
global Hu Qybar Smono Mmono M W S N ;

Ts=1/(50e3);
Cmpc=C;%eye(size(A,1));
Dmpc=D;%zeros(size(A,1),1);
[Ad,Bd,Cd,Dd]=c2dm(A,B,Cmpc,Dmpc,Ts);
m=size(Bd,2);
n=size(Ad,1);
r=size(Cd,1);
Amono=[Ad Bd;zeros(m,n) eye(m)];
Bmono=[Bd; eye(m)];
Cmono=[Cd zeros(r,m)];

N=100;
R=Ri;
Qy=200;%[.01 0 0 0; 0 .01 0 0 ;0 0 .01 0 ;0 0 0 .01 ];%eye(n);

Qybar=[];
Mmono=[];
Tbar=[];
Smono=[];
Rbar=[];
for i=0:N-1
    row=zeros(size(Cmono,1),size(Bmono,2)*N);
    for j=0:i;
        row(:,j+1)=[Cmono*Amono^(i-j)*Bmono];
    end 
    Mmono=[Mmono;row];
    Qybar=blkdiag(Qybar,Qy);
    Rbar=blkdiag(Rbar,R);
    Smono=[Smono; Cmono*Amono^(i+1)];
end 

Umax=1-alpha;
Umin=0.5-alpha;
Mu=[eye(size(Bd,2)*N);-eye(size(Bd,2)*N)];
Ulim=[Umax*ones(size(Bd,2)*N,1);-Umin*ones(size(Bd,2)*N,1)];
M=[Mu];
W=[Ulim];
S=[zeros(size(Mu,1),n+1)];
Hu=Mmono'*Qybar*Mmono+Rbar;
size(Mmono)
size(M)





%%

figure();
subplot(4,1,1);
plot(os_mm.time,os_mm.signals(1).values);
ylabel('Corriente I1(A)');
xlabel('Tiempo(s)');
title('Estado I1 Modelo Promedio');
grid on;
subplot(4,1,2);
plot(os_mm.time,os_mm.signals(2).values);
ylabel('Corriente I2(A)');
xlabel('Tiempo(s)');
title('Estado I2 Modelo Promedio');
grid on;
subplot(4,1,3);
plot(os_mm.time,os_mm.signals(3).values);
ylabel('Voltaje V1(V)');
xlabel('Tiempo(s)');
title('Estado V1 Modelo Promedio');
grid on;
subplot(4,1,4);
plot(os_mm.time,os_mm.signals(4).values);
ylabel('Voltaje V2(V)');
xlabel('Tiempo(s)');
title('Estado V2 � V0 Modelo Promedio');
grid on;


figure();
subplot(4,1,1);
plot(os_sm.time,os_sm.signals(1).values);
ylabel('Corriente I1(A)');
xlabel('Tiempo(s)');
title('Estado I1 Modelo Conmutado');
grid on;
subplot(4,1,2);
plot(os_sm.time,os_sm.signals(2).values);
ylabel('Corriente I2(A)');
xlabel('Tiempo(s)');
title('Estado I2 Modelo Conmutado');
grid on;
subplot(4,1,3);
plot(os_sm.time,os_sm.signals(3).values);
ylabel('Voltaje V1(V)');
xlabel('Tiempo(s)');
title('Estado V1 Modelo Conmutado');
grid on;
subplot(4,1,4);
plot(os_sm.time,os_sm.signals(4).values);
ylabel('Voltaje V2(V)');
xlabel('Tiempo(s)');
title('Estado V2 � V0 Modelo Conmutado');
grid on;

figure();
plot(output_sm_vs_mm.time,output_sm_vs_mm.signals.values);
ylabel('Voltaje V0(V)');
xlabel('Tiempo(s)');
title('LQG Salida V0 Modelo Promedio vs Modelo Conmutado');
legend('Modelo Promedio','Modelo Conmutado');
grid on;

% figure();
% plot(lqg_lm_output.time,lqg_lm_output.signals(2).values,mpc_ml_ouput.time,mpc_ml_ouput.signals(2).values);
% ylabel('Voltaje V0(V)');
% xlabel('Tiempo(s)');
% title('Salida V0 Control LQG vs MPC ');
% legend('Modelo Promedio','Modelo Conmutado');
% grid on;


figure();
plot(mpc_output_sm_vs_mm.time,mpc_output_sm_vs_mm.signals.values);
ylabel('Voltaje V0(V)');
xlabel('Tiempo(s)');
title('MPC Salida V0 Modelo Promedio vs Modelo Conmutado');
legend('Modelo Promedio','Modelo Conmutado');
grid on;

figure();
plot(output_sm_vs_mm.time,output_sm_vs_mm.signals.values,mpc_output_sm_vs_mm.time,mpc_output_sm_vs_mm.signals.values);
ylabel('Voltaje V0(V)');
xlabel('Tiempo(s)');
title('Salida V0 Control LQF vs MPC ');
legend('Modelo Promedio LQG','Modelo Conmutado LQG','Modelo Promedio MPC','Modelo Conmutado MPC');
grid on;