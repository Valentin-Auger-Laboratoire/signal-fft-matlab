function a = echelle_reference(x, Ai, Fi, fe)
% ECHELLE_REFERENCE Facteur signé a tel que x ≈ a * (signal de référence centré).
%   Seules les caractéristiques connues de la référence (Ai, Fi) sont utilisées,
%   jamais le signal de base lui-même :
%   |a|      : valeur efficace de x / valeur efficace de la référence, sqrt(sum(Ai.^2)/2)
%   signe(a) : phase de x sur la raie de l'harmonique dominante, comparée à celle
%              d'un sinus de phase nulle
%   Hypothèses : durée 1 s, Fi entières, distinctes et comprises entre 0 et fe/2 exclus.
    eff_ref = sqrt(sum(Ai(:).^2) / 2);
    if eff_ref == 0
        error('echelle_reference:reference', 'La référence doit contenir au moins une harmonique.');
    end

    N = length(x);
    X = fft(x);

    % Raie attendue d'un sinus Ai(i)*sin(2*pi*Fi(i)*t) : -j * Ai(i) * N/2
    [~, i] = max(abs(Ai));
    k = round(Fi(i) * N / fe) + 1;
    X_ref = -1i * Ai(i) * N / 2;
    signe = sign(real(X(k) / X_ref));

    a = signe * sqrt(mean((x - mean(x)).^2)) / eff_ref;
end
