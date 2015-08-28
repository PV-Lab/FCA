function [G_Green,sigma,laserAvg_store,laserStd_store,power_transmitted,lhs_store]=extract_sigFCA

clear all; 
close all;

d = 260e-4; %cm, sample thickness
cutoff = 0.001; %filter design cutoff

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Read the laser power data
laserpower = xlsread('C:\Users\Mallory\Documents\Lifetime spectroscopy\Experiments\FCA coeff August 27 2015\Experiment log.xlsx','Laser Power'); 
%column 1 = scan, column 4 = lambda, column 7 = avg, column 8 = std

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Read the log sample data
sample_log = xlsread('C:\Users\Mallory\Documents\Lifetime spectroscopy\Experiments\FCA coeff August 27 2015\Experiment log.xlsx','Log files+T'); 
%column 2 = scan, column 4 = lambda, column 6 = filters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Gather all the files from the current directory

% read all files with the extension .txt
files=dir('*.mat');
% read the name of all files and store as a column vector
filenames={files.name};
% number of files for import
number=length(filenames);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Read the data from each file and store it
%For the .mat files as of 8/28/15 - the contents include V0, carrier,
%datas, deltan, lifetime_raw, and t. 
laserAvg_store = zeros(number,1); 
laserStd_store = zeros(number,1);  
lambda = zeros(number,1); 
V0_store = zeros(number,1); 
carrier_store = cell(number,1); 
t_store = cell(number,1); 
filters_store = zeros(number,1); 
diameter_store = zeros(number,1); 

[m,n] = size(laserpower); 
[p,q] = size(sample_log);

for i = 1:number
    load(filenames{i}); 
    
    V0_store(i) = V0; 
    carrier_store{i} = carrier;
    t_store{i} = t; 
    
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
    lambda(i) = laserpower(index,4); 
    diameter_store(i) = laserpower(index,12);
    
    %Find the filter combination that match this filename
    index = 0; 
    for j = 1:p
        if isempty(strfind(filenames{i},num2str(sample_log(j,2))))==0
            if index ==0
                index = j; 
            else 
                error('Problem matching laser power');
            end
        end
    end 
    
    filters_store(i) = sample_log(index,6); 
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Process the data to extract sigma FCA

%Take the first part of the curve calculate the FCA coefficient assuming
%a constant generation rate for each measurement
lhs_store = zeros(size(laserAvg_store)); %this vector will store the left hand side of the sigma_FCA equation
G_Green = zeros(size(laserAvg_store));
sG_Green = zeros(size(laserAvg_store)); 
sigma = zeros(size(laserAvg_store));
power_transmitted = zeros(size(laserAvg_store));

for i = 1:length(laserAvg_store)
    
    carrier = carrier_store{i};
    t = t_store{i}; 
    
    %Let's filter the data for a better result
    [coeff1,coeff2] = butter(1,cutoff);
    carrier_filt = filtfilt(coeff1,coeff2,carrier); 
    
    %Find the maximum value of the data and then take the average of 2
    %points on either side
    max_index = find(carrier_filt == max(carrier_filt)); 
    max_values = carrier_filt(max_index-2:max_index+2); 
    max_avg = mean(max_values);
    
    figure;
    plot(t,carrier);
    hold all;
    plot(t,carrier_filt);
    hold all;
    plot(t(max_index),max_avg,'o','MarkerSize',8); 
    xlabel('Time (s)'); 
    ylabel('-log(1-V/V_0)'); 
    
    lhs_store(i) = max_avg/d; 
    
    %Get the right hand side of the equation - the carrier density
    if filters_store(i)==1
        T = NDfilters('NE05A',lambda(i)); 
    elseif filters_store(i)==2
        T = NDfilters('NE06A',lambda(i)); 
    elseif filters_store(i)==3
        T = NDfilters('NE10A',lambda(i)); 
    elseif filters_store(i)==4
        T = NDfilters('NE13A',lambda(i)); 
    elseif filters_store(i)==5
        T1 = NDfilters('NE05A',lambda(i)); 
        T2 = NDfilters('NE06A',lambda(i));
        T = T1*T2;
    elseif filters_store(i)==6
        T1 = NDfilters('NE06A',lambda(i)); 
        T2 = NDfilters('NE10A',lambda(i));
        T = T1*T2;
    elseif filters_store(i)==7
        T1 = NDfilters('NE06A',lambda(i)); 
        T2 = NDfilters('NE13A',lambda(i));
        T = T1*T2;
    elseif filters_store(i)==0
        T=1;
    else
        disp('Did not succeed at finding transmission');
    end
    
    power_transmitted(i) = laserAvg_store(i)*T; %uJ
    std_transmitted = laserStd_store(i)*T; %uJ

    [G_Green_hold,sG_Green_hold]=calcG_multipleR(power_transmitted(i)*1e-6,lambda(i),d,25+273.15,25+273.15,10,diameter_store(i),std_transmitted*1e-6,0.05);
    
    G_Green(i) = sum(G_Green_hold); 
    sG_Green(i) = sqrt(sum(sG_Green_hold.^2)); 
    
    sigma(i) = lhs_store(i)/G_Green(i); 

end

figure;
plot(G_Green,sigma,'o','MarkerSize',8);
xlabel('Carrier density [cm^-^3]','FontSize',20); 
ylabel('\sigma at t = 0 [cm^2]','FontSize',20);
title('FZ wafer with no passivation','FontSize',20); 

figure;
errorbar(laserAvg_store,laserStd_store,'x');
hold all;
plot(power_transmitted,'s');
xlabel('Measurement','FontSize',20);
ylabel('Laser Power [\muJ]','FontSize',20);

% save('NE06A_NE13A_exp_5ns_noTdep_diffAvg_changeG_revGCalc_noQuartz_10R_wError_072215.mat','T_sorted','sigma','G_Green','product_plot','sG_Green'); 