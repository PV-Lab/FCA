function [delta_carr_rev]=FCA_coeff(delta_carr,T,carrier,d)
%[delta_carr_rev] = FCA_coeff(delta_carr,T,carrier,d): This function
%calculates a revised free carrier absorption cross-section based on a
%publication by Isenberg in 2004. T is the sample temperature in Kelvin.
%delta_carr is the initial calculated injection level in cm^-3. This script
%corrects that injection level for temperature and high injection. Carrier
%is the value before conversion to carrier density (-log(1-V/V0)). d is the
%thickness of the wafer in cm.

%This correction is taken from Isenberg, APL, 2004. This should be
%validated across the temperature range. 
Ae = 5.75;
me = 0.67;
Ne = 6.3e18; 
Ah = 2.59; 
mh = 0.76; 
Nh = 3.2e18;

%Correction for holes, assume deltan=deltap
Ch = 1+(Ah*(1+erf(mh*log(delta_carr/Nh)))); 

%Correction for electrons, assume deltan=deltap
Ce = 1+(Ae*(1+erf(me*log(delta_carr/Ne)))); 

%Svantesson JPhysC 1979, corrected to achieve the value that Sin Cheng
%calculated for his JAP
k = (2.5e-20)*T; 

%Correct the free carrier coefficient if the temperature is incorrect
if delta_carr >= 3e16  
    sigma_FCA = (k*Ce)+(k*Ch); 
else
    sigma_FCA = k+k; 
end

delta_carr_rev=((sigma_FCA)^-1)*(d^-1)*carrier; 

end

        
    





