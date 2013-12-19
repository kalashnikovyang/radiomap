function flag = Compare_accuracy(X_begin,X_update,X_accurate)

%X_begin: coefficients at time t=1
%X_update: updated coefficients at current time
%X_accurate: measured coefficients

%flag: return 1 if adaptive idea is better

a = (X_begin - X_accurate).^2;
b = (X_update - X_accurate).^2;
c = sqrt(sum(sum(a)));
d = sqrt(sum(sum(b)));
if c > d
    flag = 1;% update is adaptive, better
else
    flag = 0;
end