function tests = test_pcm()
    tests = {@quantizer_maps_to_cell_centers, @quantizer_saturates_out_of_range, ...
             @quantization_error_is_bounded, @snr_grows_six_db_per_bit, ...
             @encode_and_decode_round_trip, @encode_uses_msb_first_words, ...
             @line_codes_follow_their_definitions, @ami_has_no_dc_component, ...
             @manchester_has_a_transition_per_bit, ...
             @sinc_interpolation_recovers_band_limited_signals, ...
             @validates_input};
end

function quantizer_maps_to_cell_centers()
    [xq, levels] = uniform_quantizer([-1, -0.6, -0.1, 0, 0.3, 0.99], 1, 2);
    assert_true(isequal(levels, [0, 0, 1, 2, 2, 3]), mat2str(levels));
    assert_true(isequal(xq, [-0.75, -0.75, -0.25, 0.25, 0.25, 0.75]), mat2str(xq));
end

function quantizer_saturates_out_of_range()
    [xq, levels] = uniform_quantizer([-5, 1, 5], 1, 3);
    assert_true(isequal(levels, [0, 7, 7]), mat2str(levels));
    assert_close(xq(1), -0.875, 1e-15, 'lowest level');
end

function quantization_error_is_bounded()
    x = linspace(-1, 1, 1001);
    for bits = 1:8
        xq = uniform_quantizer(x, 1, bits);
        assert_true(max(abs(x - xq)) <= 2^-bits + 1e-15, sprintf('%d bits', bits));
    end
end

function snr_grows_six_db_per_bit()
    t = linspace(0, 1, 20001);
    x = sin(2 * pi * 7 * t + 0.1);
    for bits = [6, 8, 12]
        [measured, theoretical] = quantization_snr(x, uniform_quantizer(x, 1, bits), bits);
        assert_close(measured, theoretical, 0.3, sprintf('SQNR with %d bits', bits));
    end
end

function encode_and_decode_round_trip()
    levels = [0, 5, 7, 2, 1, 6];
    bitstream = pcm_encode(levels, 3);
    assert_true(numel(bitstream) == 18, 'three bits per level');
    assert_true(isequal(pcm_decode(bitstream, 3), levels), 'round trip');
end

function encode_uses_msb_first_words()
    assert_true(isequal(pcm_encode([6, 1], 3), [1, 1, 0, 0, 0, 1]), 'MSB first');
end

function line_codes_follow_their_definitions()
    bits = [1, 0, 1, 1];
    unipolar = line_code(bits, 'unipolar_nrz', 2);
    polar = line_code(bits, 'polar_nrz', 2);
    rz = line_code(bits, 'unipolar_rz', 2);
    bipolar = line_code(bits, 'bipolar_rz', 2);
    ami = line_code(bits, 'ami', 2);
    assert_true(isequal(unipolar, [1, 1, 0, 0, 1, 1, 1, 1]), 'unipolar NRZ');
    assert_true(isequal(polar, [1, 1, -1, -1, 1, 1, 1, 1]), 'polar NRZ');
    assert_true(isequal(rz, [1, 0, 0, 0, 1, 0, 1, 0]), 'unipolar RZ');
    assert_true(isequal(bipolar, [1, 0, -1, 0, 1, 0, 1, 0]), 'bipolar RZ');
    assert_true(isequal(ami, [1, 0, 0, 0, -1, 0, 1, 0]), 'AMI alternates marks');
    [~, t] = line_code(bits, 'polar_nrz', 10, 1000);
    assert_close(t(end), 39 / 10000, 1e-15, 'time axis follows the bit rate');
end

function ami_has_no_dc_component()
    bits = mod(1:64, 3) > 0;
    waveform = line_code(double(bits), 'ami', 10);
    marks = sum(bits);
    assert_true(mod(marks, 2) ~= 0 || abs(mean(waveform)) < 1e-12, 'balanced marks');
    assert_true(abs(sum(waveform)) <= 5, 'running sum stays within one pulse');
end

function manchester_has_a_transition_per_bit()
    bits = [1, 1, 0, 0, 1];
    waveform = line_code(bits, 'manchester', 4);
    middles = waveform(2:4:end) ~= waveform(3:4:end);
    assert_true(all(middles), 'mid-bit transition');
    assert_true(isequal(waveform(1:4), [-1, -1, 1, 1]), 'IEEE 802.3: 1 is low to high');
    assert_true(abs(mean(waveform)) < 1e-12, 'no DC component');
end

function sinc_interpolation_recovers_band_limited_signals()
    ts = 0.1;
    sample_times = -40:ts:40;
    signal = @(t) cos(2 * pi * 1.3 * t) + 0.5 * sin(2 * pi * 3.1 * t);
    t = linspace(-2, 2, 401);
    x = sinc_reconstruct(signal(sample_times), sample_times, t);
    assert_true(max(abs(x - signal(t))) < 0.02, 'reconstruction above Nyquist');
    at_samples = sinc_reconstruct(signal(sample_times), sample_times, sample_times(390:400));
    assert_true(max(abs(at_samples - signal(sample_times(390:400)))) < 1e-12, 'interpolates');
end

function validates_input()
    assert_error_id(@() uniform_quantizer(0, 0, 3), 'signals:invalidRange');
    assert_error_id(@() uniform_quantizer(0, 1, 0), 'signals:invalidBits');
    assert_error_id(@() pcm_encode(8, 3), 'signals:invalidLevels');
    assert_error_id(@() pcm_decode([1, 0], 3), 'signals:invalidBitstream');
    assert_error_id(@() line_code([1, 2], 'ami'), 'signals:invalidBitstream');
    assert_error_id(@() line_code([1, 0], 'ami', 3), 'signals:invalidSamplesPerBit');
    assert_error_id(@() line_code([1, 0], 'hdb3'), 'signals:invalidScheme');
    assert_error_id(@() sinc_reconstruct([1, 2], 0, 0), 'signals:invalidSamples');
end
