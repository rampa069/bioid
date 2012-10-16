%% 
for muestras = 5
    %clearvars -except v1 muestras
    load(['Eva_' num2str(muestras) 'muestras'])
    subplot(3,2,muestras-2)
    plot_dist(scores_gen(:,end),scores_falsas(:,end),100);
end
