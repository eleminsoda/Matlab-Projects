% Computer Vision, Spring 2019, homework 2, assignment 2
% An implementation of Adaboost to compose a strong classifier.

samples = [[80, 144, +1]; [93, 232, +1]; [136, 275, -1]; [147, 131, -1]; ...
    [159, 69, +1]; [214, 31, +1]; [214, 152, -1]; [257, 83, +1]; [307, 62, -1]; [307, 231, -1]];

sample_size = size(samples, 1);
theta = 0.5;

% generate the weak classifiers
weak_classifiers = [];

%%% Plotting the Spots
% positive = [];
% negative = [];

% for i = samples'

%     if i(3) == 1
%         positive = [positive; i'];
%     else
%         negative = [negative; i'];
%     end

% end

% plot(positive(:, 1), positive(:, 2), '+');
% hold on;

% for i = positive'
%     text(i(1), i(2), ['(', num2str(i(1)), ',', num2str(i(2)), ')'])
% end

% plot(negative(:, 1), negative(:, 2), '*');

% for i = negative'
%     text(i(1), i(2), ['(', num2str(i(1)), ',', num2str(i(2)), ')'])
% end

% hold off;

weak_classifiers = generate_weak_classifier(samples, theta);
weak_classifiers = sortrows(weak_classifiers, 3);

% combine the weak classifiers using Adaboost
weight = ones(1, total_count) / total_count;

correct_classify = 0; % if the classifiers can classify the points correctly
classifier_index = 1;
alphas = [];

while ~correct_classify
    error_rate = weak_classifiers(classifier_index, 3) / sample_size;
    alpha = 0.5 * log((1 - error_rate) / error_rate);
    alphas = [alphas; alpha];

    correct_classify = check_correct_classify(weak_classifiers, alphas, samples)

end

function can_classify = check_correct_classify(weak_classifiers, alphas, samples)

    can_classify = 1;

    for point = samples
        temp = 0;

        for i = 1:length(alphas)
            temp = temp + alphas(i) * sgn(point(weak_classifiers(i, 1)), ...
                weak_classifiers(i, 2), weak_classifiers(i, 4));
        end

        if temp * point(3) > 0
            can_classify = 0;
        end

    end

end

function output = sgn(a, limit, reversed)

    if a < limit
        output = -1 * reversed;
    else
        output = 1 * reversed;
    end

end

function limits = generate_weak_classifier(samples, theta)
    x_list = (sort(samples(:, 1)))';
    y_list = (sort(samples(:, 2)))';
    list = [x_list; y_list];
    indexes = [1 1];
    limits = [];

    classifier_count = 0;
    orientation = 1;

    while (indexes(1) + indexes(2)) < 2 * size(samples, 1)
        qualified = 0;

        while (~qualified)

            if indexes(orientation) >= size(samples, 1)
                break;
            end

            temp = list(orientation, :);
            limit = temp(indexes(orientation)) + 1;
            error_count = 0;
            positive_error = 0;
            negative_error = 0;
            positive_or_negative = 0;

            for i = 1:size(samples, 1)

                if (samples(i, orientation) > limit) && (samples(i, 3) ~= 1)
                    positive_error = positive_error + 1;
                elseif (samples(i, orientation) < limit) && (samples(i, 3) ~= -1)
                    positive_error = positive_error + 1;
                end

                if (samples(i, orientation) < limit) && (samples(i, 3) ~= 1)
                    negative_error = negative_error + 1;
                elseif (samples(i, orientation) > limit) && (samples(i, 3) ~= -1)
                    negative_error = negative_error + 1;
                end

            end

            if positive_error > negative_error
                error_count = negative_error;
                positive_or_negative = -1;
            else
                error_count = positive_error;
                positive_or_negative = 1;
            end

            if error_count < round(theta * size(samples, 1))
                qualified = 1;
                classifier_count = classifier_count + 1;
                limits = [limits; orientation, limit, error_count, positive_or_negative];
            end

            indexes(orientation) = indexes(orientation) + 1;

        end

        if orientation == 1
            orientation = 2;
        else
            orientation = 1;
        end

    end

end
