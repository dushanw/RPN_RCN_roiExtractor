
function L = readAnnotation(filename)                
       I0   = imread(filename);
       if size(I0,3)>1
         I0 = mean(I0,3);
       end
       th   = (max(I0(:)) + min(I0(:)))/2 ;
       L    = imbinarize(I0,th);
       
       if sum(L(:)==0) < sum(L(:)==1)
         L = ~ L;
       end       
end
