function movingavaragefilter

global mag2data

%%
% movingavaragefilter performs, of course, a moving avarage filter with the
% number of points specified in movingavaragepoints, using the filtfilt 
% Matlab function.
% 
% Written by Stefano Stocco on September, 2007

% Copyright (C) 2007 Stefano Stocco
% 
% This file is part of MAG2DATA.
% 
% MAG2DATA is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation; either version 3 of the License, or (at your
% option) any later version.
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
% Public License for more details.
% 
% You should have received a copy of the GNU General Public License along
% with this program; if not, see <http://www.gnu.org/licenses>.


movingavaragepoints=mag2data.movingavaragepoints;
Fin=mag2data.Fin;
% ---------- Filter ---------- %
mag2data.Fout=filtfilt(ones(movingavaragepoints,1)/movingavaragepoints,1,Fin);