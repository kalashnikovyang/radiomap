function X = Cal_update_coefficient(Rss_location,Rss,X_begin,Y_update,M)

%Rss_location: Rss between beacons and locations
%Rss: Rss betwwen beacons
%X_begin: accurate coefficient for location when time starts
%Y_update: updated beacon coefficients

%X: return updated location coefficients

X = X_begin;

[row,col]=size(Rss_location);

for i = 1:row
    for l = 1:col
        %consider r_li one by one
        alpha_old = X_begin(:,i*l); %i*l th column
        [a,b]=size(alpha_old);
        alpha_new = zeros(a,b);
        for k = 1:length(alpha_old) %calculate each alpha
            %alpha_ik = sum(alpha_iv * beta_ik), beta_ik maps in Y_iv, v=1~m
            for v = 1:M
                %get beta_ik in Y_iv
                Y_iv = Y_update(M*(i-1)+v,:);
                if i==v || k==v || k==i
                    temp = 0;
                else
                    beta_ik = find_beta_ik(Y_iv,i,v,k);
                    temp = beta_ik * alpha_old(v);%alpha_iv * beta_ik(in Y_iv)
                end
                %{
                %alpha_old:10*1, Y_iv:1*9 no beta_ii,beta_iv                                            
                if i == v
                    alpha_new(k,b) = 0;
                elseif v == 1
                    alpha_old_cut = alpha_old(2:length(alpha_old));
                else
                    alpha_old_cut = [alpha_old(1:v-1),alpha_old(v+1:length(alpha_old))];
                end
                %alpha_new(k,b) = Y_iv * alpha_old_cut;
                %}
                alpha_new(k,b) = alpha_new(k,b) + temp;
            end
        end
        X(:,(l-1)*M+i) = alpha_new; %replace with updated column
        %disp('haha');
    end
end
         

