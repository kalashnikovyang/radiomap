close all, clear all, clc;

global M; %number of RSS beacons
global K; %number of TOA beacons
global N; %number of grids;
global R; %communication range of TOA beacons
global Delta; %variance of TOA measurement

global pt; %transmission power of RSS beacons;
global p0; %reference path loss at 1m;
global pvar; % random noise in path loss

global Area; %sensing field;
global RssBeaconCoordinates; %coordinates of RSS beacons
global TOABeaconCoordinates; %coordinates of TOA beacons
global GridSize;
global Map;
global Map_beacon;
global T; %training time (long enough)

M=10;
K=6;
GridSize=1;
Area=[120, 80];
pt=150;
p0=10;
pvar=0;
R=25;
Delta = 0.2;
T=1000; 

N=Area(1)/GridSize*Area(2)/GridSize; % number of training locations;

RssBeaconCoordinates=zeros(M,2); %location of RSS beacons;
% generate Location of Rss Beacons randomly
%
for i=1:1:M
    RssBeaconCoordinates(i,1)=rand*Area(1);
    RssBeaconCoordinates(i,2)=rand*Area(2);
end
%
%generate Location of Rss Beacons uniformly
%{
for i=1:1:M
    if(i>5)
        RssBeaconCoordinates(i,1)=Area(1)/10+Area(1)/5*(i-6);
        RssBeaconCoordinates(i,2)=Area(2)/4;
    else
        RssBeaconCoordinates(i,1)=Area(1)/10+Area(1)/5*(i-1);
        RssBeaconCoordinates(i,2)=Area(2)/4+Area(2)/2;
    end
end
%}
hold on;
plot(RssBeaconCoordinates(:,1), RssBeaconCoordinates(:,2),'ro','linewidth',2);
axis([0,Area(1),0,Area(2)]);

Map_beacon = zeros(M*(M-1)/2 ,T); % record RSS between beacons
%Map = zeros(M, N, T); % record RSS between beacons and locations

col=Area(1)/GridSize;
row=Area(2)/GridSize;

%RSS measurements between beacons
Dis=zeros(M,M);
for i=1:M
    for j=1:M
        Dis(i,j)=sqrt((RssBeaconCoordinates(i,1)-RssBeaconCoordinates(j,1))^2+(RssBeaconCoordinates(i,2)-RssBeaconCoordinates(j,2))^2);
        %{
        k=M*(M-1)/2-(10-i)*(11-i)/2+j; % use 2D array to store RSS between beacons 
        for t=1:T
            Map_beacon(k,t)=PropModel(dis); % normrnd in model simulates RSS time variance
        end
        %}
    end
end
%RSS measurements between beacons and locations
%
for i=1:1:col
    for j=1:1:row
        for m=1:1:M
            dis=sqrt(((i-0.5)*GridSize-RssBeaconCoordinates(m,1))^2+((j-0.5)*GridSize-RssBeaconCoordinates(m,2))^2);
            %Dis_location(m,i+(j-1)*col)=dis;
            %transfer 2D into number
            num = location_transfer(i,j,col,row);
            Dis_location(m,num)=dis;
            %Dis_location(m,(i-1)*row+j)=dis;
        end
    end
end
%
%offline training
Y_offline = []; %Y_offline stores the offline training coefficients, i*j th row represents Y_ij
%-----------------------------------------------------------
%Puzzle: each iteration re-calculate Dis(i,j)??????
%-----------------------------------------------------------
Compute_accuracy_linear_regression = [];
Compute_error = [];
for i=1:M
    for j=1:M       
        %calculate A_ij
        A_ij=[];
        Q_ij = [];
        for t=1:T
            rss=[];
            for k=1:M
                if k==i || k==j 
                    %Not include q_ii and q_ij
                else
                    rss=[rss,PropModel(Dis(i,k))];
                end
            end
            rss=[rss,1];
            A_ij=[A_ij;rss];
        end
        %calculate Q_ij
        for t=1:T
            Q_ij = [Q_ij; PropModel(Dis(i,j))];
        end
        Y_ij = inv(A_ij'*A_ij)*A_ij'*Q_ij;  
        %store all offline coefficients in Y_offline, i*jth row represents
        %Y_ij
        %
        %----------test-----------
        %compute accuracy for linear regression
        [flag,error] = test_compute_accuracy(A_ij*Y_ij, Q_ij, i, j);
        Compute_accuracy_linear_regression = [Compute_accuracy_linear_regression;flag];
        Compute_error = [Compute_error; error];
        %----------test-----------
        %}
        if i==j
            Y_ij =zeros(9,1);
        end
        Y_offline = [Y_offline;Y_ij'];
    end
end
%-----------------------------------------------------------        
figure;
subplot(1,2,1);plot(Compute_accuracy_linear_regression);
title('Compute accuracy for linear regression');
subplot(1,2,2);plot(Compute_error);
title('Compute error for linear regression');
%by a short time, get alpha(X_begin) for location with R_li and Q_li
T_train = 10;
X_begin = zeros(M,M*N);
for i=1:M
    Q_i = [];
    %get matrix Q for beacon i until time T_train
    Q_i = Get_Qi(Dis,i,T_train);
    for l=1:N
        R_li = [];
        %get a time sequence R_li
        for t=1:T_train
            temp = PropModel(Dis_location(i,l));
            R_li = [R_li;temp];
        end
        % cal matrix alpha
        alpha = [];
        alpha = inv(Q_i'*Q_i)*Q_i'*R_li;
        X_begin(:,(l-1)*M+i) = alpha;
    end
end

save beacon_setup.mat