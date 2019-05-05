% Computer Vision, Spring 2019, homework 2, assignment 2
% An implementation of Adaboost to compose a strong classifier.

samples = [[80, 144, +1]; [93, 232, +1]; [136, 275, -1]; [147, 131, -1]; ...
    [159, 69, +1]; [214, 31, +1]; [214, 152, -1]; [257, 83, +1]; [307, 62, -1]; [307, 231, -1]];

sample_size = size(samples, 1);
theta = 0.5;

% generate the weak classifiers
total_count = 5;
weak_classifiers = [];

weak_classifiers = generate_weak_classifier(total_count, samples, theta)

% combine the weak classifiers using Adaboost
weight = ones(1, total_count) / total_count

function limit = generate_weak_classifier(total_count, samples, theta)
    x_list = sort(samples(:, 1));
    y_list = sort(samples(:, 2));
    x_index = 1;
    y_index = 1;

    classifier_count = 0;
    orientation = 1;

    while classifier_count < total_count
        qualified = 0;

        while (~qualified)

            if orientation == 1 && x_index >= size(samples, orientation)
                break;
            end

            if orientation == 2 && y_index >= size(samples, orientation)
                break;
            end

            limit = x_list(x_index) + 1;
            error_count = 0;

            for i = 1:size(samples, 1)

                if (samples(i, orientation) > limit) && (samples(i, 3) ~= 1)
                    error_count = error_count + 1;
                end

                if (samples(i, orientation) < limit) && (samples(i, 3) ~= -1)
                    error_count = error_count + 1;
                end

            end

            if error_count < round(theta * size(samples, 1))
                qualified = 1;
                classifier_count = classifier_count + 1;
            end

            if orientation == 1
                x_index = x_index + 1;
            end

            if orientation == 2
                y_index = y_index + 1;
            end

        end

        if orientation == 1
            orientation = 2;
        end

        if orientation == 2
            orientation = 1;
        end

    end

end
