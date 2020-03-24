function report = qtb_compare(res1,res2)

if ~isfield(res1,'name')
    res1.name = 'Result 1';
end
if ~isfield(res2,'name')
    res1.name = 'Result 2';
end

for j_test = 1:length(res1.tests)
    test1 = res1.tests{j_test};
    test2 = res2.tests{j_test};
    fprintf('===> Comparing test %d/%d: %s\n', j_test, length(res1.tests), test1.name);
    EstimatorName = {res1.name; res2.name};
    Fidelity = {[errorstr(test1.fidelity*100),char(37)]; [errorstr(test2.fidelity*100),char(37)]};
    MeasurementNum = [mean(test1.nmeas(:)); mean(test2.nmeas(:))];
    TimeProto = [mean(test1.time_proto(:)); mean(test2.time_proto(:))];
    TimeEst = [mean(test1.time_est(:)); mean(test2.time_est(:))];
    disp(table(EstimatorName, Fidelity, MeasurementNum, TimeProto, TimeEst));
    
    figure; hold on; grid on;
    histogram(test1.fidelity(1,1,:),'DisplayName',res1.name);
    histogram(test2.fidelity(1,1,:),'DisplayName',res2.name);
    xlabel('Fidelity');
    legend('show');
    title(test1.name);
end

end

function str = errorstr(arr)
str = sprintf('%.2f%s%.2f', mean(arr(:)), char(177), std(arr(:)));
end