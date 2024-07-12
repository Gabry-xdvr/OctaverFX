function [y,xh] = myAplowpass (x, Wc, xh)
% [y,xh] = myAplowpass (x, Wc, xh)
% Applica un filtraggio passa basso all'ingresso x
% i coefficienti del filtro vengono restituiti in uscita per essere
% messi in ingresso all'elaborazione del sample successivo
% Wc frequenza di taglio normalizzata 0<Wc<1
c = (tan(pi*Wc/2)-1) / (tan(pi*Wc/2)+1);
xh_new = x - c*xh;
ap_y = c * xh_new + xh;
xh = xh_new;
y = 0.5 * (x + ap_y);
end

