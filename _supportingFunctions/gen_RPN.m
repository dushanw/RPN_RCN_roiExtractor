
function lgraph = gen_RPN(pram)

    sizeIn = [pram.Nx pram.Nx];
    
    net0_dncnn = denoisingNetwork('dncnn');
    lgraph = layerGraph(net0_dncnn.Layers);
    
    lgraph = replaceLayer(lgraph,'Conv1',convolution2dLayer(5,64,'Padding',[2 2 2 2],'Name','Conv1'));
    lgraph = replaceLayer(lgraph,'InputLayer',imageInputLayer(sizeIn,'Name','InputLayer','Normalization','none'));
    
    for i=6:19
        lgraph = removeLayers(lgraph,sprintf('Conv%d',i));
        lgraph = removeLayers(lgraph,sprintf('BNorm%d',i));
        lgraph = removeLayers(lgraph,sprintf('ReLU%d',i));
    end
    lgraph = addLayers(lgraph,additionLayer(2,'Name','add_2_5'));    
    lgraph = disconnectLayers(lgraph,'BNorm5','ReLU5');
    lgraph = connectLayers(lgraph,'BNorm5','add_2_5/in1');
    lgraph = connectLayers(lgraph,'ReLU2','add_2_5/in2');
    lgraph = connectLayers(lgraph,'add_2_5','ReLU5');    
    
    lgraph = removeLayers(lgraph,'Conv20');
    lgraph = removeLayers(lgraph,'FinalRegressionLayer');
        
    layers = [        
        convolution2dLayer(20,128,'Name','Conv21')
        %maxPooling2dLayer(3,'Stride',3,'Name','MaxPool1')
        convolution2dLayer(20,128,'Name','Conv22')
        %maxPooling2dLayer(4,'Stride',4,'Name','MaxPool2')
        convolution2dLayer(20,128,'Name','Conv23')
        convolution2dLayer(7,128,'Name','Conv24')
        convolution2dLayer(1,2,'Name','Conv25')
        softmaxLayer('Name','Softmax1')
        classificationLayer('Name','Classification1')
        ];
    lgraph = addLayers(lgraph,layers);
    lgraph = connectLayers(lgraph,'ReLU5','Conv21');
    
end