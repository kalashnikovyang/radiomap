function [x,y] = number_transfer(best,col,row)

%transfer best location number to 2D

%col=120,row=80
x = floor(best/row);
y = best - x*row;
x = x+1;