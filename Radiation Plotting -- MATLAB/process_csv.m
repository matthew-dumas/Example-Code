% This file processes a directory of CSV Files. 
% First it reads the data in, then it plots a normalized radiation pattern for human review
%   The outputs are displayed on screen in MATLAB. 
%
%
%   TODO:  (If outputs to file are necessary, then the following needs implementation)
%         - Output Chart to JPEG
%         - Clean up workspace
clear all; 
clc; 

dlist = dir;   % Get directory List
 
[END, y] = size(dlist); %find the size of the struct. We're only interested in END


for x = 1:END 
    if (strfind(dlist(x).name, '.csv') > 0) %check for CSV suffix
       
        % Call a function to work on this file.
        
        plot_normalized_pattern(dlist(x).name);
        
    end
end

