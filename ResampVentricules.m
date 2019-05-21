%files_in.source = '/home/mpelland/quarantaine/niak-0.7c3/niak-1863M/template/roi_stem.mnc.gz';%'/home/mpelland/quarantaine/niak-0.7c3/niak-1863M/template/roi_ventricle.mnc.gz';%or 
files_in.source = '/home/mpelland/database/blindtvr/fmri/tempRawMncData/prepro/anat/CBxxxVDAlCh/func_CBxxxVDAlCh_mask_stereonl.mnc.gz';
files_in.target = '/home/mpelland/quarantaine/niak-0.7c3/niak-1863M/template/mni-models_icbm152-nl-2009-1.0/mni_icbm152_t1_tal_nlin_sym_09a.mnc.gz';
files_in.transformation = '/home/mpelland/database/blindtvr/fmri/tempRawMncData/prepro/anat/CBxxxVDAlCh/transf_CBxxxVDAlCh_nativefunc_to_stereonl.xfm';
opt.flag_invert_transf = 1;

files_out = '/home/mpelland/database/blindtvr/fmri/tempRawMncData/prepro/intermediate/CBxxxVDAlCh/resample/Resamp_Mask.mnc.gz'

niak_brick_resample_vol(files_in,files_out,opt)