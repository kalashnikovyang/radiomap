function Q = Get_Qi(Dis,i,T_train)

% get current matrix Q_single until time T_train with beacon i

global M;

Q = []; %size:T_Train*M

for t=1:T_train
    temp = PropModel(Dis(i,:));
    Q_single=[];
    if i==1
        Q_single = temp(2:length(temp));
    else
        Q_single =[temp(1:i-1),temp(i+1:length(temp))];
    end
    Q_single = [Q_single,1]; %add constant 1
    Q = [Q;Q_single];
end