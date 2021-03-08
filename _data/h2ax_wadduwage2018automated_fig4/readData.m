

function [I L] = readData(pram)

  Nx            = pram.Nx;
  
  In_imds_dir   = fullfile('./Imds');
  Out_imds_dir  = fullfile('./Pxds');
  In_imds       = imageDatastore(In_imds_dir,'ReadFcn',@readRescale5k);
  L_imds        = imageDatastore(Out_imds_dir,'ReadFcn',@readAnnotation);

  I.tr          = In_imds.readall;
  L.tr          = L_imds.readall;
  
  In_imds_dir   = fullfile('./Imds_test');
  Out_imds_dir  = fullfile('./Pxds_test');
  In_imds       = imageDatastore(In_imds_dir,'ReadFcn',@readRescale5k);
  L_imds        = imageDatastore(Out_imds_dir,'ReadFcn',@readAnnotation);
  I.test        = In_imds.readall;
  L.test        = L_imds.readall;
  
  % make file name stems for saving results
  for i = 1:length(In_imds.Files)
    temp                = find(In_imds.Files{i}=='/');temp=temp(end);  
    I.test_nameStem{i}  = In_imds.Files{i}(temp+1:end-4);
  end
 
end