% Computer Vision, Spring 2019, homework 2, assignment 2
% An implementation of Adaboost to compose a strong classifier.

samples = [[80, 144, +1]; [93, 232, +1]; [136, 275, -1]; [147, 131, -1]; ...
    [159, 69, +1]; [214, 31, +1]; [214, 152, -1]; [257, 83, +1]; [307, 62, -1]; [307, 231, -1]];

sample_size = size(samples, 1);
theta = 0.5;

% generate the weak classifiers
classifier_count = 0;
total_count = 5;

for classifier_count = 1:total_count

end

function limit = generate_weak_classifier(mode)
    qualified = 0;

    while (~qualified)
        limit = rand(1) * sample_size;
        error_count = 0;

        for i = 1:sample_size

            if (samples(i, mode) > limit) && (samples(i, 3) ~= 1)
                error_count = error_count + 1;
            end

            if (samples(i, mode) < limit) && (samples(i, 3) ~= -1)
                error_count = error_count + 1;
            end

        end

        if error_count < theta * sample_size
            qualified = 1;
        end

    end

end
