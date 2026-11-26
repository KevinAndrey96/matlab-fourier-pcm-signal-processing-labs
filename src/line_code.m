function [waveform, t] = line_code(bitstream, scheme, samples_per_bit, bit_rate)
    % LINE_CODE Converts a bitstream into a baseband line code waveform.
    %
    %   [waveform, t] = line_code(bitstream, scheme, samples_per_bit, bit_rate)
    %
    %   scheme           'unipolar_nrz', 'polar_nrz', 'unipolar_rz',
    %                    'bipolar_rz', 'ami' or 'manchester'
    %   samples_per_bit  samples per bit period (even, default 100)
    %   bit_rate         bits per second used for the time axis (default 1)
    %
    %   Levels: unipolar codes use {0, 1}; polar and bipolar codes use
    %   {-1, 1}; RZ codes return to zero for the second half of each bit; AMI
    %   sends zeros as 0 and alternates +1 and -1 for ones, which removes the
    %   DC component; Manchester (IEEE 802.3) sends a low-to-high transition
    %   for 1 and high-to-low for 0, which guarantees a transition per bit.

    if nargin < 3
        samples_per_bit = 100;
    end
    if nargin < 4
        bit_rate = 1;
    end
    if any(bitstream ~= 0 & bitstream ~= 1)
        error('signals:invalidBitstream', 'bitstream must hold zeros and ones');
    end
    if ~isnumeric(samples_per_bit) || ~isscalar(samples_per_bit) || samples_per_bit < 2 || ...
       mod(samples_per_bit, 2) ~= 0
        error('signals:invalidSamplesPerBit', 'samples_per_bit must be an even integer >= 2');
    end

    bits = bitstream(:)';
    half = samples_per_bit / 2;
    full = ones(1, samples_per_bit);
    return_to_zero = [ones(1, half), zeros(1, half)];

    switch scheme
        case 'unipolar_nrz'
            symbols = bits' * full;
        case 'polar_nrz'
            symbols = (2 * bits' - 1) * full;
        case 'unipolar_rz'
            symbols = bits' * return_to_zero;
        case 'bipolar_rz'
            symbols = (2 * bits' - 1) * return_to_zero;
        case 'ami'
            polarity = (-1).^(cumsum(bits) - 1);
            symbols = (bits .* polarity)' * return_to_zero;
        case 'manchester'
            low_to_high = [-ones(1, half), ones(1, half)];
            symbols = (2 * bits' - 1) * low_to_high;
        otherwise
            error('signals:invalidScheme', ['scheme must be unipolar_nrz, polar_nrz, ' ...
                                            'unipolar_rz, bipolar_rz, ami or manchester']);
    end

    waveform = reshape(symbols', 1, []);
    t = (0:numel(waveform) - 1) / (samples_per_bit * bit_rate);
end
