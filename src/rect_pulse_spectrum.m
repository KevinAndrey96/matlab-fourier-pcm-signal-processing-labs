function spectrum = rect_pulse_spectrum(omega, a)
    % RECT_PULSE_SPECTRUM Analytic Fourier transform of rect_pulse(t, a).
    %
    %   spectrum = rect_pulse_spectrum(omega, a) = 2 a Sa(omega a), where
    %   Sa(x) = sin(x) / x and Sa(0) = 1. omega is angular frequency in rad/s.

    if ~isnumeric(a) || ~isscalar(a) || ~(a > 0) || ~isfinite(a)
        error('signals:invalidWidth', 'a must be a positive finite scalar');
    end
    argument = omega * a;
    spectrum = 2 * a * ones(size(omega));
    nonzero = argument ~= 0;
    spectrum(nonzero) = 2 * a * sin(argument(nonzero)) ./ argument(nonzero);
end
