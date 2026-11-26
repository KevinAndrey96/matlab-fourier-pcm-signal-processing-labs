function y = apply_ideal_filter(x, t, kind, cutoff)
    % APPLY_IDEAL_FILTER Filters x(t) with an ideal filter in the frequency domain.
    %
    %   y = apply_ideal_filter(x, t, kind, cutoff)
    %
    %   Multiplies the FFT of the samples by ideal_filter_mask and returns the
    %   real part of the inverse FFT, which is the filtered signal for real
    %   inputs (the imaginary part is round-off). Cutoffs are in rad/s.

    if numel(x) ~= numel(t) || numel(t) < 2
        error('signals:invalidSamples', 'x and t must have the same number of samples (>= 2)');
    end
    dt = t(2) - t(1);
    n = numel(x);
    index = (0:n - 1) - floor(n / 2);
    omega = 2 * pi * index / (n * dt);
    mask = ideal_filter_mask(omega, kind, cutoff);
    filtered = ifftshift(fftshift(fft(x(:)')) .* mask);
    y = real(ifft(filtered));
    y = reshape(y, size(x));
end
