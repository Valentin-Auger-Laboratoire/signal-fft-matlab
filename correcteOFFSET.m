function [s_base, s_deforme, s_corrige, offset_mesure] = correcteOFFSET(M, Ai, Fi, fe, P0, P1, ax_spectre, ax_correction)
    if nargin < 7, ax_spectre = []; end
    if nargin < 8, ax_correction = []; end

    %  Génération du signal de base
    s_temp = gene_signal(M, Ai, Fi, fe, 0);

    % Signal centré (moyenne nulle : amplitude nulle à 0 Hz)
    s_base = s_temp - mean(s_temp);

    %  Application de la déformation OFFSET (choix 1)
    s_deforme = deform_signal(s_base, 1, P0, P1);

    %  Calcul de la FFT
    N = length(s_deforme);
    X_deforme = fft(s_deforme);

    % Composante continue avec son signe : partie réelle de la raie 0 Hz (= moyenne)
    offset_mesure = real(X_deforme(1)) / N;

    %  Signal corrigé
    s_corrige = s_deforme - offset_mesure;

    trace_resultats(ax_spectre, ax_correction, s_base, s_deforme, s_corrige, fe, 'OFFSET');
end
