









function [I_scaled intensity_tissue] = normalize_tissue_to_1(I)

    intensity_range = linspace(0,max(I(:)),500);
    hist_I = hist(I(:),intensity_range);

    [pks locs] = findpeaks(hist_I);
    % locs(find(pks<1e6))=[];
    % intensity_tissue = intensity_range(locs(2));% second peak is the tissue

    [sorted_pks sorted_inds] = sort(pks,'descend');
    intensity_tissue = intensity_range(locs(sorted_inds(2)));% second peak is the tissue

    
    I_scaled = I/intensity_tissue;
end