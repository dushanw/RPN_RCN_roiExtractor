
function BW_proposal = apply_proposal_net(net,I,Nx)
    
  Dx = 2000;% block size
  r_start = (1:Dx:size(I,1))+Nx/2;
  c_start = (1:Dx:size(I,2))+Nx/2;    
  r_end = [r_start(2:end)-1 size(I,1)+Nx/2];
  c_end = [c_start(2:end)-1 size(I,2)+Nx/2];

  if r_end(end) - r_start(end) < Nx && length(r_start)>1
    r_start(end) = [];
    r_end(end-1) = [];    
  end
  if c_end(end) - c_start(end) < Nx && length(c_start)>1
    c_start(end) = [];
    c_end(end-1) = [];
  end
    
  I = padarray(I,[Nx/2 Nx/2]);
  BW_proposal = zeros([size(I,1) size(I,2)]);

  for i = 1:length(r_start)
    for j = 1:length(c_start)
%      size(I(r_start(i)-Nx/2:r_end(i)+Nx/2-1,c_start(j)-Nx/2:c_end(j)+Nx/2-1,:))
      BW_pred_now = activations(net,I(r_start(i)-Nx/2:r_end(i)+Nx/2-1,c_start(j)-Nx/2:c_end(j)+Nx/2-1,:),'Classification1');
      BW_proposal(r_start(i):r_end(i),c_start(j):c_end(j))= BW_pred_now(:,:,2);               
    end
  end 
  BW_proposal = BW_proposal(Nx/2+1:end-Nx/2,Nx/2+1:end-Nx/2);
end