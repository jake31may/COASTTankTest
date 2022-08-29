function [dfFFT] = derivFFT(amplitude,sample_frequency)
%%
% i = 9;
% amplitude = T(i).Heave;
% time = T(i).Time;
% % %amplitude = T(i).Heave;
% % %time = t2;
% sample_frequency = 500;
% t2 = T(i).Time;
%%
f = amplitude;
%n = 2^nextpow2(length(f));
n = length(f);
L = n./sample_frequency;

fhat = fft(f,n);
PSD = fhat.*conj(fhat)/n;

keep = PSD > 100;

fhat_filt = fhat.*keep;

kappa = (2*pi/(L))*[-n/2:n/2-1];
%kappa = ((4*pi()^2)/(n*L)).*(0:n-1)%
kappa = fftshift(kappa'); % Re-order fft frequencies
dfhat = i*kappa.*fhat_filt;
dfFFT = real(ifft(dfhat));
%% Plotting commands
% figure
% % plot(x,f_dot,'k','LineWidth',1.5), hold on
%     % plot(x,dfFD,'b--','LineWidth',1.2)
% lt = length(time);
% plot(time,dfFFT(1:lt),'r-')
%v2 = resample(dfFFT,128,500);
%plot(t2,v2)