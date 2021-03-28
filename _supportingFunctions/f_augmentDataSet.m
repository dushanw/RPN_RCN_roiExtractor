
function [X Y] = f_augmentDataSet(X,Y,onlyPos)

  if ~isempty(onlyPos) && onlyPos==1  
    X0      = X(:,:,:,Y=='1');
    Y0      = Y(Y=='1');
  else
    X0      = X;
    Y0      = Y;
  end  
  
  X90       = imrotate(X, 90);
  X180      = imrotate(X,180);
  X270      = imrotate(X,270);
  
  X0_flp    = flip(X0);
  X90_flp   = flip(X90);
  X180_flp  = flip(X180);  
  X270_flp  = flip(X270);

% imagesc([X0(:,:,1,1),   X90(:,:,1,1),     X180(:,:,1,1),     X270(:,:,1,1);...
%         X0_flp(:,:,1,1),X90_flp(:,:,1,1), X180_flp(:,:,1,1), X270_flp(:,:,1,1)]);axis image
  
  [temp mxYsize] = max(size(Y));
  
  X         = cat(4      ,X , X90, X180, X270, X0_flp, X90_flp, X180_flp, X270_flp);
  Y         = cat(mxYsize,Y ,  Y0,   Y0,   Y0,     Y0,      Y0,       Y0,       Y0);
  
  randInds  = randperm(length(Y));
  X         = X(:,:,:,randInds);
  Y         = Y(randInds);
end

      