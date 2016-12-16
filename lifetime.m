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