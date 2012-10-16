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
legend('FRR','FAR');
print('png/FFR-FAR.png','-dpng')


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
legend('ROC','EER','Op. Point');

axis([0 50 50 100]);
print('png/ROC.png','-dpng')

% DET curve
figure(3);
h = Plot_DET(FRR/100,FAR/100,'r');
hold on; Plot_DET(EERplot/100,EERplot/100,'ok');
hold on; Plot_DET(FRR(tmpOP)/100,FAR(tmpOP)/100,'xk');
legend('DET','EER','Op. Point');
title ('DET curve');
print('png/DET.png','-dpng')

end

function h = Plot_DET (Pmiss, Pfa, plot_code, opt_thickness)
%function h = Plot_DET (Pmiss, Pfa, plot_code, opt_thickness)
%
%  Plot_DET plots detection performance tradeoff on a DET plot
%  and returns the handle for plotting.
%
%  Pmiss and Pfa are the vectors of miss and corresponding false
%  alarm probabilities to be plotted.
%
%  The usage of Plot_DET is analogous to the standard matlab
%  p,ot function.
%
% See DET_usage for an example of how to use Plot_DET.
%
% opt_thickness : controls the line thickness. The default thickness
% is 0.5. A value between 2 and 5 will give a nice thick line.
%

Npts = max(size(Pmiss));
if Npts ~= max(size(Pfa))
        error ('vector size of Pmiss and Pfa not equal in call to Plot_DET');
end

%------------------------------
% plot the DET

if ~exist('plot_code')
        plot_code = 'y';
end

if ~exist('opt_thickness')
        opt_thickness = 0.5;
end

Set_DET_limits;
h = thick(opt_thickness,plot(ppndf(Pfa), ppndf(Pmiss), plot_code));
Make_DET;
end

function Make_DET()
%function Make_DET()
%
%  Make_DET creates a plot for displaying the Detection Error
%  Trade-off for a detection system.  The detection performance
%  is characterized by the miss and false alarm probabilities,
%  with the axes scaled and labeled so that a normal Gaussian
%  distribution will plot as a straight line.
%
%    The y axis represents the miss probability.
%    The x axis represents the false alarm probability.
%
%  See also Compute_DET, Plot_DET and Plot_DCF.

pticks = [0.00001 0.00002 0.00005 0.0001  0.0002   0.0005 ...
          0.001   0.002   0.005   0.01    0.02     0.05 ...
          0.1     0.2     0.4     0.6     0.8      0.9 ...
          0.95    0.98    0.99    0.995   0.998    0.999 ...
          0.9995  0.9998  0.9999  0.99995 0.99998  0.99999];

xlabels = [' 0.001' ; ' 0.002' ; ' 0.005' ; ' 0.01 ' ; ' 0.02 ' ; ' 0.05 ' ; ...
           '  0.1 ' ; '  0.2 ' ; ' 0.5  ' ; '  1   ' ; '  2   ' ; '  5   ' ; ...
           '  10  ' ; '  20  ' ; '  40  ' ; '  60  ' ; '  80  ' ; '  90  ' ; ...
           '  95  ' ; '  98  ' ; '  99  ' ; ' 99.5 ' ; ' 99.8 ' ; ' 99.9 ' ; ...
           ' 99.95' ; ' 99.98' ; ' 99.99' ; '99.995' ; '99.998' ; '99.999'];

ylabels = xlabels;

%---------------------------
% Get the min/max values of Pmiss and Pfa to plot

global DET_limits;

if isempty(DET_limits)
	Set_DET_limits;
end

Pmiss_min = DET_limits(1);
Pmiss_max = DET_limits(2);
Pfa_min   = DET_limits(3);
Pfa_max   = DET_limits(4);

%----------------------------
% Find the subset of tick marks to plot

ntick = max(size(pticks));
for (n=ntick:-1:1)
	if (Pmiss_min <= pticks(n))
		tmin_miss = n;
	end
	if (Pfa_min <= pticks(n))
		tmin_fa = n;
	end
end

for (n=1:ntick)
	if (pticks(n) <= Pmiss_max)
		tmax_miss = n;
	end
	if (pticks(n) <= Pfa_max)
		tmax_fa = n;
	end
end

%-----------------------------
% Plot the DET grid

set (gca, 'xlim', ppndf([Pfa_min Pfa_max]));
set (gca, 'xtick', ppndf(pticks(tmin_fa:tmax_fa)));
set (gca, 'xticklabel', xlabels(tmin_fa:tmax_fa,:));
set (gca, 'xgrid', 'on');
xlabel ('False Acceptance Rate (in %)');


