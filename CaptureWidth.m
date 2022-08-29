function [cw,k_cw,cw_r,Cw_max,WavePower] = CaptureWidth(WECpower,WaveAmplitude,WaveFrequency,WECRadius)
%%
% i = 1:31;
% WECpower = AvPower(i);
% WaveAmplitude = M(i).Amplitude;
% WaveFrequency = M(i).RegFrequency;
% WECRadius = WECRadius;

%%
g = 9.81;
rho = 1000;
z = 3;


omega = 2*pi*WaveFrequency;

k = omega^2/g;

for i = 1:50
    k = (omega^2)/(g*tanh(k*z));
end

energy_density = 0.5*rho*g*WaveAmplitude^2; % Energy density of wave [Jm^-2]


c = omega/k;
n = 0.5*(1+2*k*z/sinh(2*k*z)); % assumes deep water
cg = n*c;

WavePower = energy_density*cg;
cw = WECpower/WavePower;

k_cw = k*cw;
cw_r = cw/(2*WECRadius);
Cw_max = 1/k;
end