A = [2.38 4.90; 1.24 3.38; 2.93 1.30; 0.45 4.11];

alpha = [46 42 90];

l1 = [A(1,1)+2*cosd(46) A(1,2)+2*sind(46)];
l2 = [A(2,1)+2*cosd(42) A(2,2)+2*sind(42)];
l3 = [A(3,1)+2*cosd(90) A(3,2)+2*sind(90)];

figure;
scatter(A(:,1),A(:,2));
ylim([0 6]);
xlim([0 6]);
%{
hold on;
line([2.38 A(1,1)+2*cosd(46)],[4.90 A(1,2)+2*sind(46)]);
hold on;
line([1.24 A(2,1)+2*cosd(42)],[3.38 A(2,2)+2*sind(42)]);
hold on;
line([2.93 A(3,1)+2*cosd(90)],[1.30 A(3,2)+2*sind(90)]);
%}