set (gca, 'ylim', ppndf([Pmiss_min Pmiss_max]));
set (gca, 'ytick', ppndf(pticks(tmin_miss:tmax_miss)));
set (gca, 'yticklabel', ylabels(tmin_miss:tmax_miss,:));
set (gca, 'ygrid', 'on')
ylabel ('False Reject Rate (in %)')

set (gca, 'box', 'on');
axis('square');
axis(axis);
end

function [FARconfMIN  FRRconfMIN FARconfMAX FRRconfMAX]=ParamConfInter(FAR,FRR,num_imposteurs,num_clients)

% function: ParamConfInter
%
% DESCRIPTION:
% It calculates a 90% interval of confidence for each value of FAR and FRR
% using a parametric method
% 
% INPUTS:
% FAR: FAR vector
% FAR: FRR vector
% num_imposteurs: number of impostor tests
% num_clients: number of client tests
%
% OUTPUTS:
% FARconfMIN: vector of minimum values of FAR
% FRRconfMIN: vector of minimum values of FRR
% FARconfMAX: vector of maximum values of FAR
% FRRconfMAX: vector of maximum values of FRR
%
%
% CONTACT: aurelien.mayoue@int-edu.eu
% 19/11/2007

% size of error vectors
numErr = length (FAR);

% calculation of the confidence interval
for i=1:numErr
    varFRR=sqrt((FRR(i))*(1-FRR(i))/num_clients);
    FRRconfMIN(i)=FRR(i)-1.645*varFRR;
    FRRconfMAX(i)=FRR(i)+1.645*varFRR;
    
    varFAR=sqrt((FAR(i))*(1-FAR(i))/num_imposteurs);
    FARconfMIN(i)=FAR(i)-1.645*varFAR;
    FARconfMAX(i)=FAR(i)+1.645*varFAR;
end
end

function norm_dev = ppndf (cum_prob)
%function ppndf (prob)
%The input endto this function is a cumulative probability.
%The output from this function is the Normal deviate
%that corresponds to that probability.  For example:
%  INPUT   OUTPUT
%  0.001   -3.090
%  0.01    -2.326
%  0.1     -1.282
%  0.5      0.0
%  0.9      1.282
%  0.99     2.326
%  0.999    3.090

 SPLIT =  0.42;

 A0 =   2.5066282388;
 A1 = -18.6150006252;
 A2 =  41.3911977353;
 A3 = -25.4410604963;
 B1 =  -8.4735109309;
 B2 =  23.0833674374;
 B3 = -21.0622410182;
 B4 =   3.1308290983;
 C0 =  -2.7871893113;
 C1 =  -2.2979647913;
 C2 =   4.8501412713;
 C3 =   2.3212127685;
 D1 =   3.5438892476;
 D2 =   1.6370678189;

% the following code is matlab-tized for speed.
% on 200000 points, time went from 76 seconds to 5 seconds!
% original routine is included at end for reference

[Nrows Ncols] = size(cum_prob);
norm_dev = zeros(Nrows, Ncols); % preallocate norm_dev for speed
cum_prob(find(cum_prob>= 1.0)) = 1-eps;
cum_prob(find(cum_prob<= 0.0)) = eps;

R = zeros(Nrows, Ncols); % preallocate R for speed

% adjusted prob matrix
adj_prob=cum_prob-0.5;

centerindexes = find(abs(adj_prob) <= SPLIT);
tailindexes   = find(abs(adj_prob) > SPLIT);

% do centerstuff first
R(centerindexes) = adj_prob(centerindexes) .* adj_prob(centerindexes);
norm_dev(centerindexes) = adj_prob(centerindexes) .* ...
                    (((A3 .* R(centerindexes) + A2) .* R(centerindexes) + A1) .* R(centerindexes) + A0);
norm_dev(centerindexes) = norm_dev(centerindexes) ./ ((((B4 .* R(centerindexes) + B3) .* R(centerindexes) + B2) .* ...
                             R(centerindexes) + B1) .* R(centerindexes) + 1.0);


% find left and right tails
right = find(cum_prob(tailindexes)> 0.5);
left  = find(cum_prob(tailindexes)< 0.5);

% do tail stuff
R(tailindexes) = cum_prob(tailindexes);
% if prob > 0.5 then prob = 1-prob
R(tailindexes(right)) = 1 - cum_prob(tailindexes(right));
R(tailindexes) = sqrt ((-1.0) .* log (R(tailindexes)));
norm_dev(tailindexes) = (((C3 .* R(tailindexes) + C2) .* R(tailindexes) + C1) .* R(tailindexes) + C0);
norm_dev(tailindexes) = norm_dev(tailindexes) ./ ((D2 .* R(tailindexes) + D1) .* R(tailindexes) + 1.0);

