
% a function to generate a matrix with n clusters with std deviation. 

function m = genData(bigr, bigc, c1center, c1r, c1c, c2center, c2r, c2c, mean, std)

% VEL  what is a good starting dataset?  
% Have a 5x5 with one cluster
%      10x10 with two clusters. 

   b = zeros(bigr, bigc);

% [Center, radius], [center, radius], each; use Matlab: normrnd
   mean = 3;
   std = 1;
   rows = c1r;
   cols = c1c;
   cluster1 = normrnd(mean,std,[rows,cols]);
   
   %b(2:4,1:3) = cluster1;
   roffset = int8(c1r/2);
   coffset = int8(c1c/2);
   minr = c1center - roffset;
   minc = c1center - coffset;
   b(minr:minr+rows-1, minc:minc+cols-1) = cluster1;
   % b(minr, minc) = cluster1;
   % b =
   %          0         0         0         0         0
   %     4.4090    1.7925    3.4889         0         0
   %     4.4172    3.7172    4.0347         0         0
   %     3.6715    4.6302    3.7269         0         0
   %          0         0         0         0         0

   rows = c2r;
   cols = c2c;
   cluster2 = normrnd(mean,std,[rows,cols]);

   roffset = int8(c2r/2);
   coffset = int8(c2c/2);
   minr = c2center - roffset;
   minc = c2center - coffset;

   b(minr:minr+rows-1, minc:minc+cols-1) = cluster2;

   m = b;
end
   
