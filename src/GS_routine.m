function [phase] = GS_routine(target,source,n_iter)
A = ifft2(target);
for a = 1:n_iter
    B = source.*exp(1i.*angle(A));
    C = fft2(B);
    D = target.*exp(1i.*angle(C));
    A = ifft2(D);
end
phase = angle(A);
