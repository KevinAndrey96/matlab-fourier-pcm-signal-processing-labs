function [spectrum, omega] = fourier_spectrum(x, t)
    % FOURIER_SPECTRUM Approximates the continuous Fourier transform of x(t)
    % from uniform samples with the FFT.
    %
    %   [spectrum, omega] = fourier_spectrum(x, t)
    %
    %   x  samples of the signal at the uniformly spaced instants t
    %   spectrum  approximation of X(omega) = integral of x(t) exp(-j omega t) dt,
    %             centered so that omega runs from negative to positive frequencies
    %
    %   The FFT is multiplied by the sampling interval dt and by the phase
    %   factor exp(-j omega t(1)) so that signals that do not start at t = 0
    %   keep the correct phase. omega is in rad/s with resolution
    %   2 pi / (N dt).

    if numel(x) ~= numel(t) || numel(t) < 2
        error('signals:invalidSamples', 'x and t must have the same number of samples (>= 2)');
    end
    steps = diff(t(:)');
    dt = steps(1);
    if ~(dt > 0) || any(abs(steps - dt) > 1e-9 * max(1, abs(dt)))
        error('signals:nonUniformSamples', 't must be increasing and uniformly spaced');
    end

    n = numel(x);
    index = (0:n - 1) - floor(n / 2);
    omega = 2 * pi * index / (n * dt);
    raw = fftshift(fft(x(:)'));
    spectrum = dt * raw .* exp(-1i * omega * t(1));
end
