function [files_in,files_out,opt] = max_niak_brick_mask_corsica(files_in,files_out,opt)
% Thix is a modified version by MPelland of niak_brick_mask_corsica from
% niak version 0.7c3
%
%In this version, all output masks will be in the native space of the
%participant (so no normalization). 
%
%mask_corsica_CBxxxVDAlCh.files_in.transformation_nl   /home/mpelland/database/blindtvr/fmri/tempRawMncData/prepro/anat/CBxxxVDAlCh/transf_CBxxxVDAlCh_stereolin_to_stereonl.xfm
% change2 nativefun2stereonl
%
% _________________________________________________________________________
% Copyright (c) Pierre Bellec, Centre de recherche de l'institut de
% geriatrie de Montreal, Departement d'informatique et recherche 
% operationnelle, Universite de Montreal, 2010.
% Maintainer : pbellec@criugm.qc.ca
% See licensing information in the code.
% Keywords : CORSICA, fMRI, physiological noise

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Seting up default arguments %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('files_in','var')
    error('niak:brick','syntax: [FILES_IN,FILES_OUT,OPT] = NIAK_BRICK_MASK_GROUP(FILES_IN,FILES_OUT,OPT).\n Type ''help niak_brick_mask_group'' for more info.')
end

%% FILES_IN
gb_name_structure = 'files_in';
gb_list_fields    = {'mask_brain' , 'mask_vent_stereo' , 'mask_wm_stereo' , 'mask_stem_stereo' , 'functional_space' , 'transformation_nl' , 'segmentation' , 'aal' };
gb_list_defaults  = {NaN          , NaN                , NaN              , NaN                , NaN                , NaN                 , NaN            , NaN   };
psom_set_defaults

%% FILES_OUT
gb_name_structure = 'files_out';
gb_list_fields    = {'white_matter_ind' , 'mask_vent_ind' , 'mask_stem_ind' };
gb_list_defaults  = {NaN                , NaN             , NaN             };
psom_set_defaults

%% Options
gb_name_structure = 'opt';
gb_list_fields    = { 'target_space' , 'flag_verbose' , 'flag_test' , 'folder_out' };
gb_list_defaults  = { 'stereonl'     , true           , false       , ''           };
psom_set_defaults

if flag_test == 1
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The brick starts here %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
folder_tmp = niak_path_tmp('_mask_corsica');
[path_f,name_f,ext_f] = niak_fileparts(files_in.mask_vent_stereo);

%% Resampling the mask of the white matter in target space
if flag_verbose
    tic;
    fprintf('Resampling the template mask of the white matter in %s functional space - ',opt.target_space)
end
clear files_in_res files_out_res opt_res
files_in_res.source         = files_in.mask_wm_stereo;
files_in_res.target         = files_in.functional_space;
files_in_res.transformation = files_in.transformation_nl;
opt_res.flag_invert_transf  = true;
files_out_res               = [folder_tmp 'mask_wm_template.mnc'];
opt_res.interpolation       = 'nearest_neighbour';
niak_brick_resample_vol(files_in_res,files_out_res,opt_res);
if flag_verbose    
    fprintf('%1.2f sec.\n',toc)
end

%% Resampling the mask of the ventricle in target space
if flag_verbose
    tic;
    fprintf('Resampling the mask of the ventricle in %s functional space - ',opt.target_space)
end
clear files_in_res files_out_res opt_res
files_in_res.source         = files_in.mask_vent_stereo;
files_in_res.target         = files_in.functional_space;
files_in_res.transformation = files_in.transformation_nl;
opt_res.flag_invert_transf  = true;
files_out_res               = [folder_tmp 'mask_vent_ind.mnc'];
opt_res.interpolation       = 'nearest_neighbour';
niak_brick_resample_vol(files_in_res,files_out_res,opt_res);
if flag_verbose    
    fprintf('%1.2f sec.\n',toc)
end

%% Resampling the AAL template in target space
if flag_verbose
    tic;
    fprintf('Resampling the AAL template in %s functional space - ',opt.target_space)
end
clear files_in_res files_out_res opt_res
files_in_res.source         = files_in.aal;
files_in_res.target         = files_in.functional_space;
files_in_res.transformation = files_in.transformation_nl;
opt_res.flag_invert_transf  = true;
files_out_res               = [folder_tmp 'mask_aal.mnc'];
opt_res.interpolation       = 'nearest_neighbour';
niak_brick_resample_vol(files_in_res,files_out_res,opt_res);
if flag_verbose    
    fprintf('%1.2f sec.\n',toc)
end

%% Resampling the mask of the brain stem in native space
if flag_verbose
    tic;
    fprintf('Resampling the mask of the brain stem in native space - ')
end
clear files_in_res files_out_res opt_res
files_in_res.source         = files_in.mask_stem_stereo;
files_in_res.target         = files_in.functional_space;
files_in_res.transformation = files_in.transformation_nl;
opt_res.flag_invert_transf  = true;
files_out_res               = [folder_tmp 'mask_stem_ind.mnc'];
opt_res.interpolation       = 'nearest_neighbour';
niak_brick_resample_vol(files_in_res,files_out_res,opt_res);
if flag_verbose    
    fprintf('%1.2f sec.\n',toc)
end

%% Combining ventricle and CSF masks
if flag_verbose
    tic;
    fprintf('Combining ventricle and CSF masks - ')
end
clear files_in_math files_out_math opt_math
files_in_math{1}    = files_in.segmentation;
files_in_math{2}    = [folder_tmp 'mask_vent_ind.mnc'];
files_out_math      = files_out.mask_vent_ind;
opt_math.operation  = 'vol = (vol_in{2} > 0) & (round(vol_in{1}) == 1);';
niak_brick_math_vol(files_in_math,files_out_math,opt_math);
if flag_verbose    
    fprintf('%1.2f sec.\n',toc)
end

%% Combining template and individual white matter masks
if flag_verbose
    tic;
    fprintf('Combining ventricle and CSF masks - ')
end
clear files_in_math files_out_math opt_math
files_in_math{1}    = files_in.segmentation;
files_in_math{2}    = [folder_tmp 'mask_wm_template.mnc'];
files_out_math      = files_out.white_matter_ind;
opt_math.operation  = 'vol = (vol_in{2} > 0) & (round(vol_in{1}) == 3);';
niak_brick_math_vol(files_in_math,files_out_math,opt_math);
if flag_verbose    
    fprintf('%1.2f sec.\n',toc)
end

%% Combining brain and gray matter masks
if flag_verbose
    tic;
    fprintf('Excluding gray matter from brain stem mask - ')
end
clear files_in_math files_out_math opt_math
files_in_math{1}    = files_in.segmentation;;
files_in_math{2}    = [folder_tmp 'mask_stem_ind.mnc'];
files_out_math      = files_out.mask_stem_ind;
opt_math.operation  = 'vol = (vol_in{2} > 0) & (round(vol_in{1}) ~= 2);';
niak_brick_math_vol(files_in_math,files_out_math,opt_math);
if flag_verbose    
    fprintf('%1.2f sec.\n',toc)
end
        
%% Clean up temporary files
[status,msg] = system(['rm -rf ' folder_tmp]);
if status ~= 0
    error(sprintf('There was a problem cleaning up the temporary folder.\nThe command was : %s\n The feedback was: %s\n'),['rm -rf ' folder_tmp],msg);
end