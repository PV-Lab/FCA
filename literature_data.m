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

%This function was written on September 13, 2015 by Mallory Jensen. No
%inputs are required, and the output is a figure plotting the free carrier
%absorption coefficient versus temperature for the literature values
%tabulated.

function literature_data

figure; 

T = 250:5:650; 
Svan = (1.7e-20).*T; 
H(1) = plot(T,Svan,'-','LineWidth',4); 
hold all; 

Sturm = (1.01e-20+0.51e-20).*T.*(1.550^2); 
H(2) = plot(T,Sturm,'-','LineWidth',4); 
hold all;

H(3) = plot(298,0.75e-17,'v','MarkerSize',10,'LineWidth',2); 
hold all;

H(4) = plot(298,1.69e-17,'+','MarkerSize',10,'LineWidth',2); 
hold all;

%Schroder 1978
C_p = 2.7e-18; 
C_n = 1.8e-18; 
H(5) = plot(298,(C_p+C_n)*(1.550^2),'<','MarkerSize',10,'LineWidth',2); 
hold all; 

%Green
C_p = 2.6e-18; 
C_n = 2.7e-18; 
gamma_p = 2; 
gamma_n = 3; 
alpha = (C_p*(1.550^gamma_p))+(C_n*(1.550^gamma_n)); 
H(6) = plot(298,alpha,'s','MarkerSize',10,'LineWidth',2);
hold all;

%Xu
C_p = 3.2e-6;
C_n = 3e-6;
alpha = (C_p+C_n)*(.0001550^3);
H(7) = plot(298,alpha,'d','MarkerSize',10,'LineWidth',2);
hold all;

%Baker-Finch
C_p = 1.8e-9;
C_n = 1.68e-6; 
gamma_p = 2.18;
gamma_n = 2.88; 
alpha = (C_p*(.0001550^gamma_p))+(C_n*(.0001550^gamma_n));
H(8) = plot(298,alpha,'x','MarkerSize',10,'LineWidth',2);
hold all;

%Rudiger 2013
C_p = 2.6e-18;
C_n = 1.8e-18;
gamma_p = 2.4;
gamma_n = 2.6;
alpha = (C_p*(1.550^gamma_p))+(C_n*(1.550^gamma_n));
H(9) = plot(298,alpha,'^','MarkerSize',10,'LineWidth',2);
hold all;

%Isenberg, ignoring the correction for high injection
C_p = 10.72e-11;
C_n = 4.5e-11;
alpha = (C_p+C_n)*(.0001550^2);
H(10) = plot(298,alpha,'>','MarkerSize',10,'LineWidth',2);

legend(H,'Svantesson 1979','Sturm 1992','Siah 2015','Meitzner 2013','Schroder 1978','Green 1995','Xu 2013','Baker-Finch 2014','Rudiger 2013','Isenberg 2004'); 

xlabel('Temperature [K]','FontSize',20); 
ylabel('\sigma_{FCA} [cm^2]','FontSize',20);
