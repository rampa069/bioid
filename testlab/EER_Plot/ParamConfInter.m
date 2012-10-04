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