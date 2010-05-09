% ttest2_cell() - compute unpaired t-test. Allow fast computation of 
%                multiple t-test using matrix manipulation.
%
% Usage:
%    >> [F df] = ttest2_cell( { a b } );
%    >> [F df] = ttest2_cell(a, b);
%
% Inputs:
%   a,b       = data consisting of UNPAIRED arrays to be compared. The last 
%               dimension of the data array is used to compute the t-test.
% Outputs:
%   T   - T-value
%   df  - degree of freedom (array)
%
% Example:
%   a = { rand(1,10) rand(1,12)+0.5 }
%   [T df] = ttest2_cell(a)
%   signif = 1-tcdf(T, df(1))
%
%   % for comparison, the same using the Matlab t-test function
%   [h p ci stats] = ttest(a{1}', b{1}');
%   [ stats.tstat' p] 
%
%   % fast computation (fMRI scanner volume 100x100x100 and 10 control 
%   % subjects and 12 test subjects). The computation itself takes 0.5 
%   % seconds instead of  half an hour using the standard approach (1000000 
%   % loops and Matlab  t-test function)
%   a = rand(100,100,100,10); b = rand(100,100,100,10);
%   [F df] = ttest_cell({ a b });
%
% Author: Arnaud Delorme, SCCN/INC/UCSD, La Jolla, 2005
%
% Reference:
%   Schaum's outlines in statistics (3rd edition). 1999. Mc Graw-Hill.

% Copyright (C) Arnaud Delorme
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [tval, df] = ttest2_cell(a,b) % assumes equal variances
    
    if nargin < 1
        help ttest2_cell;
        return;
    end;
    
    if iscell(a), b = a{2}; a = a{1}; end;
    meana = mymean(a, myndims(a));
    meanb = mymean(b, myndims(b));
    sda   = mystd(a, [], myndims(a));
    sdb   = mystd(b, [], myndims(b));
    na    = size(a, myndims(a));
    nb    = size(b, myndims(b));
    sp    = sqrt(((na-1)*sda.^2+(nb-1)*sdb.^2)/(na+nb-2));
    tval  = (meana-meanb)./sp/sqrt(1/na+1/nb);
    df    = na+nb-2;
    
    % check values againg Matlab statistics toolbox
    % [h p ci stats] = ttest2(a', b');
    % [ tval stats.tstat' ] 
    
function val = myndims(a)
    if ndims(a) > 2
        val = ndims(a);
    else
        if size(a,1) == 1,
            val = 2;
        elseif size(a,2) == 1,
            val = 1;
        else
            val = 2;
        end;
    end; 
  
function res = mymean( data, varargin) % deal with complex numbers
    res = mean( data, varargin{:});
    if ~isreal(data)
        res = abs( res );
    end;

function res = mystd( data, varargin) % deal with complex numbers
    if ~isreal(data)
        res = std( abs(data), varargin{:});
    else
        res = sqrt(sum( bsxfun(@minus, data, mean( data, varargin{2})).^2, varargin{2})/(size(data,varargin{2})-1)); % 8 percent speedup
        %res = std( data, varargin{:});
    end;
    
    
