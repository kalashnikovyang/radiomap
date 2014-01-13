close all, clear all, clc;


global M; %number of RSS beacons
global K; %number of TOA beacons

global R; %communication range of TOA beacons
global Delta; %variance of TOA measurement
global Npoint;


global Area; %sensing field;
global RssBeaconCoordinates; %coordinates of RSS beacons
global TOABeaconCoordinates; %coordinates of TOA beacons

global Gridsize;
global Map;
global Map_beacon;
global T; %training time (long enough)
global T_run; %running time
global H; %RSS comparing threshold

load beacon_setup.mat;

Y=zeros(M,M);
T_run = 10;
H=25;

col=Area(1)/GridSize;
row=Area(2)/GridSize;

Y_update = Y_offline;

%training location coefficients, size: 10*96000
%compare begin&update with accurate to demonstrate update is better than
%begin, so that to prove its adaptive property
X_accurate = []; %accurate coefficients, calculated in each time slot

X_update = [];   %coefficients if updated

target = [];

online_test_location_accurate = zeros(T_run,2);
online_test_location_begin = zeros(T_run,2);
online_test_location_update = zeros(T_run,2);

for t=1:T_run %system running  
    %calculate current time's RSS by PropModel
    Rss = PropModel(Dis);
    Rss_location = PropModel(Dis_location);
    %generate target motion curve
    x = Area(1)/T_run*t;
    target(t,1)=x;
    target(t,2)=Area(2)/2*(sin(x*pi*2/Area(1))+1);
    %compute vector RSS_target, target<->beacon
    target_temp = [target(t,1),target(t,2)];
    Rss_target = Compute_Rss(target_temp, RssBeaconCoordinates);
    
    for i=1:M
        for j=1:M
            if i==j
                %do not calculate, ignore
            else
                %reconstruct Aij and Qij
                Q_ij = [];
                %--------------deal with time 1~t-1---------------
                if t ~= 1
                    for k = 1:t-1
                    %using model to generate Rss and avoid same A_ij in
                    %each time
                        Q_ij = [Q_ij; PropModel(Dis(i,j))];                  
                    end
                end
                %------deal with time t,current t has data--------
                Q_ij = [Q_ij; Rss(i,j)]; 
                %--------------deal with time 1~t-1---------------
                A_ij = [];
                rss = [];
                if t ~= 1
                    for kk = 1:t-1
                        rss=[];
                        for k = 1:M
                            if k==i || k==j
                            
                            else
                                rss = [rss, PropModel(Dis(i,k))];
                            end
                        end
                        rss = [rss, 1];
                        A_ij = [A_ij; rss];
                    end
                end
                %----deal with time t, using current data------
                rss = [];
                for k = 1:M
                    if k==i || k==j
                        
                    else
                        rss = [rss, Rss(i,k)];
                    end                   
                end 
                rss = [rss, 1];
                A_ij = [A_ij; rss];
                %----deal with time t, using current data------
                %-----------------------------
                temp = M*(i-1)+j;
                Y_ij = Y_offline(temp,:)';
                Q_temp = A_ij * Y_ij;
                %compare calculate RSS to accurate RSS
                %show whether to update Y_ij
                abs = (Q_temp - Q_ij).^2; 
                %{
                %----- test ------
                if(t == 5)
                fprintf('test two Q_temp & Q_ij matrix, at time %d with i=%d, j=%d\n',t,i,j);
                fprintf('size of Q matrix: %d,%d\n',size(Q_temp));
                fprintf('sum of abs');
                haha = sum(sum(abs))  
                fprintf('\n');
                figure;
                subplot(1,2,1);plot(Q_temp,'-.or');
                subplot(1,2,2);plot(Q_ij,'-.ok');
                end
                %----- test ------
                %}
                if sqrt(sum(sum(abs))) > H
                    Y_ij = inv(A_ij'*A_ij)*A_ij'*Q_ij; 
                    %replace in Y_update
                    Y_update(temp,:) = Y_ij;
                    %use Y_update to update training locations's coefficients
                    
                end
            end
        end
    end
    %calculate location coefficients first 
    %
    if t == 1
        %X_begin = Cal_coefficient(Rss_location,Rss);
        X_update = X_begin;%copy former train coefficient info from beacon_setup.m
    else
        %use t=1 X_begin to update training locations's coefficients adaptively
        %X_update = Cal_update_coefficient(Rss_location,Rss,X_begin,Y_update,M);
        %Update X_update at time t-1, generate New X_uodate at time t
        X_update = Cal_update_coefficient(Rss_location,Rss,X_update,Y_update,M);
    end
    %{
    %calculate each time slot's accurate coefficients
    X_accurate = Cal_coefficient(Rss_location,Rss);
    %compare X_begin, update and accurate
    %want to show update is better than begin for its adaptive property
    flag_compare = 0;
    flag_compare = Compare_accuracy(X_begin,X_update,X_accurate);
    %}
    
    % simulate a motion curve target to verify
    [x1,y1,x2,y2,x3,y3] = Compute_location(X_begin,X_update,target_temp,Rss_target,Rss);
    
    online_test_location_accurate(t,1) = x3;
    online_test_location_accurate(t,2) = y3;
    
    online_test_location_begin(t,1) = x1;
    online_test_location_begin(t,2) = y1;
    
    online_test_location_update(t,1) = x2;
    online_test_location_update(t,2) = y2;
end
%
figure;
plot(online_test_location_accurate(:,1),online_test_location_accurate(:,2),'b:+');
hold on;

plot(online_test_location_begin(:,1),online_test_location_begin(:,2),'g:x');
hold on;

plot(online_test_location_update(:,1),online_test_location_update(:,2),'r:o');
legend('accurate', 'begin', 'update');
hold off;
%}












