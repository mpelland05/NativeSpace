%% Getting volume of comparison between Native and Stereo
fs = filesep;

pnames ={'CBxxxVDAlCh','CBxxxVDAnBe','CBxxxVDBeMe','CBxxxVDDiCe','CBxxxVDFrCo','CBxxxVDLL','CBxxxVDMaLa','CBxxxVDMaDu','CBxxxVDMoBe','CBxxxVDNaTe','CBxxxVDSePo','CBxxxVDSoSa','CBxxxVDYP','CBxxxVDYvLa','SCxxxVDCJ','SCxxxVDChJa','SCxxxVDClDe','SCxxxVDGeAl','SCxxxVDJM','SCxxxVDJeRe','SCxxxVDJoFr','SCxxxVDKaFo','SCxxxVDLALH','SCxxxVDMaSa','SCxxxVDNiLe','SCxxxVDNiMi','SCxxxVDOL','SCxxxVDPG','SCxxxVDSC','SCxxxVDSG','SCxxxVDTJ'}; %cell of string, name of participant(s)

NormPrepro = '/home/mpelland/database/blindtvr/fmri/ReHo_Stereo_Smooth_STD/';
NatiPrepro = '/home/mpelland/database/blindtvr/fmri/ReHo_Native_Smooth_STD/Stereo/';

OutPat = '/home/mpelland/database/blindtvr/fmri/Comp_ReHo_STD/STD/Smooth/';

for pp = 1:length(pnames),
    pnames{pp}
    
    [hdr,volNorm] = niak_read_vol(strcat(NormPrepro,pnames{pp},'.mnc.gz')); 
    [hdr,volNati] = niak_read_vol(strcat(NatiPrepro,pnames{pp},'.mnc.gz')); 
    
    masknorm = (volNorm ~= 0);
    masknati = (volNati ~= 0);
    mask = masknorm.*masknati;
    
    volComp = (volNorm-volNati).*mask;
    
    hdr.file_name = strcat(OutPat,pnames{pp},'.mnc.gz');
    
    niak_write_vol(hdr,volComp);
    
end