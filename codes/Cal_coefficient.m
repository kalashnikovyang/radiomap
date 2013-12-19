function X = Cal_coefficient(Rss_location,Rss)

%Dis_location: Distance between beacons and locations
%Dis: Distance between beacons
%M: beacon number
%col,row: Map Area, col*low: nubmer of locations
%t:current running time slot

%X: return current time's accurate location coefficients

X = [];
[a, b] = size(Rss_location); %a=10,b=9600

R = []; %R records current col of Dis_location, means each becacon to locations
Q = []; %Q records current beacon distance
Alpha = []; %Alpha records training coefficients

%{
for i = 1:b
    R = Rss_location(:,i)'; %1*10 
    temp = Rss(i,:);%1*10
    %delete q_ii
    if i==1
        Q = temp(2:length(temp));
    else
        Q =[temp(1:i-1),temp(i+1:length(temp))];
    end
    Q = [Q,1]; %add constant 1
    sprintf('this is matrix inv Q\n');
    inv(Q'*Q)
    Alpha = inv(Q'*Q)*Q'*R;
    X = [X,Alpha];
end
%}
%consider each beacon to each location, => cause high correlation when
%calculate inv(Q'*Q)
%
for i = 1:a
    R = Rss_location(i,:); %1*9600  
    temp = Rss(i,:);%1*10
    %delete q_ii
    if i==1
        Q = temp(2:length(temp));
    else
        Q =[temp(1:i-1),temp(i+1:length(temp))];
    end
    Q = [Q,1]; %add constant 1
    sprintf('this is matrix inv Q\n');
    inv(Q'*Q)
    Alpha = inv(Q'*Q)*Q'*R;
    X = [X,Alpha];
end
%}   