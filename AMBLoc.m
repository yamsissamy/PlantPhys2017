function [edges, center] = AMBLoc(filename)
      % Define 3-way junctions and center region
      left = filename(1:6,3);
      right = filename(end-5:end,3);
      middle = filename(round(end/2-5):round(end/2+6),3);
      % Calculates area under AMB signal
      edges  = trapz(left)+trapz(right);
      center = trapz(middle);
end
