function lab1_fourier_filters(output_dir)
    % LAB1_FOURIER_FILTERS Rectangular pulse, its spectrum and ideal filters.
    %
    %   lab1_fourier_filters()            shows the figures
    %   lab1_fourier_filters(output_dir)  saves them as PNG files instead
    %
    %   Compares the analytic transform 2 a Sa(omega a) with the FFT
    %   approximation and filters the pulse with the four ideal filters.

    here = fileparts(mfilename('fullpath'));
    addpath(fullfile(here, '..', 'src'));
    if nargin < 1
        output_dir = '';
    end
    save_figures = ~isempty(output_dir);

    a = 1;
    dt = 1e-2;
    t = -20:dt:20 - dt;
    x = rect_pulse(t, a);
    [X, omega] = fourier_spectrum(x, t);
    window = abs(omega) <= 15;
    deviation = max(abs(X(window) - rect_pulse_spectrum(omega(window), a)));
    fprintf('Lab 1: rectangular pulse with a = %g, %d samples, dt = %g s\n', a, numel(t), dt);
    fprintf('  max |FFT - 2a Sa(omega a)| for |omega| <= 15 rad/s: %.2e\n', deviation);

    spectrum_figure = new_figure(save_figures);
    subplot(2, 1, 1);
    plot(t, x, 'b', 'LineWidth', 1.5);
    axis([-3, 3, -0.2, 1.2]);
    grid on;
    title('Pulso rectangular x(t), a = 1');
    xlabel('t [s]');
    subplot(2, 1, 2);
    plot(omega(window), rect_pulse_spectrum(omega(window), a), 'r', 'LineWidth', 2);
    hold on;
    plot(omega(window), real(X(window)), 'k--', 'LineWidth', 1.2);
    hold off;
    grid on;
    legend('2a Sa(\omega a) teórica', 'FFT escalada');
    title('Transformada de Fourier');
    xlabel('\omega [rad/s]');
    export(spectrum_figure, output_dir, 'lab1-spectrum.png');

    filters = {'lowpass', 4; 'highpass', 4; 'bandpass', [2, 6]; 'bandstop', [2, 6]};
    names = {'Pasa bajas, \omega_c = 4', 'Pasa altas, \omega_c = 4', ...
             'Pasa banda, [2, 6]', 'Suprime banda, [2, 6]'};
    filter_figure = new_figure(save_figures);
    for k = 1:size(filters, 1)
        y = apply_ideal_filter(x, t, filters{k, 1}, filters{k, 2});
        fprintf('  %-8s energy kept: %5.1f %%\n', filters{k, 1}, 100 * sum(y.^2) / sum(x.^2));
        subplot(2, 2, k);
        plot(t, x, 'Color', [0.75, 0.75, 0.75]);
        hold on;
        plot(t, y, 'b', 'LineWidth', 1.3);
        hold off;
        axis([-4, 4, -0.6, 1.3]);
        grid on;
        title(names{k});
        xlabel('t [s]');
    end
    export(filter_figure, output_dir, 'lab1-filters.png');
end

function handle = new_figure(hidden)
    if hidden
        handle = figure('Visible', 'off', 'Position', [0, 0, 960, 600]);
    else
        handle = figure('Position', [0, 0, 960, 600]);
    end
end

function export(handle, directory, name)
    if ~isempty(directory)
        print(handle, fullfile(directory, name), '-dpng', '-r110');
        close(handle);
    end
end
