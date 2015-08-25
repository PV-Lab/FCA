% This Matlab script reads the output files from a free-carrier absoprtion
% measurement. The data is processed and save as raw data, carrier density,
% and then lifetime. 
% clear all
% close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define parameters
bin=1; % binning resolution
d=240*10^-4; % thickness of silicon wafer, cm
% define the cut-off injection level. signal at low injection levels 
% is very noisy
cutoff_inject=1.0e13; %cm^-3
%Define the cutoff time - this is similar to the above consideration
cutoff_t=10e-3; %s
T = 25+273.15; %sample temperature in K
FCA = 7.5e-18; %FCA cross-section to be used, cm^2. 7.5e-18 is the value determined by Sin Cheng's work.
inj_dep = 0; %Is the FCA cross-section injection dependent? This will also perform a correction for temperature if measurements are not made at room-temperature.
save_file='20150825_FCAData_bin1_3281_25C.mat'; %filename for .mat file with raw data for fitting

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Read the data and do some initial processing

% read all files with the extension .plt
files=dir('*.txt');
% read the name of all files and store as a column vector
filenames={files.name};
% number of files for import
number=length(filenames);

% First, read experimental data from files
filename1=filenames{1};
filename2=filenames{2};
[deltan,t,datas,carrier,V0]=FCA_process(filename1,filename2,FCA,inj_dep,T,cutoff_inject,cutoff_t,bin,d);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Try some things with max values

figure;
subplot(2,1,1); 
product = carrier./d; 
plot(t,product); 

%Filter
sampling = length(t)/(max(t)-min(t)); 
cutoff = (1.7e7)/sampling/2; 
[coeff1,coeff2] = butter(1,cutoff);
product_filt = filtfilt(coeff1,coeff2,product); 

hold all;
plot(t,product_filt); 

subplot(2,1,2);
[m,n] = size(product_filt);
dcdt = zeros(size(product_filt)); 
for j = 3:(max(m,n)-2)
    x = t(j-2:j+2);
    y = product_filt(j-2:j+2);
    X = [x',ones(5,1)];
    fit = X\(y');
    dcdt(j) = fit(1);
end
plot(t(3:end),dcdt(3:end)); 

%Find the maximum value from the filtered data and then take the average of 2 points on either side 
max_index = find(product_filt==max(product_filt)); 
max_values = product_filt(max_index-2:max_index+2); 
max_avg = mean(max_values); 

subplot(2,1,1); 
hold all; 
plot(t(max_index),max_avg,'o','MarkerSize',8); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate the lifetime

%First with the unfiltered data
lifetime_raw = lifetime(deltan,t); 

%Plot the results so that we can see them
figure;
loglog(deltan,lifetime_raw,'.'); 
xlabel('\Deltan [cm^-^3]');
ylabel('Lifetime [s]');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Save all of our results
save(save_file,'t','deltan','datas','carrier','V0','lifetime_raw');

