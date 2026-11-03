function [s_base, s_deforme, s_corrige, gain_mesure, offset_mesure] = correcteGAIN_OFFSET(M, Ai, Fi, fe, P0, P1, ax_spectre, ax_correction)
    if nargin < 7, ax_spectre = []; end
    if nargin < 8, ax_correction = []; end

    % 1. Signal de base (avec +1 pour observer le gain à 0 Hz)
    s_temp = gene_signal(M, Ai, Fi, fe, 0);
    s_base = (s_temp - mean(s_temp)) + 1;

    % 2. Application de la déformation GAIN + OFFSET (choix 3)
    choix_deformation = 3;
    s_deforme = deform_signal(s_base, choix_deformation, P0, P1);

    % 3. Calcul de la FFT
    N = length(s_deforme);
    X_deforme = fft(s_deforme);
    X_base    = fft(s_base);

    % 4. Estimation du Gain sur un pic alternatif (f > 0 Hz), où l'offset n'agit pas
    [pic, idx_peak] = max(abs(X_base(2:floor(N/2))));
    if isempty(pic) || pic == 0
        error('correcteGAIN_OFFSET:signal', 'Le signal doit contenir au moins une harmonique.');
    end
    idx_peak = idx_peak + 1; % Ajustement d'indice
    % Le module du rapport donne |P1|, sa phase (0 ou pi) donne le signe
    rapport = X_deforme(idx_peak) / X_base(idx_peak);
    gain_mesure = abs(rapport) * sign(cos(angle(rapport)));
    if gain_mesure == 0
        error('correcteGAIN_OFFSET:gain', 'Gain nul : la déformation n''est pas inversible.');
    end

    % Estimation de l'Offset à 0 Hz (composante continue signée, moins la contribution du gain sur le +1)
    offset_mesure = real(X_deforme(1)) / N - (1 * gain_mesure);

    % 5. Correction (Inverse des opérations : Retirer l'offset puis diviser par le gain)
    s_corrige = (s_deforme - offset_mesure) / gain_mesure;

    trace_resultats(ax_spectre, ax_correction, s_base, s_deforme, s_corrige, fe, 'GAIN + OFFSET');
end
