function [s_base, s_deforme, s_corrige, gain_mesure, offset_mesure] = correcteOFFSET_GAIN(M, Ai, Fi, fe, P0, P1, ax_spectre, ax_correction)
    if nargin < 7, ax_spectre = []; end
    if nargin < 8, ax_correction = []; end

    % 1. Signal de base (avec +1 pour observer la composante)
    s_temp = gene_signal(M, Ai, Fi, fe, 0);
    s_base = (s_temp - mean(s_temp)) + 1;

    % 2. Application de la déformation OFFSET + GAIN (choix 4)
    choix_deformation = 4;
    s_deforme = deform_signal(s_base, choix_deformation, P0, P1);

    % 3. Calcul de la FFT
    N = length(s_deforme);
    X_deforme = fft(s_deforme);
    X_base    = fft(s_base);

    % 4. Estimation du Gain sur un pic AC (f > 0 Hz)
    [pic, idx_peak] = max(abs(X_base(2:floor(N/2))));
    if isempty(pic) || pic == 0
        error('correcteOFFSET_GAIN:signal', 'Le signal doit contenir au moins une harmonique.');
    end
    idx_peak = idx_peak + 1;
    % Le module du rapport donne |P1|, sa phase (0 ou pi) donne le signe
    rapport = X_deforme(idx_peak) / X_base(idx_peak);
    gain_mesure = abs(rapport) * sign(cos(angle(rapport)));
    if gain_mesure == 0
        error('correcteOFFSET_GAIN:gain', 'Gain nul : la déformation n''est pas inversible.');
    end

    % Estimation de l'Offset (l'offset a été multiplié par le gain), composante continue signée
    offset_mesure = (real(X_deforme(1)) / N / gain_mesure) - 1;

    % 5. Correction (Inverse des opérations : Diviser par le gain puis retirer l'offset)
    s_corrige = (s_deforme / gain_mesure) - offset_mesure;

    trace_resultats(ax_spectre, ax_correction, s_base, s_deforme, s_corrige, fe, 'OFFSET + GAIN');
end