% swap sign on left tail
norm_dev(tailindexes(left)) = norm_dev(tailindexes(left)) .* -1.0;

return
end

%--------------------
% here is the old routine, which is much slower

function norm_dev = oldppndf (cum_prob)
%function ppndf (prob)
%The input to this function is a cumulative probability.
%The output from this function is the Normal deviate
%that corresponds to that probability.  For example:
%  INPUT   OUTPUT
%  0.001   -3.090
%  0.01    -2.326
%  0.1     -1.282
%  0.5      0.0
%  0.9      1.282
%  0.99     2.326
%  0.999    3.090

 SPLIT =  0.42;

 A0 =   2.5066282388;
 A1 = -18.6150006252;
 A2 =  41.3911977353;
 A3 = -25.4410604963;
 B1 =  -8.4735109309;
 B2 =  23.0833674374;
 B3 = -21.0622410182;
 B4 =   3.1308290983;
 C0 =  -2.7871893113;
 C1 =  -2.2979647913;
 C2 =   4.8501412713;
 C3 =   2.3212127685;
 D1 =   3.5438892476;
 D2 =   1.6370678189;

[Nrows Ncols] = size(cum_prob);
norm_dev = zeros(Nrows, Ncols); % preallocate norm_dev for speed
for irow=1:Nrows
   for icol=1:Ncols

      prob = cum_prob(irow, icol);
      if (prob >= 1.0)
         prob = 1-eps;
      elseif (prob <= 0.0)
         prob = eps;
      end

      q = prob - 0.5;
      if (abs(prob-0.5) <= SPLIT)
         r = q * q;
         pf = q * (((A3 * r + A2) * r + A1) * r + A0);
         pf = pf / ((((B4 * r + B3) * r + B2) * r + B1) * r + 1.0);
 
      else
         if (q>0.0)
            r = 1.0-prob;
         else
            r = prob;
         end

         r = sqrt ((-1.0) * log (r));
         pf = (((C3 * r + C2) * r + C1) * r + C0);
         pf = pf / ((D2 * r + D1) * r + 1.0);
         if (q < 0)
            pf = pf * (-1.0);
         end
      end
      norm_dev(irow, icol) = pf;
   end
end
end

function Set_DET_limits(Pmiss_min, Pmiss_max, Pfa_min, Pfa_max)
% function Set_DET_limits(Pmiss_min, Pmiss_max, Pfa_min, Pfa_max)
%
%  Set_DET_limits initializes the min.max plotting limits for P_min and P_fa.
%
%  See DET_usage for an example of how to use Set_DET_limits.

Pmiss_min_default = 0.0005+eps;
Pmiss_max_default = 0.5-eps;
Pfa_min_default = 0.0005+eps;
Pfa_max_default = 0.5-eps;

global DET_limits;

%-------------------------
% If value not supplied as arguement, then use previous value
% or use default value if DET_limits hasn't been initialized.

if (~isempty(DET_limits))
	Pmiss_min_default = DET_limits(1);
	Pmiss_max_default = DET_limits(2);
	Pfa_min_default  = DET_limits(3);
	Pfa_max_default  = DET_limits(4);
end

if ~(exist('Pmiss_min')); Pmiss_min = Pmiss_min_default; end;
if ~(exist('Pmiss_max')); Pmiss_max = Pmiss_max_default; end;
if ~(exist('Pfa_min')); Pfa_min = Pfa_min_default; end;
if ~(exist('Pfa_max')); Pfa_max = Pfa_max_default; end;

%-------------------------
% Limit bounds to reasonable values

Pmiss_min = max(Pmiss_min,eps);
Pmiss_max = min(Pmiss_max,1-eps);
if Pmiss_max <= Pmiss_min
	Pmiss_min = eps;
	Pmiss_max = 1-eps;
end

Pfa_min = max(Pfa_min,eps);
Pfa_max = min(Pfa_max,1-eps);
if Pfa_max <= Pfa_min
	Pfa_min = eps;
	Pfa_max = 1-eps;
end

%--------------------------
% Load DET_limits with bounds to use


DET_limits = [Pmiss_min Pmiss_max Pfa_min Pfa_max];
end

function [lh] = thick(w,lh)
% THICK chages the width of the lines references by habdles
%    lh, the line handles
%     w, new width (default is 0.5)
% Example usage: thick(2,plot([1:5],[1,0,1,0,1],'b'))

for i=1:length(lh)
   set (lh(i),'LineWidth',w);
end
end