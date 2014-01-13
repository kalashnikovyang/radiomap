function [flag,error] =test_compute_accuracy(Q_cal, Q_acc, i, j)

%compute accuracy for calculated Q_Cal and Measured Q_Acc (T*1Vector)
%i,j: interbeacon i and j

flag = 0;
error = 0;

if i == j
    %disp('i==j');
    flag = 0;
    error = 0;
else
    %{
    figure;
    subplot(1,2,1);plot(Q_cal);title(['Calculated Rss', '  at beacon',num2str(i), '&', num2str(j)]);
    subplot(1,2,2);plot(Q_acc);title(['Measured Rss', '   at beacon',num2str(i), '&', num2str(j)]);
    %}
    flag = sqrt(sum(sum((Q_cal - Q_acc).^2)));
    temp_error = abs(Q_cal-Q_acc);
    temp_error = temp_error ./ Q_acc;
    error = sum(temp_error)/length(temp_error);
    %{
    figure;
    plot(error);title(['error at beacon ',num2str(i), '&', num2str(j)]);
    %}
end

