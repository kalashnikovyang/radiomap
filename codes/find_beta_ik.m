function beta_ik = find_beta_ik(Y_iv,i,v,k)

%Y_iv:1*9 no beta_ii, beta_iv
%i,v,k not equal respectively

max_value = max(i,v);
min_value = min(i,v);

if k < min_value
    beta_ik = Y_iv(k);
elseif k > max_value
    beta_ik = Y_iv(k-2);
else
    beta_ik = Y_iv(k-1);
end