function bitstream = pcm_encode(levels, bits)
    % PCM_ENCODE Serializes quantizer levels as a binary PCM bitstream.
    %
    %   bitstream = pcm_encode(levels, bits)
    %
    %   Each level in 0 .. 2^bits - 1 becomes bits binary digits, most
    %   significant bit first, and the words are concatenated in order. The
    %   result is a row vector of zeros and ones with numel(levels) * bits
    %   entries.

    if ~isnumeric(bits) || ~isscalar(bits) || bits < 1 || bits > 32 || mod(bits, 1) ~= 0
        error('signals:invalidBits', 'bits must be an integer between 1 and 32');
    end
    levels = levels(:)';
    if any(levels < 0 | levels > 2^bits - 1 | mod(levels, 1) ~= 0)
        error('signals:invalidLevels', 'levels must be integers between 0 and %d', 2^bits - 1);
    end
    weights = 2.^(bits - 1:-1:0)';
    words = mod(floor(levels ./ weights), 2);
    bitstream = words(:)';
end
