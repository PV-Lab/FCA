%This Matlab function reads 2 filename (data and background) as input and 
%processes the experimental file generated by the oscilloscope in PVLAB and 
%returns transient decay of carriers 
%
%filename1 is baseline and filename2 is data 
%
%FCA is the baseline FCA cross-section to be used. This can be an
%injection dependent value. If so, enter 1 for "inj_dep." If the value
%should be injection-independent, enter 0 for "inj_dep." Corrections for
%injection dependence are made based on Isenberg 2004.
%
%T is the sample temperature during the measurement. This is only used if
%a correction is made for the FCA coefficient. If this is not desired,
%enter an arbitrary value. 
%
%cutoff_inject is the injection level below which the data will be too
%noisy to interpret later.
%
%cutoff_t is similar to the injection cutoff. Beyond this time, the data
%has hit the noise floor.
%
%bin is used to smooth the data. This defines the number of values which
%are averaged to produce the resulting curve.
%
%d is the thickness of the wafer in cm. 
%
%File outputs include: deltan (carrier density as function of time in
%cm^-3), t (time vector which matches deltan, carrier, and datas), datas
%(raw voltage data before it has been converted to a carrier density or
%some form of that), carrier (-log(1-voltage/V0)), and V0 (the calculated
%value at 100% absorption, corrected for voltage offset). 

function [deltan,t,datas,carrier,V0]= FCA_process(filename1,filename2,FCA,inj_dep,T,cutoff_inject,cutoff_t,bin,d)

%Reading the baseline file. This  measurement has been taken with the mono
%closed so that we are reading the "dark" voltage of the detector.
fid=fopen(filename1);
%extracting the baseline data
info1b=textscan(fid,'%[^:] %c %s',3);
info2b=textscan(fid,'%[^:] %c %f64',6);
info3b=textscan(fid,'%[^:] %c %s',11);
%reading the data file into an array until the strong 'Data:' with x being
%the time and y being the intensity
info4b=textscan(fid,'%[^:] %c',1);
datab=textscan(fid,'%f64');

%Extracting the parameter V0, which is the baseline voltage. Required so
%that we know what is the signal at 0% transmission.

%Reading the details for the x-axis or time axis
n=info2b{3}(1);
a=info2b{3}(4);
b=info2b{3}(3);
%Reconstruct the x-axis from the info given in the text file
tb=linspace(a,a+b,n)';

%Flip to be consistent with the later processing
datab{1}=-(datab{1});

%Fitting the baseline data with the a polynomial with degree 0 which is a
%straight line
%THIS COMMAND ASSUMES THAT THE TRANSMITTED DATA IS PROPERLY ZERO-ED USING
%THE VOFFSET OF THE AMPLIFIER. The labview code atuomatically takes into
%account the Voffset of the oscilloscope.
%We plot the data for transparency
figure;
plot(tb,datab{1});
title('Baseline offset - no probe beam, or 0% transmission'); 
fitb = polyfit(tb,datab{1},0);
%V0 is required to for free carrier concentration calculation
V0=fitb(1);
disp('At 100% absorption before offset correction');
fprintf('%d\n',V0)

%Read pumped data file 
fid=fopen(filename2);
%reading the data file into an array until the strong 'Data:'
info1=textscan(fid,'%[^:] %c %s',3);
info2=textscan(fid,'%[^:] %c %f64',6);
info3=textscan(fid,'%[^:] %c %s',11);
%reading the data file into an array until the strong 'Data:'
info4=textscan(fid,'%[^:] %c',1);
data=textscan(fid,'%f64');

%Reading the details for the x-axis or time axis
n=info2{3}(1);
a=info2{3}(4);
b=info2{3}(3);
%Reconstruct the x-axis from the info given in the text file
t=linspace(a,a+b,n);
t = t';

%Flip the data
data{1}=-(data{1});

%Plot the resulting raw data for clarity
figure;
semilogy(t,data{1})
title('Raw data (V) versus time'); 

%Remove the horizontal offset from the transmitted pump-ed data so that the
%decay curve goes to zero. To do this, we fit the negative time components
%with a straight line to obtain Voffest. 
index = find(t<0); 
offset = max(index)-500; %remove 500 points from the end to avoid skewing the fit

figure;
plot(t(1:offset),data{1}(1:offset));
title('Data offset - the data before the pulse arrives'); 

fit = polyfit(t(1:offset),data{1}(1:offset),0);
Voffset=fit;
disp('Offset voltage');
fprintf('%d\n',Voffset)
%Re-define corrected data
data{1}=data{1}-Voffset;
%Re-define the V0 of the baseline data too since both set of data has the
%same offset
V0=V0-Voffset; 

datas=data{1};

%Remove the last 2 entries to make no. of entries rounded up to nearest
%10000
datas = data{1}; 
remainder=rem(length(datas),bin); %remainder to be truncated
datas(end-remainder+1:end)=[]; %truncate the odd data points
t(end-remainder+1:end)=[]; %truncate the odd data points

%Bin the data to smooth it
datas = (1/bin)*sum(reshape(datas,bin,[]),1);
t=(1/bin)*sum(reshape(t,bin,[]),1);

%Remove data for t<5ns (account for rise time of detector)
ix=(t<5*10^-9);
datas(ix)=[];
t(ix)=[];
%Remove all negative values first
ix=(datas<0);
datas(ix)=[];
t(ix)=[];

%Throw out data that has time >cutoff_t 
ix=(t>cutoff_t);
datas(ix)=[];
t(ix)=[];

figure;
plot(t,datas); 
hold all;
plot([min(t) max(t)],[V0 V0],'--');
title('Corrected data (V) vs. time (s)'); 
legend('Measured','V_0');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computing the excess minority carrier concentration
carrier=-(log(1-(datas./V0)));
deltan = carrier./d./FCA; 


%We need to correct for the injection dependence if desired
if inj_dep == 1
    for i = 1:length(carrier)
        delta_carr_rev(i)=FCA_coeff(deltan(i),T,carrier(i),d);
    end
    deltan = delta_carr_rev; 
end

%Throw out data that has injection level <cutoff_inject 
ix=(deltan<cutoff_inject);
deltan(ix)=[];
datas(ix)=[];
t(ix)=[];
carrier(ix) = [];

%Throw out data that has time >cutoff_t 
ix=(t>cutoff_t);
deltan(ix)=[];
datas(ix)=[];
t(ix)=[];
carrier(ix) = [];

end