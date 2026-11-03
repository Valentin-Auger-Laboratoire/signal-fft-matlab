function sd = deform_signal(s, choix, P0, P1)
% DEFORM_SIGNAL Applique une déformation de la chaîne de mesure au signal s.
%   1 : offset            sd = s + P0
%   2 : gain              sd = P1 * s
%   3 : gain + offset     sd = P1 * s + P0
%   4 : offset + gain     sd = P1 * (s + P0)
%   5 : exponentielle     sd = P0 * exp(P1 * s)
%   6 : logarithme        sd = P0 + P1 * sign(s) .* log(1 + |s|)
    switch choix
        case 1
            % Offset (OFFSET)
            sd = s + P0;
        case 2
            % Gain
            sd = P1 * s;
        case 3
            % Gain + Offset
            sd = P1 * s + P0;
        case 4
            % Offset + Gain
            sd = P1 * (s + P0);
        case 5
            % Exponentielle
            sd = P0 * exp(P1 * s);
        case 6
            % Logarithme symétrique : défini aussi pour s < 0, et inversible
            sd = P0 + P1 * sign(s) .* log(1 + abs(s));
        otherwise
            sd = s;
    end
end
