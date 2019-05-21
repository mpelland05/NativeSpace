%LaunchReho
fs = filesep;

smoothed = 0; %paths to the results will differ

NativPrepro = '/home/mpelland/database/blindtvr/fmri/fmri_preprocess_01_Native/'; %output path of current (native)
%/home/mpelland/database/blindtvr/fmri/fmri_preprocess_01_Native/intermediate/corsica/fmri_..._rest_run_cor_p.mnc.gz
%/home/mpelland/database/blindtvr/fmri/fmri_preprocess_01_Native/fmri/fmri_..._rest_run.mnc.gz

pnames ={'CBxxxVDAlCh','CBxxxVDAnBe','CBxxxVDBeMe','CBxxxVDDiCe','CBxxxVDFrCo','CBxxxVDLL','CBxxxVDMaLa','CBxxxVDMaDu','CBxxxVDMoBe','CBxxxVDNaTe','CBxxxVDSePo','CBxxxVDSoSa','CBxxxVDYP','CBxxxVDYvLa','SCxxxVDCJ','SCxxxVDChJa','SCxxxVDClDe','SCxxxVDGeAl','SCxxxVDJM','SCxxxVDJeRe','SCxxxVDJoFr','SCxxxVDKaFo','SCxxxVDLALH','SCxxxVDMaSa','SCxxxVDNiLe','SCxxxVDNiMi','SCxxxVDOL','SCxxxVDPG','SCxxxVDSC','SCxxxVDSG','SCxxxVDTJ'}; %cell of string, name of participant(s)


files_in.nvoxels = 21;
files_in.rank = 1;

pathout = '/home/mpelland/database/blindtvr/fmri/ReHo_Native_noSmooth_STD/Native/';

for pp = 1:length(pnames),
    pnames{pp}

    files_in.mask = strcat(fs,NativPrepro,'/anat/',pnames{pp},'/func_',pnames{pp},'_mask_nativefunc.mnc.gz');
    files_out = strcat(pathout,pnames{pp},'.mnc.gz');

    if smoothed,
        files_in.vol = strcat(NativPrepro,'/fmri/fmri_',pnames{pp},'_rest_run.mnc.gz');
    else
        files_in.vol = strcat(NativPrepro,'intermediate/',pnames{pp},'/corsica/fmri_',pnames{pp},'_rest_run_cor_p.mnc.gz');
    end

    [hdr, mask] = niak_read_vol(files_in.mask);
    [thdr, vol] = niak_read_vol(files_in.vol);
    
    volstd = std(vol,0,4).*(mask == 1);
    
    hdr.file_name = files_out;
    niak_write_vol(hdr,volstd);

end

