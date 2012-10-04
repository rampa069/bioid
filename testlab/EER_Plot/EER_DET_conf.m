function [EER confInterEER OP confInterOP]=EER_DET_conf(clients,imposteurs,OPvalue,pas0,creciente)

% function: EER_DET_conf
%
% DESCRIPTION:
% It plots traditional curves and gives also some interesting values in 
% order to evaluate the performance of a biometric verification system. 
% The curves are:
%       - Receiver Operating Characteristic (ROC) curve
%       - Detection Error Trade-off (DET) curve
%       - FAR vs FRR
% The values are:
%       - Equal Error Rate (EER) which is computed as the point where
%       FAR=FRR
%       - Operating Point (OP) which is defined in terms of FRR (%)
%       achieved for a fixed FAR
% A 90% interval of confidence is provided for both values (parametric 
% method).
%
% INPUTS:
% clients: vector of genuine/client scores
% imposteurs: vector of impostor scores
% OPvalue: value of FAR at which the OP value is estimated
% pas0: number of thresholds used the estimate the score distributions
% (10000 is advised for this parameter)
%
% OUTPUTS:
% EER: EER value
% confInterEER: error margin on EER value
% OP: OP value
% confInterOP: error margin on OP value
%
%
% CONTACT: aurelien.mayoue@int-edu.eu
% 19/11/2007

%%%%% estimation of thresholds used to calculate FAR et FRR

% maximum of client scores
m0 = max (clients);

% size of client vector
num_clients = length (clients);

% minimum impostor scores
m1 = min (imposteurs);

% size of impostor vector
num_imposteurs = length (imposteurs);

% calculation of the step
pas1 = (m0 - m1)/pas0;
x = [m1:pas1:m0]';

num = length (x);

%%%%%

%%%%% calculation of FAR and FRR
if creciente == 0
    for i=1:num
        fr=0;
        fa=0;
        for j=1:num_clients
            if clients(j)<x(i)
                fr=fr+1;
            end
        end
        for k=1:num_imposteurs
            if imposteurs(k)>=x(i)
                fa=fa+1;
            end
        end
        FRR(i)=100*fr/num_clients;
        FAR(i)=100*fa/num_imposteurs;
    end
else
    for i=1:num
        fr=0;
        fa=0;
        for j=1:num_clients
            if clients(j)>x(i)
                fr=fr+1;
            end
        end
        for k=1:num_imposteurs
            if imposteurs(k)<=x(i)
                fa=fa+1;
            end
        end
        FRR(i)=100*fr/num_clients;
        FAR(i)=100*fa/num_imposteurs;
    end
end
%%%%%

%%%%% calculation of EER value
if creciente == 0
    
    tmp1=find (FRR-FAR<=0);
    tmps=length(tmp1);
    
    if ((FAR(tmps)-FRR(tmps))<=(FRR(tmps+1)-FAR(tmps+1)))
        EER=(FAR(tmps)+FRR(tmps))/2;tmpEER=tmps;
    else
        EER=(FRR(tmps+1)+FAR(tmps+1))/2;tmpEER=tmps+1;
    end
else
    tmp1=find (FRR-FAR>=0);
    tmps=length(tmp1);
    
    if ((FAR(tmps)-FRR(tmps))>=(FRR(tmps+1)-FAR(tmps+1)))
        EER=(FAR(tmps)+FRR(tmps))/2;tmpEER=tmps;
    else
        EER=(FRR(tmps+1)+FAR(tmps+1))/2;tmpEER=tmps+1;
    end
end

%%%%%

%%%%% calculation of the OP value
tmp2=find (OPvalue-FAR<=0);
tmpOP=length(tmp2);

OP=FRR(tmpOP);
%%%%%

%%%%% calculation of the confidence intervals
[FARconfMIN  FRRconfMIN FARconfMAX FRRconfMAX]=ParamConfInter(FAR/100,FRR/100,num_imposteurs,num_clients);

% EER
confInterEER=EER-100*(FARconfMIN(tmpEER)+FRRconfMIN(tmpEER))/2;

% Operating Point
confInterOP=OP-100*FRRconfMIN(tmpOP);

%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% plotting of curves

% FAR vs FRR
figure(1);
plot (x,FRR,'r');
hold on;plot (x,FAR,'b');
xlabel ('Threshold');
ylabel ('Error');
title ('FAR vs FRR graph');
legend('FRR','FAR','Location','Best');
print('png/FFR.png','-dpng')

% interpolation for the plotting
equaX=x(tmps)*(FRR(tmps+1)-FAR(tmps+1))+x(tmps+1)*(FAR(tmps)-FRR(tmps));
equaY=FRR(tmps+1)-FAR(tmps+1)+FAR(tmps)-FRR(tmps);
threshold=equaX/equaY;
EERplot=threshold*(FAR(tmps)-FAR(tmps+1))/(x(tmps)-x(tmps+1))+(x(tmps)*FAR(tmps+1)-x(tmps+1)*FAR(tmps))/(x(tmps)-x(tmps+1));

% ROC curve
figure(2);
plot (FAR,100-FRR,'r');
xlabel ('Impostor Attempts Accepted = FAR (%)');
ylabel ('Genuine Attempts Accepted = 1-FRR (%)');
title ('ROC curve');
hold on;scatter (EERplot,100-EERplot,'ok');
hold on;scatter (FAR(tmpOP),100-FRR(tmpOP),'xk');
% AXIS([0 50 50 100]);
print('png/ROC.png','-dpng')

% DET curve
figure(3);
h = Plot_DET(FRR/100,FAR/100,'r');
hold on; Plot_DET(EERplot/100,EERplot/100,'ok');
hold on; Plot_DET(FRR(tmpOP)/100,FAR(tmpOP)/100,'xk');
title ('DET curve');
print('png/DET.png','-dpng')
