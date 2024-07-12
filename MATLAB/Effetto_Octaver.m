clear

% carico il sample audio
[data,Fs]=audioread("guitar_riff.wav");
L = length(data);
t = 0:1/Fs:(L-1)/Fs;

% sinusoide per test
% durata = 2;
% Fs = 48000;
% fc = 8000;
% L = durata*Fs;
% t = 0:1/Fs:(L-1)/Fs;
% data = transpose(sin(2*pi*fc*t));

%%Chirp per test
% durata = 5;
% Fs = 48000;
% L = durata*Fs;
% fmax = 1500;
% fc = 80:(fmax-80)/L:fmax-(fmax-80)/L;
% t = 0:1/Fs:(L-1)/Fs;
% data = transpose(chirp(t, 100, durata, fmax));


%%% visualizzo il segnale in ingresso

figure; spectrogram(data(:,1),2048,1024,2048,Fs,"yaxis");
%figure; plot(t,data(:,1));

%% dati per l'elaborazione
xhf0 = 0;
fundamental = zeros(L,1); %array contenente l'armonica fondamentale
bpc = 1;    %coefficiente banda filtro principale
xhf = [0, 0]; %coefficienti del filtro relativo
gM = 1; % guadagno del segnale in ingresso
Q = 1;

gL = 3; %gain dell'ottava inferiore
low = zeros(L,1); %array contente l'ottava inferiore
Ql = 12;
bpl = 0.1;   %coefficiente banda filtro ottava bassa
xhl = [0,0]; %coefficienti del filtro relativo

gH = gL; %gain dell'ottava superiore
high = zeros(L,1); %array contenente l'ottava superiore
Qh = 3;
bph = 0.1;   %coefficiente banda filtro ottava alta
xhh = [0,0]; %coefficienti del filtro relativo

windowL = 1024; %% lunghezza della finestra per la stima di F0
windowOverlap = 8; % fattore di overlap delle finestre

% parametri per la generazione dell'onda quadra modulata dalla f0
moduloCounter = 0;
threshold = 1;
sThreshold = 0.5;

% array contenente le frequenze stimate
fArray =zeros(1,L);

%f0 stimata non filtrata
f0nf = 0;
%f0 stimata filtrata
f0 = 0;
% minima frequenza accettabile
fMin = 100;
%soglia YIN
yinThreshold = 0.1;
%% Elaborazione del segnale

for i=1 : L
    % stimo il pitch in finestre di lunghezza windowL che si overlappano

    if((mod(i,windowL/windowOverlap)==1)&&(i+windowL<L))
        f0nf = YIN(data(i:i+windowL),Fs,fMin,yinThreshold);
        if (f0nf < fMin )
            f0nf = f0;
        else
            f0 = f0nf;
        end
        [f0,xhf0] = myAplowpass(f0,0.1,xhf0);
    end
    %array per capire l'andamento del pitch stimato nel tempo
    
    fArray(i) = f0;
    
    % Filtro il segnale in ingresso attorno alla f0 stimata
    fb = f0/Q;
    [fundamental(i),xhf] = myApbandpass(data(i),2*f0/(Fs),fb/Fs,xhf);

    %Genero i campioni di segnale contenenti le armoniche superiori
    rawH = abs(fundamental(i));
    
    %Genero il segnale a dente di sega modulato dalla frequenza stimata
    increment = f0/(2*Fs);
    moduloCounter = moduloCounter + increment;
    if moduloCounter > threshold
        moduloCounter = moduloCounter - threshold;
    end
    %modulo il segnale con un'"onda quadra" con periodo e duty cycle
    %comandato dal sawtooth
    if ((moduloCounter < sThreshold))%&&(fundamental(i)>0))
        rawL = fundamental(i);
    else
        rawL = 0;
    end
    fbl = f0/Ql;
    % estraggo l'ottava inferiore
    [low(i),xhl] = myApbandpass(rawL,f0/(Fs),fbl/Fs,xhl);
    fbh = f0/Qh;
    %estraggo l'ottava superiore
    [high(i),xhh] = myApbandpass(rawH,4*f0/(Fs),fbh/Fs,xhh);

end

% segnale contenente le ottave create
HL = gH*high+ gL*low;
% segnale complessivo
out = gM*data + gH*high + gL*low;
%% risultati
figure; plot(t,fArray);
%figure; plot(t,gL.*low(:,1));
%figure; plot(t,gH.*high(:,1));
%figure; spectrogram(fundamental(:,1),1024,512,1024,Fs,"yaxis");
%figure; spectrogram(gL.*low(:,1),1024,512,1024,Fs,"yaxis");
%figure; spectrogram(gH.*high(:,1),1024,512,1024,Fs,"yaxis");
figure; spectrogram(out(:,1),2048,1024,2048,Fs,"yaxis");
%figure; spectrogram(HL(:,1),2048,1024,2048,Fs,"yaxis");