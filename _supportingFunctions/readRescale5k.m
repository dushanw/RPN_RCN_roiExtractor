
function I = readRescale5k(filename)                
       I0 = imread(filename);
       I = single(I0)/5000;        
end