function [T] = NDfilters(name,wavelength)
%[T] = NDfilters(name): This function was written on 8/28/15 by Mallory
%Jensen to determine the transmission of a given neutral density filter
%(specify by "name") at a given wavelength. Name is a string which denotes
%the item# for the neutral density filter (Ex. NE05A). Wavelength should be
%in nm. Included filters are NE05A, NE06A, NE10A, and NE13A. The original
%Excel sheets should be stored somewhere that can be reference and found
%inside of this function. The output is transmission as a fraction. 

%Where the spreadsheets are located
dirname = 'C:\Users\Mallory\Documents\Lifetime spectroscopy\Experiments\Filter spec sheets'; 

%Read the data
data = xlsread([dirname '\' name '.xlsx']);
%The first column is wavelength, the second column is transmission

%Find the wavelength that matches most closely
match = abs(data(:,1)-wavelength); 
index_match = find(min(match)==match); 

T = data(index_match,2);

T = T/100;

end