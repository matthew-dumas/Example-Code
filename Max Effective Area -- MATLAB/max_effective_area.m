function x = max_effective_area(file, Vi, Er, Pi)
 
% This function opens the CSV file being processed and computes the effective
% area for each data set. 
%
% It also saves these plots as a CSV for use in Excel
% 
% Takes file name and either 
%       1.    incident field voltage (V/m) and relative permittivity
% or 
%       2.    incident power density 
%
%  For case 1, let Pi = 0
%  For case 2, let Vi and Er be 0 
%
% Assumptions: In free space.
%clc;
file 

%-----------------------------------------------------------------
% Start setup, glob file, get titles, separate into usable stuff
%-----------------------------------------------------------------

A = csvread(file,1,0);  %load CSV
    
[R, C] = size(A);  % get size of data array
    
FID = fopen(file);         %open file
title_line = fgets(FID);   %get headers
fclose(FID);               %close file

titles = char(regexp(title_line,'\"','split')); %split headers into a 2 d array
 
[x,y] = size(titles);                           %get size

titles = cellstr(titles);                       %turn back to strings

file = regexprep(file, '_', '-')

n = 1;
while n <= x                                    %loop the ever changing array
    [xx,yy] = size(char(titles(n)));            %check size
    if ( yy < 2)                              
        titles(n) = [];                         %chomp garbage files
        x = x - 1;                              %array just shortened by one, remove it
        continue;                               %skip incrementing because the array got smaller
    end
    n = n + 1;                                  %increment so we don't clip good titles
    
end

%--------------------------------------------------------------------------
%     Compute incident power density 
%--------------------------------------------------------------------------

if (Pi == 0)
    Pi = (377/sqrt(Er))^(-1); 
end 
    

%--------------------------------------------------------------------------
%     Get Maximum power dissipated
%--------------------------------------------------------------------------
 
for c = 2:C             % skip ID axis data   
      maximum(c-1) = max(A(:,c));  
end
    
%--------------------------------------------------------------------------
%      Get Max Effective Area  
%--------------------------------------------------------------------------    
for c = 1:C-1              
        Ae(c) = maximum(c)/Pi; %normalize
end 

%--------------------------------------------------------------------------
%      Output
%--------------------------------------------------------------------------

% Get title data and make a name
t1 = char(regexp(file,'.csv','split'));
c=0;
for n = 2:C
    c = c+1;
    t2 = char(regexp(char(titles(n)),'- ','split'));
    t3 = char(regexp(t2(2,:),' F','split'));
    out_name = strtrim([t1(1,:),'_max_effective_area.csv']);

    t4 = char(regexp(strtrim(t3(1,:)), 'ohm', 'split'));
    t5 = t4(1,9:length(t4));
    n = str2num(t5);
    out_dat(c) = n;
end

format short e;
out = [out_dat' Ae']

file_1 = fopen(out_name,'w');
fprintf(file_1, 'RLoad,Max Effective Area\n');
fclose(file_1) 

dlmwrite(out_name, out, '-append'); 

