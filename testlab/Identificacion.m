%% Identificación
clear

%% configuración
num_ranks = 15;

%% Cargamos datos de scores (calculados en verificación)
load Eva_5muestras scores_gen scores_falsas users
%%
rank_ok = zeros(1,num_ranks);
num_attempts = rank_ok;
errores = zeros(numel(users),numel(users));
for u = 1 : numel(users)
    for h = 1 : numel(users(u).sample)  % Huellas para las cuales tenemos todas las comparaciones con todos los patrones
       scores = [ scores_falsas(scores_falsas(:,1)==u & scores_falsas(:,3)==h,[2,4]) ; scores_gen(scores_gen(:,1)==u & scores_gen(:,2)==h,[1,3])]; % Unimos los resultados de las falsas para la huella h del usuario u, junto con la genuina (guardamos también los indices de patrón comparado)
       scores_sort = flipud(sortrows(scores,2));  % Ordenamos de manera creciente los scores
       for r = 1 : num_ranks % Comprobamos si el usuario esta dentro de los r primeros.
          num_attempts(r) = num_attempts(r) +1;
          if any(scores_sort(1:r,1) == u)
             rank_ok(r) = rank_ok(r) + 1;
          else
              if (r==1)
                errores(u,scores_sort(1,1)) = errores(u,scores_sort(1,1)) + 1;
              end
          end
       end
    end
end

%% Dibujamos
ratios = 100*rank_ok./num_attempts;
figure;
plot_ident(ratios);
%% Dibujamos matriz de confusión
%figure;
%imagesc(errores)
%colorbar('EastOutside')