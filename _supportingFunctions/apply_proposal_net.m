
function BW_proposal = apply_proposal_net(net,I,Nx)
    
    Dx = 2000;% block size
    r_start = (1:Dx:size(I,1))+Nx/2;
    c_start = (1:Dx:size(I,2))+Nx/2;    
    r_end = [r_start(2:end)-1 size(I,1)];
    c_end = [c_start(2:end)-1 size(I,2)];
    
    I = padarray(I,[Nx/2 Nx/2]);
    BW_proposal = zeros(size(I));
    
    for i = 1:length(r_start)
        for j = 1:length(c_start)
           [i j]
           BW_pred_now = activations(net,I(r_start(i)-Nx/2:r_end(i)+Nx/2-1,c_start(j)-Nx/2:c_end(j)+Nx/2-1),'Classification1');
           BW_proposal(r_start(i):r_end(i),c_start(j):c_end(j))= BW_pred_now(:,:,2);               
        end
    end 
    BW_proposal = BW_proposal(Nx/2+1:end-Nx/2,Nx/2+1:end-Nx/2);
end