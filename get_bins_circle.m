function DD = get_bins_circle(corrected_angles,accuracy) 

corrected_angles_deg = corrected_angles * 360 / (2*pi);

angs = 0:15:360;

temp2 = zeros(size(corrected_angles_deg));

for p = 1:length(angs)-1
    inds = (corrected_angles_deg > angs(p)) & (corrected_angles_deg < angs(p+1));
    CC{p} = accuracy(inds);
end

DD(1) = mean( [CC{1} CC{end}]);
DD(2) = mean( [CC{2} CC{3}]);
DD(3) = mean( [CC{4} CC{5}]);
DD(4) = mean( [CC{6} CC{7}]);
DD(5) = mean( [CC{8} CC{9}]);
DD(6) = mean( [CC{10} CC{11}]);
DD(7) = mean( [CC{12} CC{13}]);
DD(8) = mean( [CC{14} CC{15}]);
DD(9) = mean( [CC{16} CC{17}]);
DD(10) = mean( [CC{18} CC{19}]);
DD(11) = mean( [CC{20} CC{21}]);
DD(12) = mean( [CC{22} CC{23}]);

