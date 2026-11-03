% DEMO  Chaîne complète sans IHM : génération du signal, déformation,
% estimation des paramètres, correction et affichage.
% MATLAB R2016b ou plus récent, aucune toolbox.

clear; close all; clc;

% Signal de référence : M + somme de 3 harmoniques, durée 1 s
M  = 2;
Ai = [5 3 2];     % amplitudes
Fi = [4 6 7];     % fréquences (Hz) : entières, distinctes, < fe/2
fe = 100;         % fréquence d'échantillonnage (Hz)

% Déformations testées : nom, correcteur, position de P0 et P1 dans les
% sorties d'estimation (0 = paramètre non utilisé par la déformation)
noms        = {'OFFSET', 'GAIN', 'GAIN + OFFSET', 'OFFSET + GAIN', 'Exponentielle', 'Logarithmique'};
correcteurs = {@correcteOFFSET, @correcteGAIN, @correcteGAIN_OFFSET, @correcteOFFSET_GAIN, ...
               @correcteExponentielle, @correcteLogarithmique};
position    = [1 0; 0 1; 2 1; 2 1; 1 2; 1 2];

% Deux jeux de paramètres [P0 P1] : positifs, puis négatifs
jeux = {[ 3  0;  0  2.5;  3  2.5;  3  2.5;  2  0.3;  1  2], ...
        [-4  0;  0 -1.5; -4 -1.5; -4 -1.5; -2 -0.3; -1 -2]};
titres_jeux = {'paramètres positifs', 'paramètres négatifs'};

for j = 1:numel(jeux)
    P = jeux{j};
    fprintf('\n=== %s ===\n', titres_jeux{j});
    fprintf('%-15s %9s %9s %9s %9s %12s\n', 'Déformation', 'P0 vrai', 'P0 estimé', ...
            'P1 vrai', 'P1 estimé', 'erreur max');

    for c = 1:numel(noms)
        f = correcteurs{c};

        % Figure : signal déformé, spectres, correction
        figure('Name', sprintf('%s (%s)', noms{c}, titres_jeux{j}), 'NumberTitle', 'off');
        ax_temps      = subplot(3, 1, 1);
        ax_spectre    = subplot(3, 1, 2);
        ax_correction = subplot(3, 1, 3);

        sorties = cell(1, nargout(f));
        [sorties{:}] = f(M, Ai, Fi, fe, P(c, 1), P(c, 2), ax_spectre, ax_correction);
        [s_base, s_deforme, s_corrige] = sorties{1:3};
        estimations = [sorties{4:end}];

        t = (0:length(s_base)-1) / fe;
        plot(ax_temps, t, s_base, 'b--', t, s_deforme, 'r');
        grid(ax_temps, 'on');
        xlabel(ax_temps, 'Temps (s)');
        ylabel(ax_temps, 'Amplitude');
        title(ax_temps, sprintf('Déformation %s : P0 = %g, P1 = %g', noms{c}, P(c, 1), P(c, 2)));
        legend(ax_temps, 'Signal de base', 'Signal déformé');

        % Tableau des paramètres vrais / estimés
        texte = cell(1, 4);
        for p = 1:2
            if position(c, p) == 0
                texte{2*p-1} = '-';
                texte{2*p}   = '-';
            else
                texte{2*p-1} = sprintf('%.4g', P(c, p));
                texte{2*p}   = sprintf('%.4g', estimations(position(c, p)));
            end
        end
        fprintf('%-15s %9s %9s %9s %9s %12.2e\n', noms{c}, texte{:}, max(abs(s_corrige - s_base)));
    end
end
