function y = rect_pulse(t, a)
    % RECT_PULSE Rectangular pulse of half-width a centered at the origin.
    %
    %   y = rect_pulse(t, a) returns 1 where |t| < a, 1/2 where |t| == a and
    %   0 elsewhere. The half value at the edges is the convention that makes
    %   the inverse Fourier transform converge pointwise.

    if ~isnumeric(a) || ~isscalar(a) || ~(a > 0) || ~isfinite(a)
        error('signals:invalidWidth', 'a must be a positive finite scalar');
    end
    y = double(abs(t) < a);
    y(abs(t) == a) = 0.5;
end
