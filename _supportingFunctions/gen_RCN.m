

function lgraph = gen_RCN(net_rcn)
    
    lgraph = layerGraph(net_rcn);
    lgraph = removeLayers(lgraph,'Conv24');
    lgraph = removeLayers(lgraph,'Conv25');
    lgraph = addLayers(lgraph,fullyConnectedLayer(2,'Name','fc1'));    

    lgraph = connectLayers(lgraph,'Conv23','fc1');
    lgraph = connectLayers(lgraph,'fc1','Softmax1');
end