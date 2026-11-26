function mask = ideal_filter_mask(omega, kind, cutoff)
    % IDEAL_FILTER_MASK Frequency response of an ideal (brick-wall) filter.
    %
    %   mask = ideal_filter_mask(omega, kind, cutoff)
    %
    %   kind    'lowpass' or 'highpass' with a scalar cutoff wc, or
    %           'bandpass' or 'bandstop' with cutoff = [w1, w2], w1 < w2
    %   mask    1 where the filter passes |omega| and 0 where it rejects it;
    %           the response is even in omega, as for any real filter

    magnitude = abs(omega);
    switch kind
        case {'lowpass', 'highpass'}
            if ~isnumeric(cutoff) || ~isscalar(cutoff) || ~(cutoff > 0)
                error('signals:invalidCutoff', '%s needs a positive scalar cutoff', kind);
            end
            mask = magnitude <= cutoff;
            if strcmp(kind, 'highpass')
                mask = ~mask;
            end
        case {'bandpass', 'bandstop'}
            if ~isnumeric(cutoff) || numel(cutoff) ~= 2 || ~(cutoff(1) >= 0) || ...
               ~(cutoff(2) > cutoff(1))
                error('signals:invalidCutoff', ...
                      '%s needs cutoff = [w1, w2] with 0 <= w1 < w2', kind);
            end
            mask = magnitude >= cutoff(1) & magnitude <= cutoff(2);
            if strcmp(kind, 'bandstop')
                mask = ~mask;
            end
        otherwise
            error('signals:invalidFilter', ...
                  'kind must be lowpass, highpass, bandpass or bandstop');
    end
    mask = double(mask);
end
