function [xq, levels] = uniform_quantizer(x, xmax, bits)
    % UNIFORM_QUANTIZER Mid-rise uniform quantizer with 2^bits levels.
    %
    %   [xq, levels] = uniform_quantizer(x, xmax, bits)
    %
    %   The range [-xmax, xmax] is split into L = 2^bits cells of width
    %   Delta = 2 xmax / L. Each sample maps to the center of its cell, so
    %   the error is at most Delta / 2 inside the range; samples outside it
    %   saturate to the first or last level.
    %
    %   xq      reconstructed values, same size as x
    %   levels  level indices 0 .. L - 1, ready for pcm_encode

    if ~isnumeric(xmax) || ~isscalar(xmax) || ~(xmax > 0) || ~isfinite(xmax)
        error('signals:invalidRange', 'xmax must be a positive finite scalar');
    end
    validate_bits(bits);

    count = 2^bits;
    delta = 2 * xmax / count;
    levels = floor((x + xmax) / delta);
    levels = min(max(levels, 0), count - 1);
    xq = -xmax + (levels + 0.5) * delta;
end

function validate_bits(bits)
    if ~isnumeric(bits) || ~isscalar(bits) || bits < 1 || bits > 32 || mod(bits, 1) ~= 0
        error('signals:invalidBits', 'bits must be an integer between 1 and 32');
    end
end
