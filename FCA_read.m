%{
MIT License

Copyright (c) [2016] [Mallory Ann Jensen, jensenma@alum.mit.edu]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
%}

% This Matlab script reads the output files from a free-carrier absoprtion
% measurement. The data is processed and save as raw data, carrier density,
% and then lifetime. 
clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define parameters
bin=1; % binning resolution
d=490*10^-4; % thickness of silicon wafer, cm
% define the cut-off injection level. signal at low injection levels 
% is very noisy
cutoff_inject=1.0e13; %cm^-3
%Define the cutoff time - this is similar to the above consideration
cutoff_t=1e-3; %s
T = 25+273.15; %sample temperature in K
FCA = 7.5e-18; %FCA cross-section to be used, cm^2. 7.5e-18 is the value determined by Sin Cheng's work.
inj_dep = 0; %Is the FCA cross-section injection dependent? This will also perform a correction for temperature if measurements are not made at room-temperature.
save_file='20150821_FCAData_bin1_5303_25C.mat'; %filename for .mat file with raw data for fitting

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

