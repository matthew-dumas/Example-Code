
clear all; 
clc; 

dlist = dir;   % Get directory List
 
[END, y] = size(dlist); %find the size of the struct. We're only interested in END


for x = 1:END 
    if (strfind(dlist(x).name, '.csv') > 0) %check for CSV suffix
       
        % Call a function to work on this file.
        
       % plot_normalized_pattern(dlist(x).name);
        max_effective_area( dlist(x).name, 0 , 0 , 0.00907 );
    end
end

