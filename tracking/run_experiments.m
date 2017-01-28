
% for i = 12:20
%     testdir = sprintf('./test/video%02d/', i);
%     single_tracking1(testdir);
%     single_tracking2(testdir, 256);
%     single_tracking2(testdir, 1024);
%     single_tracking2(testdir, 4096);
%     single_tracking4(testdir);
%     
% end
% a = [1,4,19,20];
for i = 10:10
    testdir = sprintf('./test/video%02d/', i);
%     single_tracking1(testdir);
    single_tracking2(testdir, 256);
    single_tracking2(testdir, 1024);
    single_tracking2(testdir, 4096);
    single_tracking3(testdir);
%     single_tracking4(testdir);
    
end


% test_dir = sprintf('./test/video%02d/', 11);
% single_tracking4(test_dir);
