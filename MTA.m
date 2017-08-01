function [first, second, third, fourth] = MTA(filename)
    % This calculates original angle, rotates moves segment to x-axis and
    % interpolates to 500 points. 
    for i=1:size(filename,2)
      ans(i,1) = (i*.212)-.212;
      ans(i,2) = sum(filename(:,i));
    end
    
    maxS = max(ans(:,2));
    minS = min(ans(:,2));
    
    for i=1:size(filename,2)
      ans(i,3)=(ans(i,2)-minS)/(maxS-minS);
    end
    first  = ans(:,1);
    second = ans(:,2);
    third  = ans(:,3);
    
    i = (size(third,1)-1)/499;
    sci = 1:i:size(third,1);
    x(:,1) = 1:size(third,1);
    x(:,2) = third(:,1);
    SP = spline(x(:,1),x(:,2),sci);
    fourth = transpose(SP);
end
