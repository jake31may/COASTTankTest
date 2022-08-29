function RAO = FFT_RAO(z,w,sample_frequency)
%% 
% i = 9;
% z = H(i).Heave;
% w = H(i).WaveAmp;
% sample_frequency=500;

n = length(z);

if mod(n,2) == 1
    n = n+1;
end

% Perform FFT 
zhat = fftshift(fft(z,n,1));
zhat = [abs(zhat(1+n/2:n))]';

what = fftshift(fft(w,n,1));
what = [abs(what(1+n/2:n))]';

% Filter low peaks
PSDz = zhat.*conj(zhat)/n;

keepZ = PSDz>10000;
PSDz = PSDz.*keepZ;

PSDw = what.*conj(what)/n;
keepW = PSDw>100;
PSDw = PSDw.*keepW;

df = sample_frequency/n;
f = 0:df:(sample_frequency/2 - df);
%%
% figure(11)
% plot(PSDz), hold on
% plot(PSDw)
%%
response_fz = find(zhat==max(zhat),1)
response_fw = find(what==max(what),1)
f(response_fw)


% avPSDz = trapz(PSDz(response_fz-5:response_fz+5))/df
% avPSDw = trapz(PSDw(response_fw-5:response_fw+5))/df

RAO = zhat(response_fz)/what(response_fw)
% RAOav = sqrt(avPSDz/avPSDw)

end
