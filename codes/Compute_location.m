function flag = Compute_location(X_begin,X_update,target,Rss_target,Rss)

%X_begin: coefficients at time t=1
%X_update: updated coefficients at current time

%target: current target location [x,y]
%Rss_target: current rss between target and beacons, M*1 vector
%Rss: rss between beacons, M*M vector

%flag: return 1 if track by update is better

[row,col]=size(X_begin); %10*96000, row: beacon num, col: location*beacon num
location_num = col/row;

X_location = [];

begin_best = 0; %record best fit track location for target
update_best = 0;

% compute each location's rss, compare to target rss, find the closest one
for k = 1:location_num
    %compute begin's rss
    X_location_begin = X_begin(:,k:k+row-1);
    matrix_begin = Rss * X_location_begin;
    %diag elements equals to Rss
    Rss_target_cal_begin = diag(matrix_begin);    
    if k == 1
        old_begin = sum((Rss_target_cal_begin - Rss_target).^2); 
        begin_best = 1;
    else
        new_begin = sum((Rss_target_cal_begin - Rss_target).^2);
        if new_begin < old_begin
            begin_best = k;
            old_begin = new_begin;
        end
    end
        
    
    %compute update's rss
    X_location_update = X_update(:,k:k+row-1);
    matrix_update = Rss * X_location_update;
    %diag elements equals to Rss
    Rss_target_cal_update = diag(matrix_update);
    if k == 1
        old_update = sum((Rss_target_cal_update - Rss_target).^2);
        update_best = 1;
    else
        new_update = sum((Rss_target_cal_update - Rss_target).^2);
        if new_update < old_update
            update_best = k;
            old_update = new_update;
        end
    end
end

%transfer location into 2-D [x,y]
[x1,y1] = number_transfer(begin_best,120,80);
[x2,y2] = number_transfer(update_best,120,80);
x3=target(1);
y3=target(2);

%
figure;
plot(x1,y1,'go',x2,y2,'rx',x3,y3,'b+');
%}

a=[x1,y1];
b=[x2,y2];
c=[x3,y3];
d=sum((a-c).^2);
e=sum((b-c).^2);
if d > e
    flag = 1;
else
    flag = 0;
end







