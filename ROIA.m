function [first,second] = ROIA(filename,r)
% This normalizes AMB signal from 0 to 1 and interpolates line to 500 points. 
    Origin(:,1)=filename(:,1)-filename(1,1);
    Origin(:,2)=filename(:,2)-filename(1,2);
    tempor(:,1)= Origin(:,1)*cos(r)-Origin(:,2)*sin(r);
    tempor(:,2)= Origin(:,1)*sin(r)+Origin(:,2)*cos(r);
    angle = -(atan(tempor(end,2)/tempor(end,1)));
    tempor2 = tempor(:,1)*sin(angle)+tempor(:,2)*cos(angle);
    
    i = size(filename,1)/499;
    sci = 0:i:size(filename,1);
    x(:,1) = 1:size(filename,1);
    x(:,2) = tempor2;
    SP = spline(x(:,1),x(:,2),sci);
    first = 1:size(SP,2);
    second = transpose(SP);
end


