function System=addFactorPose(factorR,Config,System)

% Config=addPose(factorR,Config)
% The script adds a new pose factor to the current System
% Author: Viorela Ila

global Timing
Sz=diag([1/factorR.data(6);1/factorR.data(8);1/factorR.data(9)]); % only diag cov.
R=chol(inv(Sz)); %S^(-1/2)

% The 2 poses linked by the constraint
s1=factorR.data(2);
s2=factorR.data(1);

% % check for the order of ids and invert the transformation if needed
if (s1>s2)
    z=factorR.data(3:5)';
    s1=factorR.data(1);
    s2=factorR.data(2);
else
     z=InvertEdge(factorR.data(3:5)');
end

ndx1=[Config.PoseDim*Config.id2config((s1+1),1)+Config.LandDim*Config.id2config((s1+1),2)]+[1:Config.PoseDim];
ndx2=[Config.PoseDim*Config.id2config((s2+1),1)+Config.LandDim*Config.id2config((s2+1),2)]+[1:Config.PoseDim];


p1=Config.vector(ndx1,1); % The estimation of the two poses
p2=Config.vector(ndx2,1);

h=Absolute2Relative(p1,p2); % Expectation
[H1 H2]=Absolute2RelativeJacobian(p1,p2); % Jacobian

% Update System

System.ndx=System.ndx(end)+1:System.ndx(end)+Config.PoseDim;

ck=cputime;
System.A(System.ndx,ndx1)=sparse2(R*H1); % Jacobian matrix
System.A(System.ndx,ndx2)=sparse2(R*H2);
Timing.updateA=Timing.updateA+(cputime-ck);
Timing.updateACnt=Timing.updateACnt+1;


% right hand side
ck=cputime;
d=z-h;
d(end)=pi2pi(d(end));
System.b(System.ndx)=R*d; % Independent term
Timing.updateB=Timing.updateB+(cputime-ck);
Timing.updateBCnt=Timing.updateBCnt+1;
