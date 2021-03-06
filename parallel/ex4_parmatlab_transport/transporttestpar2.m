function [myruntime]=transporttestpar2(nsamples)
    %using matlab distributoe to distribute a matrix across processors
    %gather is used to collect each component
    nsamples=1;
    msiz=[48 480 4800];  %matrix sizes to test
    %msiz=[480]; 
    myruntime=zeros(1,nsamples)
    %k=3;
  
    for k=1:3
    tic;
    image=zeros(msiz(k), msiz(k)/numlabs);
    if labindex==1
        image=image+1;
    end
    imsize=size(image)
    %image=labBroadcast(1,image);
    %labBarrier;
    imsect=distributed(image,distributor())
    
     
     %matrix scattered now perform an operation
     limsect=imsect+labindex;
     
     
     image=gather(limsect,1);
     myruntime(k)=toc
     

    end


