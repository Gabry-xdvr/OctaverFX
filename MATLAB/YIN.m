function pitch = YIN(in,fs,f0min,yinTolerance)
    blockSize = length(in);
    taumax = round(1/f0min*fs);
    yinLen = blockSize - taumax;
    yinTemp = zeros(1,taumax);
    % calcolo delle differenze quadrate
    for tau=1:taumax
        for j=1:yinLen
            yinTemp(tau) = yinTemp(tau) + (in(j) - in(j+tau))^2;
        end
    end
    % normalizzazione delle differenze quadrate
    tmp = 0;
    yinTemp(1) = 1;
    for tau=2:taumax
        tmp = tmp + yinTemp(tau);
        yinTemp(tau) = yinTemp(tau) *(tau/tmp);
    end
    % determino il pitch
    tau=1;
    while(tau<taumax)
        if(yinTemp(tau) < yinTolerance)
             % cerco il punto di inversione
             while (yinTemp(tau+1) < yinTemp(tau) && tau+2<taumax)
                 tau = tau+1;
             end
             pitch = fs/tau;
             break
        else
            tau = tau+1;
        end
             % se non è stato stimato
             pitch = 0;
    end
end