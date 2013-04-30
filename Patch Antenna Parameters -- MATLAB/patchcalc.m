%Change these Values
clc;
clear all;
Er           = 2.2;       %relative permitivity
h            = 2E-6;       %height of dielectric  (m)
W            = 0;       %width of patch        (m) 
L            = 0;       %length of patch       (m) 
Fr           = 12E9;       %resonant freq of antenna  (Hz)
Zo           = 0;       %input impedance 
dL           = 0;       %delta L 

c            = 3E8;     %Speed of light in vacuume
% -------------------------------------------------------
% Calculations -- Using whichever method is convenient based on defined
% parameters. If you are not defining a parameter, leave it to be 0

if (Fr > 0 && Er > 0 && h > 0)  

    W = c/(2*Fr)*((Er+1)/2)^(-1/2);
    
    Eeff = (Er + 1)/2 + (Er-1)/2*(1 + (12*h)/W)^(-1/2);
    dL = (0.412*h)*((Eeff+.3)/(Eeff-0.258))*((W/h+0.264)/(W/h+0.8));
    
    L = c/(2*Fr*sqrt(Eeff))-(2*dL);
    
    Zo = (120*pi*h)/(W*sqrt(Eeff));
    sprintf('---------------------------------')
    sprintf('Design Params: ')
    sprintf('Fr: %g',Fr) 
    sprintf('h:  %g', h) 
    sprintf('Er: %g', Er) 
    sprintf('Output: ')
    sprintf('W: %g', W)
    sprintf('L: %g', L) 
    sprintf('Zo: %g',Zo) 
    sprintf('-------------------------------------------')
    
    
else 
    
    Eeff = (Er + 1)/2 + (Er-1)/2*(1 + (12*h)/W)^(-1/2);

    Zo = (120*pi*h)/(W*sqrt(Eeff));

    dL = (0.412*h)*((Eeff+.3)/(Eeff-0.258))*((W/h+0.264)/(W/h+0.8));

    Fr=(3E8)/(2*sqrt(Eeff)*(L+(2*dL)));
    
    sprintf('-------------------------------------------')
    sprintf('Design Params: ')    
    sprintf('W: %g', W)
    sprintf('L: %g', L) 
    sprintf('h:  %g', h) 
    sprintf('Er: %g', Er) 
    sprintf('Output: ')
    sprintf('Fr: %g',Fr)
    sprintf('Zo: %g',Zo) 
    sprintf('-------------------------------------------')
end 
