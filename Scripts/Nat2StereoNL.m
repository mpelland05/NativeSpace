%inputs
pathin = '/home/mpelland/database/blindtvr/fmri/ReHo_Native_Smooth_STD/Native/';%path to normalized preprocessing
pathout = '/home/mpelland/database/blindtvr/fmri/ReHo_Native_Smooth_STD/Stereo/'; %output path of current (native) preprocessing

fs = filesep;

pnames = {'CBxxxVDAlCh','CBxxxVDAnBe','CBxxxVDBeMe','CBxxxVDDiCe','CBxxxVDFrCo','CBxxxVDLL','CBxxxVDMaLa','CBxxxVDMaDu','CBxxxVDMoBe','CBxxxVDNaTe','CBxxxVDSePo','CBxxxVDSoSa','CBxxxVDYP','CBxxxVDYvLa','SCxxxVDCJ','SCxxxVDChJa','SCxxxVDClDe','SCxxxVDGeAl','SCxxxVDJM','SCxxxVDJeRe','SCxxxVDJoFr','SCxxxVDKaFo','SCxxxVDLALH','SCxxxVDMaSa','SCxxxVDNiLe','SCxxxVDNiMi','SCxxxVDOL','SCxxxVDPG','SCxxxVDSC','SCxxxVDSG','SCxxxVDTJ'}; %cell of string, name of participant(s)


%%Participant loop
for pp = 1:length(pnames),
    
    files_in.source=strcat(pathin,pnames{pp},'.mnc.gz');
    files_in.target= '/home/mpelland/quarantaine/niak-0.7c3/niak-1863M/template//roi_aal_3mm.mnc.gz';
    files_in.transformation=strcat('/home/mpelland/database/blindtvr/fmri/fmri_preprocess_01/anat/',pnames{pp},'/transf_',pnames{pp},'_nativefunc_to_stereonl.xfm');
   
    files_out=strcat(pathout,pnames{pp},'.mnc.gz');
    
    opt.voxel_size= [3 3 3];
    opt.interpolation= 'trilinear';
    
    niak_brick_resample_vol(files_in,files_out,opt);
end