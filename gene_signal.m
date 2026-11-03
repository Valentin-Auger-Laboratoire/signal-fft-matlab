% Créé le 21/09/2026 par une équipe de 3 élèves, EPISEN


function [s] = gene_signal(M, Ai, Fi, fe, AFF)
% Durée du signal : 1 seconde
T = 1;

% Vecteur temps (N échantillons sur 1 seconde)
t = 0 : 1/fe : T - 1/fe;

% Calcul de la somme des harmoniques + la valeur moyenne M
% Note : sum() permet d'éviter la boucle 'for' en MATLAB
s = M + sum(Ai(:) .* sin(2 * pi * Fi(:) * t), 1);

% Affichage optionnel
if AFF == 1
    plot(t, s);
    grid on;
    xlabel('Temps (s)');
    ylabel('Amplitude');
    title('Signal généré');
end
end