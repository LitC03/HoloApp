function [phase] = GS_routine(target,source,n_iter)
A = ifft2(target);
old_A = A;
for a = 1:n_iter
    B = source.*exp(1i.*angle(A));
    C = fft2(B);
    D = target.*exp(1i.*angle(C));
    A = ifft2(D);
    if isequal(A,old_A)
        break
    end
    old_A = A;
end
phase = angle(A);
