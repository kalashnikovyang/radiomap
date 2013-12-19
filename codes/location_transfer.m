function [x,y] = location_transfer(best,col,row)

%col=120,row=90
x = floor(best/row);
y = best - x*row;
x = x+1;