function plot_dist(sg,sf,num_bin)

if nargin < 3
    error('myApp:argChk', 'Wrong number of input arguments');
end

figure;
cla
hold on;
[n xout] = hist(sg,num_bin);
n = n*100/numel(sg);
line(xout,n,'LineWidth',6,'Color',[0 0 1])
[n xout] = hist(sf,num_bin);
n = n*100/numel(sf);
line(xout,n,'LineWidth',6,'Color',[1 0 0])
title('Distribucion de Scores')
xlabel('Score')
ylabel('%')
legend('Genuinas','Falsas','Location','Best')
grid on
print('png/Dist_Scores.png','-dpng')


end
