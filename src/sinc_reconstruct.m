function x = sinc_reconstruct(samples, sample_times, t)
    % SINC_RECONSTRUCT Whittaker-Shannon interpolation of uniform samples.
    %
    %   x = sinc_reconstruct(samples, sample_times, t)
    %
    %   Evaluates x(t) = sum_n x[n] sinc((t - n Ts) / Ts) with the normalized
    %   sinc(u) = sin(pi u) / (pi u). It recovers a band-limited signal
    %   exactly when it was sampled above the Nyquist rate and the sum runs
    %   over all samples; with a finite record the error concentrates near
    %   the ends.

    if numel(samples) ~= numel(sample_times) || numel(samples) < 2
        error('signals:invalidSamples', 'samples and sample_times must match (>= 2 samples)');
    end
    ts = sample_times(2) - sample_times(1);
    if ~(ts > 0)
        error('signals:nonUniformSamples', 'sample_times must be increasing');
    end
    u = (t(:) - sample_times(:)') / ts;
    kernel = ones(size(u));
    nonzero = u ~= 0;
    kernel(nonzero) = sin(pi * u(nonzero)) ./ (pi * u(nonzero));
    x = reshape(kernel * samples(:), size(t));
end
