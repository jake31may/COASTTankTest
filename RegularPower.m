function [Mean_Power] = RegularPower(force,heave,sample_frequency)

%%
% i = 7;
% heave = T(i).Heave;
% sample_frequency = [500,128];
% force = 4.1;

%velocity = gradient(heave,(1/sample_frequency(1)))./1000;

velocity = derivFFT(heave,sample_frequency(1))/1000;



%% Calculate Power

InstaPower = abs(force.*velocity);
Mean_Power = trapz(InstaPower)/length(InstaPower);
%plot(InstaPower)
%% Identify peaks
% 
% w = 0;
% threshold = 1.1;
% while w < 20
%     threshold = threshold - 0.01;
%     if threshold == 0
%         return
%     end
%     [PowerPeak, PowerElement] = findpeaks(InstaPower,"MinPeakProminence",threshold);
%     w = length(PowerPeak);
% end
% 
% % figure()
% % plot(InstaPower)
% % hold on
% % scatter(PowerElement,PowerPeak,'ro')
% % hold off
% 
% %% Calculate average power in n cycle blocks
% 
% n = 10; 
% 
% nPeaks = length(PowerPeak);
% Nblock = nPeaks - (n -1);
% BlockPower = zeros(Nblock,1);
% 
% for block = 1:Nblock
%     Peak1 = PowerElement(block);
%     Peak2 = PowerElement(block+n-1);
% 
%     BlockPower(block) = (1/(Peak2-Peak1)).*trapz(InstaPower(Peak1:Peak2));
% end
% 
% if length(BlockPower)>15
%     BlockPower(1:12) = [];
% end
% [P_sd,P_Mean] = std(BlockPower);
%%
% sd_3 = P_sd*3
% xgrid = linspace(P_Mean-sd_3,P_Mean+sd_3,5001);
% pd = fitdist((BlockPower),'Normal');
% PdEst = pdf(pd,xgrid);
% %Hs = xgrid(find(0.50>PdEst,1,'last'));
% 
% figure()
%     p = line(xgrid,PdEst,linewidth=2)
%     hold on 
%     histogram(BlockPower,50,"Normalization","pdf")
%     %l1 = line(linspace(0,Hs),repelem(0.5,100),'linewidth',1,'Color','r');
%     %l2 = line(repelem(Hs,100),linspace(0,0.5),'linewidth',1,'Color','r');
%     hold off
%     xlabel('Wave Height (m)','fontweight','bold')
%     ylabel('Normalised Cumulative Frequency ','fontweight','bold')
%     legend('Cumulative Frequency','70% - Hs')
%     grid on