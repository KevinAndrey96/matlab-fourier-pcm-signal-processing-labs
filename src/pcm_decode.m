function levels = pcm_decode(bitstream, bits)
    % PCM_DECODE Recovers quantizer levels from a PCM bitstream.
    %
    %   levels = pcm_decode(bitstream, bits) is the inverse of pcm_encode:
    %   it groups the stream in words of bits digits, most significant bit
    %   first, and returns one level per word.

    if ~isnumeric(bits) || ~isscalar(bits) || bits < 1 || bits > 32 || mod(bits, 1) ~= 0
        error('signals:invalidBits', 'bits must be an integer between 1 and 32');
    end
    if mod(numel(bitstream), bits) ~= 0 || any(bitstream ~= 0 & bitstream ~= 1)
        error('signals:invalidBitstream', ...
              'bitstream must hold zeros and ones in words of %d bits', bits);
    end
    words = reshape(bitstream(:)', bits, []);
    levels = 2.^(bits - 1:-1:0) * words;
end
