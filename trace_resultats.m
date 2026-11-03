function trace_resultats(ax_spectre, ax_correction, s_base, s_deforme, s_corrige, fe, nom)
% TRACE_RESULTATS Trace les spectres (base / déformé) et la correction temporelle.
%   Un axe vide ([]) n'est pas tracé.
    N = length(s_base);

    %  Spectres du signal déformé et du signal de base
    if ~isempty(ax_spectre)
        N2 = floor(N/2);
        f = (0:N2-1) * fe / N;
        S_deforme = abs(fft(s_deforme)) / N;
        S_base    = abs(fft(s_base)) / N;

        hold(ax_spectre, 'off');
        stem(ax_spectre, f, S_deforme(1:N2), 'r', 'LineWidth', 2, 'DisplayName', 'Signal Déformé');
        hold(ax_spectre, 'on');
        % Décalé de 0,1 Hz pour rester visible sous le spectre déformé
        stem(ax_spectre, f + 0.1, S_base(1:N2), 'b--', 'LineWidth', 1.2, 'DisplayName', 'Signal de base (+0,1 Hz)');

        grid(ax_spectre, 'on');
        xlabel(ax_spectre, 'Fréquence (Hz)');
        ylabel(ax_spectre, '|S(f)|');
        title(ax_spectre, ['Spectre : ' nom]);
        legend(ax_spectre, 'show');
    end

    %  Signal d'origine (s_base) et signal corrigé
    if ~isempty(ax_correction)
        t = (0:N-1) / fe;

        hold(ax_correction, 'off');
        plot(ax_correction, t, s_base, 'b--', 'LineWidth', 1.2, 'DisplayName', 'Signal Origine');
        hold(ax_correction, 'on');
        plot(ax_correction, t, s_corrige, 'g', 'LineWidth', 1.5, 'DisplayName', 'Signal Corrigé');

        grid(ax_correction, 'on');
        xlabel(ax_correction, 'Temps (s)');
        ylabel(ax_correction, 'Amplitude');
        title(ax_correction, ['Correction ' nom]);
        legend(ax_correction, 'show');
    end
end
