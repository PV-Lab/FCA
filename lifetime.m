function [tau] = lifetime(deltan,time)
%This function was written on August 17, 2015 to calculate the lifetime
%from a pair of vectors - excess carrier density as a function of time. The
%sizes of deltan and time must be the same. 

%Calculate the derivative of the excess carrier vector as a function of
%time, spanning 5 points and fitting a linear line. We can only start 3
%entries into the vector because we need 2 entries before and 2 entries
%after. 
[m,n] = size(deltan); 
dndt = zeros(size(deltan)); 
for j = 3:(max(m,n)-2)
    
    x = time(j-2:j+2); 
    y = deltan(j-2:j+2); 
    
    X = [x', ones(5,1)]; 
    fit = X\(y'); 
    
    dndt(j) = fit(1); 
    
%     %Fit a linear line to the data
%     p = polyfit(x,y,1); 
%     dndt(j) = p(1); 
    
end

%Now that we have the derivative, calculate the lifetime. 
tau = -deltan./dndt; 

%When dndt = 0, tau will be NaN. Otherwise tau should be the same size as
%both deltan and time. 