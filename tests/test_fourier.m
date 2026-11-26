function tests = test_fourier()
    tests = {@rect_pulse_has_half_values_at_edges, @analytic_spectrum_matches_known_values, ...
             @fft_spectrum_matches_the_analytic_transform, ...
             @fft_spectrum_keeps_the_phase_of_shifts, ...
             @filter_masks_select_the_right_bands, @lowpass_filter_smooths_the_pulse, ...
             @complementary_filters_add_up_to_the_signal, @validates_input};
end

function rect_pulse_has_half_values_at_edges()
    y = rect_pulse([-2, -1, -0.5, 0, 0.5, 1, 2], 1);
    assert_true(isequal(y, [0, 0.5, 1, 1, 1, 0.5, 0]), mat2str(y));
end

function analytic_spectrum_matches_known_values()
    a = 1.5;
    assert_close(rect_pulse_spectrum(0, a), 2 * a, 0, 'X(0) is the pulse area');
    zeros_at = (1:3) * pi / a;
    assert_true(all(abs(rect_pulse_spectrum(zeros_at, a)) < 1e-12), 'zeros at k pi / a');
end

function fft_spectrum_matches_the_analytic_transform()
    dt = 1e-3;
    t = -20:dt:20 - dt;
    [X, omega] = fourier_spectrum(rect_pulse(t, 1), t);
    window = abs(omega) <= 20;
    difference = max(abs(X(window) - rect_pulse_spectrum(omega(window), 1)));
    assert_true(difference < 5e-3, sprintf('max deviation %.3e', difference));
end

function fft_spectrum_keeps_the_phase_of_shifts()
    dt = 1e-3;
    t = -10:dt:10 - dt;
    shift = 2;
    [X, omega] = fourier_spectrum(rect_pulse(t - shift, 1), t);
    expected = rect_pulse_spectrum(omega, 1) .* exp(-1i * omega * shift);
    window = abs(omega) <= 10;
    assert_true(max(abs(X(window) - expected(window))) < 1e-2, 'shift theorem');
end

function filter_masks_select_the_right_bands()
    omega = -3:0.5:3;
    low = ideal_filter_mask(omega, 'lowpass', 1);
    band = ideal_filter_mask(omega, 'bandpass', [1, 2]);
    assert_true(isequal(low, double(abs(omega) <= 1)), 'lowpass');
    assert_true(isequal(ideal_filter_mask(omega, 'highpass', 1), 1 - low), 'highpass');
    assert_true(isequal(band, double(abs(omega) >= 1 & abs(omega) <= 2)), 'bandpass');
    assert_true(isequal(ideal_filter_mask(omega, 'bandstop', [1, 2]), 1 - band), 'bandstop');
end

function lowpass_filter_smooths_the_pulse()
    dt = 1e-2;
    t = -20:dt:20 - dt;
    x = rect_pulse(t, 1);
    y = apply_ideal_filter(x, t, 'lowpass', 40);
    assert_true(isreal(y) && isequal(size(y), size(x)), 'real output with input shape');
    overshoot = max(y) - 1;
    assert_true(overshoot > 0.08 && overshoot < 0.1, ...
                sprintf('Gibbs overshoot near 9%%, got %.3f', overshoot));
    assert_close(sum(y) * dt, 2, 1e-6, 'area is kept because X(0) passes');
end

function complementary_filters_add_up_to_the_signal()
    t = linspace(-5, 5, 1001);
    t = t(1:end - 1);
    x = rect_pulse(t, 1) .* cos(3 * t);
    low = apply_ideal_filter(x, t, 'lowpass', 2);
    high = apply_ideal_filter(x, t, 'highpass', 2);
    assert_true(max(abs(low + high - x)) < 1e-12, 'lowpass + highpass = identity');
end

function validates_input()
    assert_error_id(@() rect_pulse(0, 0), 'signals:invalidWidth');
    assert_error_id(@() rect_pulse_spectrum(0, -1), 'signals:invalidWidth');
    assert_error_id(@() fourier_spectrum([1, 2, 3], [0, 1]), 'signals:invalidSamples');
    assert_error_id(@() fourier_spectrum([1, 2, 3], [0, 1, 3]), 'signals:nonUniformSamples');
    assert_error_id(@() ideal_filter_mask(0, 'notch', 1), 'signals:invalidFilter');
    assert_error_id(@() ideal_filter_mask(0, 'lowpass', -1), 'signals:invalidCutoff');
    assert_error_id(@() ideal_filter_mask(0, 'bandpass', [2, 1]), 'signals:invalidCutoff');
end
