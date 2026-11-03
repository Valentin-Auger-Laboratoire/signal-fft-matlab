function [s_base, s_deforme, s_corrige, P0_estime, P1_estime] = correcteLogarithmique(M, Ai, Fi, fe, P0, P1, ax_spectre, ax_correction)
% Modèle (identique à deform_signal, choix 6) : sd = P0 + P1 * sign(s) .* log(1 + |s|)
    if nargin < 7, ax_spectre = []; end
    if nargin < 8, ax_correction = []; end

    % 1. Génération du signal de base
    s_temp = gene_signal(M, Ai, Fi, fe, 0);
    s_base = s_temp - mean(s_temp); % Signal centré à 0

    % 2. Application de la déformation logarithmique (choix = 6)
    choix_deformation = 6;
    s_deforme = deform_signal(s_base, choix_deformation, P0, P1);

    % 3. Estimation de P0 : sign(s).*log(1+|s|) est impaire et la référence (somme de
    % sinus sur une seconde) est antisymétrique, donc sa moyenne est nulle : <sd> = P0
    P0_estime = mean(s_deforme);
    g = s_deforme - P0_estime;   % = P1 * sign(s) .* log(1 + |s|)

    % 4. Estimation de P1
    % Signe : g a le signe de P1 * s, lu sur la phase de la raie dominante
    signe_P1 = sign(echelle_reference(g, Ai, Fi, fe));
    if signe_P1 == 0
        error('correcteLogarithmique:P1', 'P1 nul : la déformation n''est pas inversible.');
    end
    % Module : unique p > 0 pour lequel exp(|g|/p) - 1 a la valeur efficace de la référence
    eff_ref = sqrt(sum(Ai(:).^2) / 2);
    ecart = @(p) sqrt(mean((exp(abs(g) / p) - 1).^2)) - eff_ref;   % décroissante en p
    p_min = max(abs(g)) / 300;   % exp(300)^2 reste fini
    p_max = max(abs(g));
    while ecart(p_max) > 0
        p_max = 2 * p_max;
    end
    P1_estime = signe_P1 * fzero(ecart, [p_min p_max]);

    % 5. Correction (Transformation inverse : s = sign(g/P1) .* (exp(|g/P1|) - 1))
    u = g / P1_estime;
    s_corrige = sign(u) .* (exp(abs(u)) - 1);

    trace_resultats(ax_spectre, ax_correction, s_base, s_deforme, s_corrige, fe, 'Logarithmique');
end
