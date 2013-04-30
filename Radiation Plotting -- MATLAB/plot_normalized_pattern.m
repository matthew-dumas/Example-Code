function x = plot_normalized_pattern(file)
 
% This function processes the CSV file name passed in  the argument. 
% It takes in radiation data, and plots a normalized field pattern. 
clc;
%clear all
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
%     Get Normalization data 
%--------------------------------------------------------------------------
 
for c = 2:C             % skip ID axis data   
      maximum(c-1) = max(A(:,c));  
end
    
%--------------------------------------------------------------------------
%      Normalize  
%--------------------------------------------------------------------------    
for c = 2:C             % skip ID axis data   
    for r = 1:R         % loop all rows
        A_norm(r,c) = A(r,c)/maximum(c-1); %normalize
    end
end 

%--------------------------------------------------------------------------
%      plot
%--------------------------------------------------------------------------

% Get title data: 
t1 = char(regexp(file,'.csv','split'));


for n = 2:C 
    
    t2 = char(regexp(char(titles(n)),'- ','split'));
    t3 = char(regexp(t2(2,:),' F','split'));
    figure(n-1);  
    polar(A(:,1), A_norm(:,n))  
    title([cellstr(t1(1,:)), cellstr(t3(1,:))]) 
    out_name = strtrim([t1(1,:), '_',t3(1,:)]); 
    print(figure(n-1), '-djpeg', out_name) 
    saveas(figure(n-1),out_name,'fig')
    
end
