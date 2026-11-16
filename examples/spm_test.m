% Quick check that standalone SPM works: prints the version and reads a template image.
% Run with:  spm26 script examples/spm_test.m
disp(spm('Ver'));
V = spm_vol(fullfile(spm('Dir'), 'canonical', 'single_subj_T1.nii'));
fprintf('Read %s: %d x %d x %d\n', V.fname, V.dim);
disp('SPM test OK');
