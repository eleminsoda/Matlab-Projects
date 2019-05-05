% Computer Vision, Spring 2019, homework 2, assignment 1
% An implementation of RANSAC to fit a straight 2D line.

points = [[-2, 0]; [0, 0.9]; [2, 2.0]; [3, 6.5]; [4, 2.9]; [5, 8.8]; [6, 3.95]; [8, 5.03]; [10, 5.97]; ...
    [12, 7.1]; [13, 1.2]; [14, 8.2]; [16, 8.5]; [18, 10.1]];

up_limit = 0.8 * size(points, 1);
botton_limit = 0.5 * size(points, 1);

best_consensus_set = [];

max_iteration = 20;
iteration = 0;

while (iteration < max_iteration)
    inliers = randperm(size(points, 1), 2);
    consensus_set = inliers;

    for point = [1:size(points, 1)]

        if (~ismember(point, inliers))

            if calculate_dis_p2l(points(point, :), points(inliers(1), :), points(inliers(2), :)) < 0.5
                consensus_set = [consensus_set, point];
            end

        end

    end

    if size(consensus_set, 2) > size(best_consensus_set, 2)
        best_consensus_set = consensus_set;
    end

    if length(best_consensus_set) >= up_limit
        break;
    end

    iteration = iteration + 1;
end

model = polyfit(points(best_consensus_set, 1), points(best_consensus_set, 2), 1);

x = [-10:0.01:20];
y = model(1) * x + model(2);
plot(points(:, 1), points(:, 2), '*', x, y, 'r');

function dis = calculate_dis_p2l(P, Q1, Q2)
    dis = abs(det([Q2 - Q1; P - Q1])) / norm(Q2 - Q1);
end
