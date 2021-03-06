function [sumouter,myruntime]=qscatterpar1(sgetid)
 %solve radial wave equation using numerov 
%predictor method to fourth order 
%for 2nd order de's
 %Using labsend and labreceive to distribute the matrix
global m
global hb

m=1.672*10^(-27);

hb=1.054*10^(-34);
lupper=10
e=1.6*10^(-19); 
 delta=0.1*(10^(-10));
 delta=0.5;
 epsilon=5.9;%meV H-Kr interaction
 sigma=3.57;%Angstrom
 m=1;
 hb=1;
 e=1;
  lupper=10;
  sumdelta=0;
  nr=100;
  ne=240;
  nnepp=ne/numlabs;
  startne=1+(labindex-1)*nnepp;
  
  if labindex==numlabs
    finishne=ne;  
  else
    finishne=startne+nnepp;
  end
  
  sumouter=zeros(ne,1);
  totsum=0;
  
  
  u1=zeros(nr,lupper+1);
  u2=zeros(nr,lupper+1);
  u3=zeros(nr,lupper+1);
  %outer loop integration over r

 
 tic
 %parallel loop
 for nec=startne:finishne
    e=nec*0.0005;
    k=sqrt(2*m*e)/hb;
    totsum=0; 
     u1=zeros(nr,lupper+1);
     u2=zeros(nr,lupper+1);
     u3=zeros(nr,lupper+1);
      for j=1:nr,

        u1=0;
        %inner loop summation over l
        sumdelta=0;
        for i=0:lupper,   
          if j == 1 %then
            u1(j,i+1)=.1;
            u2(j,i+1)=delta^(i+1);
          else
            u2(j,i+1)=u3(j-1,i+1);
            u1(j,i+1)=u2(j-1,i+1);
          end;

          u3(j,i+1)=numerov(u1(j,i+1),u2(j,i+1),i,3.1+j*delta,delta,e,sigma,epsilon);
        end
  end
  
 
     for i=0:lupper,   
 
      
       res=tdl(u2(nr-2,i+1),u2(nr-1,i+1),(nr-1)*delta,(nr)*delta,i,k);
      cosecdelta2=((1/(res^2))+1);
      sumdelta=sumdelta+(2*i+1)*(1/cosecdelta2); 
    end
    sumouter(nec,1)=((4*pi)/(k^2))*sumdelta;
    totsum=totsum+sumouter(nec);
    
  end  %endof parallel for loop
  
  %Gather matrices onto first processor
  if numlabs>1
      if labindex ==1
           for i=2:numlabs
            startne=1+(i-1)*nnepp;
            if i==numlabs
                finishne=ne;  
            else
                finishne=startne+nnepp;
            end

           sumouter(startne:finishne,1)=labReceive(i);
          end
      else
          labSend(sumouter(startne:finishne,1),1);
      end
  end
  
 
myruntime=toc

   



function [tdl]=tdl(u1,u2,r1,r2,l,k)
   %calculate phase shift of partial waves tand deltl
   kk=(r1*u1)/(r2*u2);
 tdl=(kk*besselj(l,k*r1)-besselj(l,k*r2))/(kk*bessely(l,k*r1)-bessely(l,k*r2));
%endfunction




function [numerov]=numerov(u1,u2,l,r,delta,e,sigma,epsilon)
global m
global hb

  %num1=1/(1-(delta^2/12)*f(l,r+delta,e,sigma,epsilon));
  %bracket1=2*u2-u1+(delta^2/12)*(10*f(l,r,e,sigma,epsilon)*u2+f(l,r,e,sigma,epsilon)*u1);
  flre=10*epsilon*( ((sigma/r)^12)-2*((sigma/r)^6))+(hb^2/(2*m*r*r))-e;
num1=1/(1-(delta^2/12)*(flre));
  bracket1=2*u2-u1+(delta*delta/12)*(10*flre*u2+flre*u1);
  
  
  numerov=num1*bracket1;

%endfunction


