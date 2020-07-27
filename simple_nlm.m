 function [output]=simple_nlm(input,t,f,h1,h2,selfsim)
 
 [m n]=size(input);
 pixels = input(:);
 
 s = m*n;
 
 psize = 2*f+1;
 nsize = 2*t+1;
 % Compute patches
 padInput = padarray(input,[f f],'symmetric'); 
 filter = fspecial('average',psize);
 patches = repmat(sqrt(filter(:))',[s 1]) .* im2col(padInput, [psize psize], 'sliding')';
 
 % Compute list of edges (pixel pairs within the same search window)
 indexes = reshape(1:s, m, n);
 padIndexes = padarray(indexes, [t t]);
 %neighbors = im2col(padIndexes, [nsize, nsize], 'sliding');
 [c1 c2]=cmeanstest(input);
 neighbors = im2col(c1,[nsize,nsize],'sliding');
 TT = repmat(1:s, [nsize^2 1]);
 edges = [TT(:) neighbors(:)];
 RR = find(TT(:) >= neighbors(:));
 edges(RR, :) = [];
 
 % Compute weight matrix (using weighted Euclidean distance)
 diff = patches(edges(:,1), :) - patches(edges(:,2), :);
 diff=patches(c1(:,1),:)- patches(c1(:,2), :);
 V = exp(-sum(diff.*diff,2)/h2^2); 
 W = sparse(edges(:,1), edges(:,2), V, s, s);
 
 % Make matrix symetric and set diagonal elements
 if selfsim > 0
    W = W + W' + selfsim*speye(s);
 else
     maxv = max(W,[],2);
     W = W + W' + spdiags(maxv, 0, s, s);
 end     
 
 % Normalize weights
 W = spdiags(1./sum(W,2), 0, s, s)*W;
 
 % Compute denoised image
 output = W*pixels;
 output = reshape(output, m , n);