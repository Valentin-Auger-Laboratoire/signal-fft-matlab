function [s_base, s_deforme, s_corrige, gain_mesure] = correcteGAIN(M, Ai, Fi, fe, P0, P1, ax_spectre, ax_correction)
    if nargin < 7, ax_spectre = []; end
    if nargin < 8, ax_correction = []; end

    %  Génération du signal de base
    s_temp = gene_signal(M, Ai, Fi, fe, 0);

    % Centrage du signal + ajout de +1 pour avoir une composante à 0 Hz
    s_base = (s_temp - mean(s_temp)) + 1;

    %  Application de la déformation GAIN (choix 2 = Gain P1)
    choix_deformation = 2;
    s_deforme = deform_signal(s_base, choix_deformation, P0, P1);

    %  Calcul de la FFT
    X_deforme = fft(s_deforme);
    X_base    = fft(s_base);

    %  Estimation du Gain à partir de la composante à 0 Hz
    % Le module du rapport donne |P1|, sa phase (0 ou pi) donne le signe
    rapport = X_deforme(1) / X_base(1);
    gain_mesure = abs(rapport) * sign(cos(angle(rapport)));
    if gain_mesure == 0
        error('correcteGAIN:gain', 'Gain nul : la déformation n''est pas inversible.');
    end

    %  Correction du Gain sur le signal déformé
    s_corrige = s_deforme / gain_mesure;

    trace_resultats(ax_spectre, ax_correction, s_base, s_deforme, s_corrige, fe, 'GAIN');
end
