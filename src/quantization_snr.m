function [measured, theoretical] = quantization_snr(x, xq, bits)
    % QUANTIZATION_SNR Signal-to-quantization-noise ratio in decibels.
    %
    %   [measured, theoretical] = quantization_snr(x, xq, bits)
    %
    %   measured     10 log10(mean(x.^2) / mean((x - xq).^2))
    %   theoretical  6.02 bits + 1.76 dB, the classic value for a full-scale
    %                sine through a uniform quantizer (each extra bit adds
    %                about 6 dB)

    noise = mean((x(:) - xq(:)).^2);
    if noise == 0
        measured = Inf;
    else
        measured = 10 * log10(mean(x(:).^2) / noise);
    end
    theoretical = 20 * log10(2) * bits + 10 * log10(1.5);
end
