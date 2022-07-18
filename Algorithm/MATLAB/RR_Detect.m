function bpm = RR_Detect(x, samplerate)
    n = length(x);
    T = 1 / samplerate;
    for i = 1:(n - 1)
        rr = (x(i + 1) - x(i)) * T;
        bpm(i) = 60/rr
    end

end