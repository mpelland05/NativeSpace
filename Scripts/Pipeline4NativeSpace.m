%This script creates a pipline for making preprocessing into native
%functional space. Thus, here, the outputs of the functional volume will
%not have been normalized to the stereotaxic space. This script requires
%that the preprocessing was already carried with the normalization, for
%some of its inputs come from the normalized preprocessing. 
%Also, some steps of the normalized preprocessing are redone to avoid
%losing resolution during the dernormalization process (this could not be 
%done for the brain mask but was done for the stem and ventricules.

%inputs
NormPrepro = '/home/mpelland/database/blindtvr/fmri/fmri_preprocess_01/';%path to normalized preprocessing
NativPrepro = '/home/mpelland/database/blindtvr/fmri/fmri_preprocess_01_Native/'; %output path of current (native) preprocessing

fs = filesep;

pnames = {'CBxxxVDAlCh','CBxxxVDAnBe','CBxxxVDBeMe','CBxxxVDDiCe','CBxxxVDFrCo','CBxxxVDLL','CBxxxVDMaLa','CBxxxVDMaDu','CBxxxVDMoBe','CBxxxVDNaTe','CBxxxVDSePo','CBxxxVDSoSa','CBxxxVDYP','CBxxxVDYvLa',...  'SCxxxVDCJ','SCxxxVDChJa','SCxxxVDClDe','SCxxxVDGeAl','SCxxxVDJM','SCxxxVDJeRe','SCxxxVDJoFr','SCxxxVDKaFo','SCxxxVDLALH','SCxxxVDMaSa','SCxxxVDNiLe','SCxxxVDNiMi','SCxxxVDOL','SCxxxVDPG','SCxxxVDSC','SCxxxVDSG','SCxxxVDTJ'}; %cell of string, name of participant(s)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set variables
%%%
pipeline = struct([]);



%%Participant loop
for pp = 1:length(pnames),
    
    %%%%%
    % Step 1, rerun the resampling minus the normalization (9b).
    %%%%
    clear files_in files_out opt jname comm;
    
    files_in.source = strcat(fs,NormPrepro,'/intermediate/',pnames{pp},'/slice_timing//fmri_',pnames{pp},'_rest_run_a.mnc.gz');
    %files_in.target = '/home/mpelland/quarantaine/niak-0.7c3/niak-1863M/template//roi_aal_3mm.mnc.gz';
    files_in.target = files_in.source;
    files_in.transformation = strcat(fs,NormPrepro,'/intermediate/',pnames{pp},'/motion_correction/motion_parameters_',pnames{pp},'_rest_run.mat');
    
    files_out = strcat(fs,NativPrepro,'/intermediate/',pnames{pp},'/resample//fmri_',pnames{pp},'_rest_run_a_res.mnc.gz');
    
    opt.voxel_size= [3 3 3];
    opt.flag_test= 0;
    opt.flag_skip= 0;
    opt.transf_name= 'transf';
    opt.interpolation= 'trilinear';
    opt.flag_tfm_space= 0;
    opt.flag_invert_transf= 0;
    opt.flag_adjust_fov= 0;
    opt.flag_keep_range= 0;
    
    comm = 'niak_brick_resample_vol';
    jname = strcat('resamp_func_',pnames{pp});
    
    pipeline = psom_add_job(pipeline,jname,comm,files_in,files_out,opt);

    
    %%%%%
    % Step 2, take mask from normalized preprocessing that was just done  and return them to
    % native space. 
    % Note: this means that for the native space, 2 resampling steps are carried for the masks which  should impact their precision. 
    %%%%
    
  %%% Tissue classification 1b
    clear files_in files_out opt jname comm;
    
    files_in.source = strcat(fs, NormPrepro,'/anat/',pnames{pp},'/anat_',pnames{pp},'_classify_stereolin.mnc.gz');
    files_in.target = strcat(fs,NormPrepro,'/intermediate/',pnames{pp},'/slice_timing//fmri_',pnames{pp},'_rest_run_a.mnc.gz');
    files_in.transformation = strcat(fs,NormPrepro,'/anat/',pnames{pp},'/transf_',pnames{pp},'_nativefunc_to_stereolin.xfm');
    
    opt.flag_invert_transf = 1;
    opt.voxel_size = [3 3 3];
    opt.interpolation = 'nearest_neighbour';
    
    files_out = strcat(fs, NativPrepro,'/anat/',pnames{pp},'/anat_',pnames{pp},'_classify_nativ.mnc.gz');
    
    comm = 'niak_brick_resample_vol';
    jname = strcat('resamp_tissueclass_',pnames{pp});
    
    pipeline = psom_add_job(pipeline,jname,comm,files_in,files_out,opt);
    
  %%% Brain mask (10b)
    clear files_in files_out opt jname comm;
    
    files_in.source = strcat(fs,NormPrepro,'/anat/',pnames{pp},'/func_',pnames{pp},'_mask_stereonl.mnc.gz');
    files_in.target = strcat(fs,NormPrepro,'/intermediate/',pnames{pp},'/slice_timing//fmri_',pnames{pp},'_rest_run_a.mnc.gz');
    files_in.transformation = strcat(fs,NormPrepro,'/anat/',pnames{pp},'/transf_',pnames{pp},'_nativefunc_to_stereonl.xfm');
    
    opt.flag_invert_transf = 1;
    opt.voxel_size = [3 3 3];
    opt.interpolation = 'nearest_neighbour';
   
    files_out = strcat(fs,NativPrepro,'/anat/',pnames{pp},'/func_',pnames{pp},'_mask_nativefunc.mnc.gz');
    
    comm = 'niak_brick_resample_vol';
    jname = strcat('resamp_mask_',pnames{pp});
    
    pipeline = psom_add_job(pipeline,jname,comm,files_in,files_out,opt);
    
    
  %%% Stem mask (11b.1)
    clear files_in files_out opt jname comm;
    
    files_in.mask_vent_stereo = '/home/mpelland/quarantaine/niak-0.7c3/niak-1863M/template/roi_ventricle.mnc.gz';
    files_in.mask_wm_stereo = '/home/mpelland/quarantaine/niak-0.7c3/niak-1863M/template/mni-models_icbm152-nl-2009-1.0/mni_icbm152_t1_tal_nlin_sym_09a_mask_pure_wm_2mm.mnc.gz';
    files_in.mask_stem_stereo = '/home/mpelland/quarantaine/niak-0.7c3/niak-1863M/template/roi_stem.mnc.gz';
    files_in.mask_brain = strcat(fs,NativPrepro,'/anat/',pnames{pp},'/func_',pnames{pp},'_mask_nativefunc.mnc.gz');
    files_in.aal =  '/home/mpelland/quarantaine/niak-0.7c3/niak-1863M/template/roi_aal.mnc.gz';
    files_in.functional_space = files_in.mask_brain;
    files_in.transformation_nl = strcat(fs,NormPrepro,'/anat/',pnames{pp},'/transf_',pnames{pp},'_nativefunc_to_stereonl.xfm');
    files_in.segmentation = strcat(fs, NativPrepro,'/anat/',pnames{pp},'/anat_',pnames{pp},'_classify_nativ.mnc.gz');
    
    opt.target_space= 'stereonl';
    opt.flag_test= 0;
    opt.flag_verbose= 1;
    opt.folder_out= '';
    
    files_out.mask_stem_ind = strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'/corsica/',pnames{pp},'_mask_stem_nativefunc.mnc.gz');
    files_out.mask_vent_ind = strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'/corsica/',pnames{pp},'_mask_vent_nativefunc.mnc.gz');
    files_out.white_matter_ind = strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'/corsica/',pnames{pp},'_mask_wm_nativefunc.mnc.gz');
    
    comm = 'max_niak_brick_mask_corsica';
    jname = strcat('mask_corsica_',pnames{pp});
    
    pipeline = psom_add_job(pipeline,jname,comm,files_in,files_out,opt);
   
    
    %%%%%
    % Step 3, run temporal filtering (well.... obtain the covariates
    % related to it) (12b)
    %%%%
    clear files_in files_out opt jname comm;
    
    files_in = strcat(fs,NativPrepro,'/intermediate/',pnames{pp},'/resample//fmri_',pnames{pp},'_rest_run_a_res.mnc.gz');
    
    files_out.dc_high = strcat(fs,NativPrepro,'/intermediate/',pnames{pp},'/time_filter//fmri_',pnames{pp},'_rest_run_a_res_dc_high.mat');
    files_out.dc_low  = strcat(fs,NativPrepro,'/intermediate/',pnames{pp},'/time_filter//fmri_',pnames{pp},'_rest_run_a_res_dc_low.mat');
    
    opt.hp= 0.0100;
    opt.lp= Inf;
    opt.flag_test= 0;
    opt.flag_mean= 1;
    opt.tr= -Inf;
    
    comm = 'niak_brick_time_filter';
    jname = strcat('time_filter_',pnames{pp});
    
    pipeline = psom_add_job(pipeline,jname,comm,files_in,files_out,opt);
    
    
    %%%%%
    % Step 4, run regress confounds (13b)
    %%%%
    clear files_in files_out opt jname comm;
    
    files_in.fmri = strcat(fs,NativPrepro,'/intermediate/',pnames{pp},'/resample//fmri_',pnames{pp},'_rest_run_a_res.mnc.gz');
    files_in.dc_high = strcat(fs,NativPrepro,'/intermediate/',pnames{pp},'/time_filter//fmri_',pnames{pp},'_rest_run_a_res_dc_high.mat');
    files_in.dc_low  = strcat(fs,NativPrepro,'/intermediate/',pnames{pp},'/time_filter//fmri_',pnames{pp},'_rest_run_a_res_dc_low.mat');
    files_in.motion_param = strcat(fs,NormPrepro,'/intermediate/',pnames{pp},'/motion_correction/motion_parameters_',pnames{pp},'_rest_run.mat');
    files_in.mask_brain = strcat(fs,NativPrepro,'/anat/',pnames{pp},'/func_',pnames{pp},'_mask_nativefunc.mnc.gz');
    files_in.mask_vent = strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'/corsica/',pnames{pp},'_mask_vent_nativefunc.mnc.gz');
    files_in.mask_wm = strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'/corsica/',pnames{pp},'_mask_wm_nativefunc.mnc.gz');
    
    files_out.scrubbing = strcat(fs,NativPrepro,'/intermediate/',pnames{pp},'/regress_confounds//scrubbing_',pnames{pp},'_rest_run.mat');
    files_out.compcor_mask = strcat(fs,NativPrepro,'/intermediate/',pnames{pp},'/regress_confounds//compcor_mask_',pnames{pp},'_rest_run.mnc.gz');
    files_out.confounds = strcat(fs,NativPrepro,'/intermediate/',pnames{pp},'/regress_confounds//confounds_gs_',pnames{pp},'_rest_run_cor.mat');
    files_out.filtered_data= strcat(fs,NativPrepro,'/intermediate/',pnames{pp},'/regress_confounds//fmri_',pnames{pp},'_rest_run_cor.mnc.gz');
    files_out.qc_compcor= strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'//regress_confounds/',pnames{pp},'_rest_run_qc_compcor_funcstereonl.mnc.gz');
    files_out.qc_slow_drift= strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'//regress_confounds/',pnames{pp},'_rest_run_qc_slow_drift_funcstereonl.mnc.gz');
    files_out.qc_high= strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'//regress_confounds/',pnames{pp},'_rest_run_qc_high_funcstereonl.mnc.gz');
    files_out.qc_wm= strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'//regress_confounds/',pnames{pp},'_rest_run_qc_wm_funcstereonl.mnc.gz');
    files_out.qc_vent= strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'//regress_confounds/',pnames{pp},'_rest_run_qc_vent_funcstereonl.mnc.gz');
    files_out.qc_motion= strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'//regress_confounds/',pnames{pp},'_rest_run_qc_motion_funcstereonl.mnc.gz');
    files_out.qc_custom_param= 'gb_niak_omitted';
    files_out.qc_gse= strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'//regress_confounds/',pnames{pp},'_rest_run_qc_gse_funcstereonl.mnc.gz');
    
    
    opt.flag_compcor= 0;
    opt.nb_vol_min= 40;%%%%<<<---------------------Keep or not?
    opt.flag_scrubbing= 1;%%%%<<<---------------------Keep or not?
    opt.thre_fd= 0.5000;%%%%<<<---------------------Keep or not?
    opt.flag_slow= 1;
    opt.flag_high= 0;
    opt.flag_motion_params= 1;
    opt.flag_wm= 1;
    opt.flag_vent= 1;
    opt.flag_gsc= 0;
    opt.flag_pca_motion= 1;
    opt.pct_var_explained= 0.9500;
    
    comm = 'niak_brick_regress_confounds';
    jname = strcat('confounds_',pnames{pp});
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
           %Verify whether scrubbing should be used, if not, change the
           %options here. Make sure this does not have an effect on
           %previous step
    
    pipeline = psom_add_job(pipeline,jname,comm,files_in,files_out,opt);
    
    %%%%%
    % Step 5, run spatial ICA (14b)
    %%%%
    clear files_in files_out opt jname comm;
    
    files_in.mask = strcat(fs,NativPrepro,'/anat/',pnames{pp},'/func_',pnames{pp},'_mask_nativefunc.mnc.gz');
    files_in.fmri = strcat(fs,NativPrepro,'/intermediate/',pnames{pp},'/regress_confounds//fmri_',pnames{pp},'_rest_run_cor.mnc.gz');;
    
    files_out.space = strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'/corsica//fmri_',pnames{pp},'_rest_run_cor_sica_space.mnc.gz');
    files_out.time = strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'/corsica//fmri_',pnames{pp},'_rest_run_cor_sica_time.mat');
    
    opt.nb_comp= 60;
    opt.norm= 'mean';
    opt.algo= 'Infomax';
    
    comm = 'niak_brick_sica';
    jname = strcat('sica_',pnames{pp});
    
    pipeline = psom_add_job(pipeline,jname,comm,files_in,files_out,opt);
    
    
    %%%%%
    % Step 6, select ventricles components (15b)
    %%%%
    clear files_in files_out opt jname comm;
    
    files_in.fmri= strcat(fs,NativPrepro,'/intermediate/',pnames{pp},'/regress_confounds//fmri_',pnames{pp},'_rest_run_cor.mnc.gz');
    files_in.component= strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'/corsica//fmri_',pnames{pp},'_rest_run_cor_sica_time.mat');
    files_in.mask= strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'/corsica/',pnames{pp},'_mask_vent_nativefunc.mnc.gz');
    files_in.transformation= 'gb_niak_omitted';
    files_in.component_to_keep= 'gb_niak_omitted';
    
    files_out = strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'/corsica//fmri_',pnames{pp},'_rest_run_cor_compsel_ventricles.mat');
    
    comm = 'niak_brick_component_sel';
    jname = strcat('comp_vent_',pnames{pp});
    
    pipeline = psom_add_job(pipeline,jname,comm,files_in,files_out);
    
    
    %%%%%
    % Step 7, select ventricles components (16b)
    %%%%
    clear files_in files_out opt jname comm;
    
    files_in.fmri= strcat(fs,NativPrepro,'/intermediate/',pnames{pp},'/regress_confounds//fmri_',pnames{pp},'_rest_run_cor.mnc.gz');
    files_in.component= strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'/corsica//fmri_',pnames{pp},'_rest_run_cor_sica_time.mat');
    files_in.mask= strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'/corsica/',pnames{pp},'_mask_stem_nativefunc.mnc.gz');
    files_in.transformation= 'gb_niak_omitted';
    files_in.component_to_keep= 'gb_niak_omitted';
    
    files_out = strcat(fs,NativPrepro,'/quality_control/',pnames{pp},'/corsica//fmri_',pnames{pp},'_rest_run_cor_compsel_stem.mat');
    
    comm = 'niak_brick_component_sel';
    jname = strcat('comp_stem_',pnames{pp});
    
    pipeline = psom_add_job(pipeline,jname,comm,files_in,files_out);
    
    
    %%%%%
    % Step 8,copy outputs of 13b (18b)
    %%%%
    clear files_in files_out opt jname comm;
    
    files_in = {strcat(fs,NativPrepro,'/intermediate/',pnames{pp},'/regress_confounds//fmri_',pnames{pp},'_rest_run_cor.mnc.gz')};
    
    opt.flag_fmri= 1;
    
    files_out = {strcat(fs,NativPrepro,'/intermediate/',pnames{pp},'/corsica/fmri_',pnames{pp},'_rest_run_cor_p.mnc.gz')};
    
    comm = 'niak_brick_copy';
    jname = strcat('comp_supp_',pnames{pp});
    
    pipeline = psom_add_job(pipeline,jname,comm,files_in,files_out,opt);
    
    %%%%%
    % Step 9, smoothing (20b). Should it be done??????
    %%%%
    clear files_in files_out opt jname comm;
    
    files_in = strcat(fs,NativPrepro,'/intermediate/',pnames{pp},'/corsica/fmri_',pnames{pp},'_rest_run_cor_p.mnc.gz');
    
    files_out = strcat(fs,NativPrepro,'/fmri/fmri_',pnames{pp},'_rest_run.mnc.gz');
    
    opt.flag_edge = 1;
    opt.fwhm = [6 6 6];
    
    comm = 'niak_brick_smooth_vol';
    jname = strcat('smooth_',pnames{pp});
    
    pipeline = psom_add_job(pipeline,jname,comm,files_in,files_out,opt);
end

%%%%%
% Last Step, lauching pipeline
%%%%
opt.psom.mode = 'session';
opt.psom.path_logs = strcat(fs,NativPrepro,'/logs');

psom_run_pipeline(pipeline,opt.psom);
