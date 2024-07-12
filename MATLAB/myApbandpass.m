function [y,xh] = myApbandpass (x, Wc, Wb,xh)
    % [y,xh] = myApbandpass (x, Wc, Wb, xh)
    % y = campione in input (x) filtrato
    % xh = ultimo coefficiente del filtro
    % Wc frequenza di centro banda normalizzata 0<Wc<1, 2*fc/fS.
    % Wb larghezza di banda normalizzata 0<Wb<1, 2*fb/fS.
    c = (tan(pi*Wb/2)-1) / (tan(pi*Wb/2)+1);
    d = -cos(pi*Wc);
    xh_new = x - d*(1-c)*xh(1) + c*xh(2);
    ap_y = -c * xh_new + d*(1-c)*xh(1) + xh(2);
    xh = [xh_new, xh(1)];
    y = 0.5 * (x - ap_y);
end