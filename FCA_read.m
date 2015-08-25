% This Matlab script reads the output files from a free-carrier absoprtion
% measurement. The data is processed and save as raw data, carrier density,
% and then lifetime. 
clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define parameters
bin=25; % binning resolution
d=240*10^-4; % thickness of silicon wafer, cm
% define the cut-off injection level. signal at low injection levels 
% is very noisy
cutoff_inject=1.0e13; %cm^-3
%Define the cutoff time - this is similar to the above consideration
cutoff_t=10e-3; %s
T = 25+273.15; %sample temperature in K
FCA = 7.5e-18; %FCA cross-section to be used, cm^2. 7.5e-18 is the value determined by Sin Cheng's work.
inj_dep = 1; %Is the FCA cross-section injection dependent? This will also perform a correction for temperature if measurements are not made at room-temperature.
save_file='20150825_FCAData_bin25_3281_injDepFCA_25C.mat'; %filename for .mat file with raw data for fitting

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

