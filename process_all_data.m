clear all; 
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Read the laser power data
laserpower = xlsread('C:\Users\Mallory\Documents\Lifetime spectroscopy\Experiments\July 7 2015\Experiment log.xlsx','Laser Power'); 
%column 1 = scan, column 6 = avg, column 7 = std

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Gather all the files from the current directory

% read all files with the extension .txt
files=dir('*.mat');
% read the name of all files and store as a column vector
filenames={files.name};
% number of files for import
number=length(filenames);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Read the data from each file
laserAvg_store = zeros(number,1); 
laserStd_store = zeros(number,1);  
lambda = zeros(number,1); 

figure; 

[m,n] = size(laserpower); 
[p,q] = size(temps); 

for i = 1:number
    load(filenames{i}); 
    
    T_store(i) = T;  
    product_store(i) = product; 
    
    %Find the laser power that matches this filename
    index = 0; 
    for j = 1:m
        if isempty(strfind(filenames{i},num2str(laserpower(j,1))))==0
            if index ==0
                index = j; 
            else 
                error('Problem matching laser power');
            end
        end
    end
    
    laserAvg_store(i) = laserpower(index,7); 
    laserStd_store(i) = laserpower(index,8); 
    
    %Find the window temperatures that match this filename
    index = []; 
    for j = 1:p
        if isempty(strfind(filenames{i},num2str(temps(j,2))))==0
            index = [index j];
        end
    end
    
    windowTs = temps(index',7);
    windowTs(find(windowTs)==0)=NaN; 
    windowT_store(i) = nanmean(windowTs); 
    lambda(i) = temps(index(1),4); 
end

[T_sorted,IX] = sort(T_store); 

for i = 1:number
    
    product_plot(i) = product_store(IX(i)); 
    
    laserAvg_plot(i) = laserAvg_store(IX(i)); 
    laserStd_plot(i) = laserStd_store(IX(i)); 
    windowT_plot(i) = windowT_store(IX(i)); 
    lambda_plot(i) = lambda(IX(i)); 
    
end


figure;
h(1)=plot(T_sorted,product_plot,'.'); 

xlabel('Temperature (K)'); 
ylabel('\sigma*\Deltan at t = 0'); 
title('5 ns rise time + 5 ns averaging'); 

%Take the first 5 ns averages and calculate the FCA coefficient assuming
%a constant generation rate for each measurement
%Take the average laser power and cut it according to the filters
T_NE06A = 24.13527517/100; %According to Thorlabs datasheet  
T_NE13A = 4.398539889/100; %According to Thorlabs datasheet
power_transmitted = laserAvg_plot.*T_NE06A.*T_NE13A; % uJ
% model = 'Sturm';
G_Green = length(power_transmitted); 
sigma = length(power_transmitted); 
laserStd_transmitted = laserStd_plot.*T_NE06A.*T_NE13A; %uJ

for i = 1:length(power_transmitted)

    [G_Green_hold,sG_Green_hold]=calcG_multipleR(power_transmitted(i)*1e-6,lambda_plot(i),260,T_sorted(i),windowT_plot(i),10,0.75,laserStd_transmitted(i)*1e-6,0.05);
    G_Green(i) = sum(G_Green_hold); 
    sG_Green(i) = sqrt(sum(sG_Green_hold.^2)); 
%     G_Sturm_hold = calcG_multipleR(power_transmitted(i)*1e-6,lambda_plot(i),260,T_sorted(i),windowT_plot(i),'Sturm',10,0.75);
%     G_Sturm(i) = sum(G_Sturm_hold); 
%     G_none(i) = calcG_noModel(power_transmitted(i)*1e-6,lambda(i),260);
    sigma(i) = product_plot(i)/G_Green(i); %cm2
    
end

figure;
plot(T_sorted,sigma,'o','MarkerSize',8);
xlabel('Temperature [K]','FontSize',20); 
ylabel('\sigma at t = 0 [cm^2]','FontSize',20);
title('FZ wafer with NE06A+NE13A filter','FontSize',20); 

figure;
semilogy(T_sorted,G_Green,'o'); 
xlabel('Temperature [K]','FontSize',20);
ylabel('Generation rate [cm^{-3}]','FontSize',20); 
legend('Green 2008');

figure;
errorbar(T_sorted,laserAvg_plot,laserStd_plot,'x');
hold all;
plot(T_sorted,power_transmitted,'s');
xlabel('Temperature [K]','FontSize',20);
ylabel('Laser Power [\muJ]','FontSize',20);

save('NE06A_NE13A_exp_5ns_noTdep_diffAvg_changeG_revGCalc_noQuartz_10R_wError_072215.mat','T_sorted','sigma','G_Green','product_plot','sG_Green'); 