%%ERA



function p=PropModel(d)
global pvar;
global pt;
global p0;

[a,b]=size(d);
p=zeros(a,b);
for i=1:a
    for j=1:b
        if d(i,j)==0 %if same beacon, set rss=0
            p(i,j)=0;
        else
            p(i,j)=pt-p0-10*2*log(d(i,j)/1)+normrnd(0,pvar);%using normrnd to generate RSS as time variant
        end
    end
end

