function z = soft_threshold(v, threshold)
    z = sign(v) .* max(abs(v) - threshold, 0);
end
