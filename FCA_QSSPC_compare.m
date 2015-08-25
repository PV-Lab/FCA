%% Load the raw data and plot
clear all; close all; 

filename = 'C:\Users\Mallory\Documents\Lifetime spectroscopy\Experiments\PA-3 no T-stage\2015-08Aug-24-16-3281\20150825_FCAData_bin25_3281_injDepFCA_25C.mat'; 
%The stored variables are t, deltan, datas, carrier, V0, and lifetime. The
%data has not been filtered before calculating lifetime. The data has been
%binned according to the file label. 

load(filename); 

%Plot the raw voltage
voltage = figure; 
plot(t,datas,'.'); 
xlabel('Time (s)'); 
ylabel('Voltage (V)'); 

%Plot the carrier density
carrier_density = figure; 
plot(t,deltan,'.'); 
xlabel('Time (s)'); 
ylabel('Carrier density (cm^-^3)'); 

%Read the QSSPC data
QSSPC = xlsread('C:\Users\Mallory\Documents\Lifetime spectroscopy\Experiments\PA-3 no T-stage\Sinton\PA-3 after FCA','RawData','E6:G126');
lifetimeQSSPC = QSSPC(:,1);
deltanQSSPC = QSSPC(:,3);

%Plot the lifetimes toether for comparison
lifetimes = figure;
loglog(deltanQSSPC,lifetimeQSSPC,'k-','LineWidth',3); 
hold all;
loglog(deltan,lifetime_raw,'.'); 
xlabel('\Deltan [cm^-^3]');
ylabel('Lifetime [s]');
legend('QSSPC','FCA');

%% Try a low-pass digital filter on the collected data
[coeff1,coeff2] = butter(1,.2);

testData = filtfilt(coeff1,coeff2,deltan); 

figure(carrier_density);
hold all; 
plot(t,testData,'-','LineWidth',3);

lifetime_filt = lifetime(testData,t); 

figure(lifetimes); 
loglog(testData,lifetime_filt,'.');

%% Plot Richter lifetime
deltan_ideal = logspace(13,18,500);
tau_intr = zeros(size(deltan_ideal));
N_dop = 5.7e15; 
type = 'p';
T = 25+273.15;

for i = 1:length(deltan_ideal)
    tau_intr(i) = Richter(T,deltan_ideal(i),N_dop,type);
end

hold all;
loglog(deltan_ideal,tau_intr,'--','LineWidth',3);





    
