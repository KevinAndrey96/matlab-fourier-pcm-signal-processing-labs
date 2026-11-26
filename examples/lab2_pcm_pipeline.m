function lab2_pcm_pipeline(output_dir)
    % LAB2_PCM_PIPELINE Sampling, quantization, PCM coding, line codes and
    % sinc reconstruction of a band-limited signal.
    %
    %   lab2_pcm_pipeline()            shows the figures
    %   lab2_pcm_pipeline(output_dir)  saves them as PNG files instead

    here = fileparts(mfilename('fullpath'));
    addpath(fullfile(here, '..', 'src'));
    if nargin < 1
        output_dir = '';
    end
    hidden = ~isempty(output_dir);

    signal = @(t) 0.7 * sin(2 * pi * t) + 0.25 * sin(2 * pi * 3 * t + 0.4);
    max_frequency = 3;
    fs = 8 * max_frequency;
    bits = 3;
    duration = 2;

    sample_times = 0:1 / fs:duration;
    samples = signal(sample_times);
    [quantized, levels] = uniform_quantizer(samples, 1, bits);
    bitstream = pcm_encode(levels, bits);
    assert(isequal(pcm_decode(bitstream, bits), levels));

    fine = linspace(0, duration, 2001);
    reconstructed = sinc_reconstruct(quantized, sample_times, fine);
    middle = fine > 0.5 & fine < duration - 0.5;
    [measured, theoretical] = quantization_snr(samples, quantized, bits);

    fprintf('Lab 2: PCM with fs = %g Hz (Nyquist %g Hz), %d bits, %d levels\n', ...
            fs, 2 * max_frequency, bits, 2^bits);
    fprintf('  %d samples -> %d bits, bit rate %g bit/s\n', numel(samples), ...
            numel(bitstream), fs * bits);
    fprintf('  SQNR measured %.2f dB, full-scale sine rule %.2f dB\n', measured, theoretical);
    fprintf('  max reconstruction error away from the edges: %.3f\n', ...
            max(abs(reconstructed(middle) - signal(fine(middle)))));

    pipeline = new_figure(hidden);
    subplot(2, 1, 1);
    plot(fine, signal(fine), 'Color', [0.6, 0.6, 0.6], 'LineWidth', 1.5);
    hold on;
    stem(sample_times, samples, 'b', 'MarkerSize', 3);
    stairs(sample_times, quantized, 'r', 'LineWidth', 1.2);
    hold off;
    grid on;
    legend('x(t)', 'muestras', sprintf('cuantizada (%d bits)', bits), 'Location', 'southwest');
    title(sprintf('Muestreo a %g Hz y cuantización uniforme', fs));
    xlabel('t [s]');
    subplot(2, 1, 2);
    plot(fine, signal(fine), 'Color', [0.6, 0.6, 0.6], 'LineWidth', 1.5);
    hold on;
    plot(fine, reconstructed, 'b', 'LineWidth', 1.2);
    hold off;
    grid on;
    legend('x(t)', 'reconstrucción sinc', 'Location', 'southwest');
    title('Recuperación por interpolación de Whittaker-Shannon');
    xlabel('t [s]');
    export(pipeline, output_dir, 'lab2-pcm.png');

    schemes = {'unipolar_nrz', 'polar_nrz', 'unipolar_rz', 'bipolar_rz', 'ami', 'manchester'};
    names = {'Unipolar NRZ', 'Polar NRZ', 'Unipolar RZ', 'Bipolar RZ', 'AMI', 'Manchester'};
    first_bits = bitstream(1:12);
    codes = new_figure(hidden);
    for k = 1:numel(schemes)
        [waveform, t] = line_code(first_bits, schemes{k}, 100);
        subplot(3, 2, k);
        plot(t, waveform, 'b', 'LineWidth', 1.3);
        axis([0, numel(first_bits), -1.3, 1.3]);
        grid on;
        title(sprintf('%s: %s', names{k}, sprintf('%d', first_bits)));
        xlabel('bit');
    end
    export(codes, output_dir, 'lab2-line-codes.png');
end

function handle = new_figure(hidden)
    if hidden
        handle = figure('Visible', 'off', 'Position', [0, 0, 960, 640]);
    else
        handle = figure('Position', [0, 0, 960, 640]);
    end
end

function export(handle, directory, name)
    if ~isempty(directory)
        print(handle, fullfile(directory, name), '-dpng', '-r110');
        close(handle);
    end
end
