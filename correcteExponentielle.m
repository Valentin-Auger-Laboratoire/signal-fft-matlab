function [s_base, s_deforme, s_corrige, P0_estime, P1_estime] = correcteExponentielle(M, Ai, Fi, fe, P0, P1, ax_spectre, ax_correction)
% Modèle (identique à deform_signal, choix 5) : sd = P0 * exp(P1 * s)
    if nargin < 7, ax_spectre = []; end
    if nargin < 8, ax_correction = []; end

    % 1. Génération du signal de base
    s_temp = gene_signal(M, Ai, Fi, fe, 0);
    s_base = s_temp - mean(s_temp); % Signal centré à 0

    % 2. Application de la déformation exponentielle (choix = 5)
    choix_deformation = 5;
    s_deforme = deform_signal(s_base, choix_deformation, P0, P1);
    if any(s_deforme == 0)
        error('correcteExponentielle:P0', 'P0 doit être non nul.');
    end

    % 3. Linéarisation : ln|sd| = ln|P0| + P1 * s
    y = log(abs(s_deforme));

    % Le signal de référence étant centré, la moyenne de y vaut ln|P0| ;
    % le signe de P0 est celui du signal déformé
    P0_estime = sign(s_deforme(1)) * exp(mean(y));

    % 4. Estimation de P1 : y - <y> = P1 * s
    % (valeur efficace et phase comparées à celles, connues, de la référence)
    y_centre = y - mean(y);
    P1_estime = echelle_reference(y_centre, Ai, Fi, fe);
    if P1_estime == 0
        error('correcteExponentielle:P1', 'P1 nul : la déformation n''est pas inversible.');
    end

    % 5. Correction (Transformation inverse : s = ln(sd / P0) / P1)
    s_corrige = y_centre / P1_estime;

    trace_resultats(ax_spectre, ax_correction, s_base, s_deforme, s_corrige, fe, 'Exponentielle');
end
