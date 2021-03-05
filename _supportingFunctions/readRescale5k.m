
function I = readRescale5k(filename)                
       I0 = imread(filename);
       if size(I0,3)>1
         I0 = sum(I0,3);
       end
       I = single(I0)/5000;        
end