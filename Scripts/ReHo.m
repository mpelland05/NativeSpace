function ReHo(files_in,files_out),
%
%
%This function will take each voxel that are part of a mask and calculate
%their ReHo based on a specifiec number of adjacent voxels. All adjacent
%voxels will be part of the mask (meaning the ReHo will likely not be based
%on a sphere. 
%
%files_in
%        vol        string, path to a 4d volume
%        mask       string, path to a mask which will limit which voxels will
%                   be part of the analysis 
%        nvoxels    number of voxels to be taken in the analysis
%        rank       logical, 1 if rank should be used... 0 is not well
%                   emplemented yet
%
%files_out          string, path to output vol. 

files_in.rank = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[hdr, mask] = niak_read_vol(files_in.mask);
[hdr, vol] = niak_read_vol(files_in.vol);

nvoxels = files_in.nvoxels;

tloc = find(mask > 0);
[xx yy zz] = ind2sub(size(mask),tloc);

rehovol = zeros(size(vol,1),size(vol,2),size(vol,3));

for vv = 1:length(xx),
    xo = xx(vv); yo = yy(vv); zo = zz(vv);

    dist = sqrt( ((xx - xo).^2) + ((yy - yo).^2) + ((zz - zo).^2) );
    [B,idx] = sort(dist);
    tloc = idx(1:nvoxels);
    
    %create matrix with the timeseries of the voxels of interest. 
    ts_temp = zeros(nvoxels,size(vol,4));
    for vt = 1:nvoxels,
        if files_in.rank == 1,
            [B ts_temp(vt,:)] = sort(vol(xx(tloc(vt)),yy(tloc(vt)),zz(tloc(vt)),:));
        else
            %this is not the right line, it should be changed....
            %ts_temp(vt,:) = vol(xx(tloc(vt)),yy(tloc(vt)),zz(tloc(vt)),:));
        end
    end
    
    %Calculate reho
    Ri = sum(ts_temp);
    RiBar = mean(Ri);
        
    %put reho value in matrix
    nvox = nvoxels;
    ntim = size(ts_temp,2);
    rehovol(xx(vv),yy(vv),zz(vv)) = ( 12.*sum((Ri - RiBar).^2) ) / ( (nvox.^2).*( ((ntim)^3) - ntim ) );
end
hdr.file_name = files_out;
niak_write_vol(hdr,rehovol);
end
