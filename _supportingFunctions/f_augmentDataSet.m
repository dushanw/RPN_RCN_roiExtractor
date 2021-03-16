
function [X Y] = f_augmentDataSet(X,Y)
  X90   = imrotate(X, 90);
  X180  = imrotate(X,180);
  X270  = imrotate(X,270);
  
  [temp mxYsize] = max(size(Y));
  
  X     = cat(4      ,X,X90,X180,X270);
  Y     = cat(mxYsize,Y,  Y,   Y,   Y);  
end