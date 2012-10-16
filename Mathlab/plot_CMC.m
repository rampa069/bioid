function plot_CMC(scores_gen,scores_falsas,num_ranks)

%%
cmc_values = zeros(1,num_ranks);
num_attempts = numel(scores_gen(:,3));

for a = 1 : num_attempts
    u = scores_gen(a,1);
    h = scores_gen(a,2);
    
    sc_gen = scores_gen(a,3);
    sc_falsas = scores_falsas(scores_falsas(:,2)==u & scores_falsas(:,3)==h,4);
    
    rango = numel(sc_falsas(sc_falsas>=sc_gen)) + 1;
    cmc_values(rango:end) = cmc_values(rango:end)+1;   
end
%%
cmc_values = 100*cmc_values./num_attempts;
%% Dibujamos
figure;
plot(cmc_values,'LineWidth',4)
legend('Porcentaje de Aciertos','Location','East');
ylabel('% Aciertos');
xlabel('Num de Candidatos');
axis([1 num_ranks 75 105]);
title(' Porcentaje de Aciertos Vs Num. Candidatos (CMC)');
print('png/CMC.png','-dpng')

