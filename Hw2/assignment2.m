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
% weak_classifiers = sortrows(weak_classifiers, 3);

% combine the weak classifiers using Adaboost
weights = ones(1, sample_size) / sample_size;

correct_classify = []; % if the classifiers can classify the points correctly
classifier_index = 1;
classifier_indexes = [];
alphas = [];
finished = 0;

while ~finished
    error_rate = 0;
    [classifier_index, error_rate] = find_best_weak_classifier(weak_classifiers, weights, samples, classifier_indexes);

    alpha = 0.5 * log((1 - error_rate) / error_rate);
    alphas = [alphas; alpha];
    classifier_indexes = [classifier_indexes; classifier_index];

    indicators = zeros(1, size(samples, 1));

    for i = 1:length(alphas)

        correct_classify = check_correct_classify(weak_classifiers(classifier_indexes(i), :), samples);

        for j = 1:size(samples, 1)
            indicators(j) = indicators(j) + correct_classify(j) / samples(j, 3) * alphas(i);
        end

    end

    for i = 1:length(indicators)
        indicators(i) = sgn(indicators(i), 0, 1);
    end

    temp = 1;

    for i = 1:length(indicators)

        if indicators(i) ~= samples(i, 3)
            temp = 0;
            break;
        end

    end

    if temp
        finished = 1;
        disp(alphas);
        disp(classifier_indexes);
    end

    weights = update_samples_weights(samples, alpha, weights, correct_classify);

end

function [index, error_rate] = find_best_weak_classifier(weak_classifiers, weights, samples, classifier_indexes)
    index = 0;
    error_rate = 10000;

    for i = 1:size(weak_classifiers, 1)
        temp = 0;
        can_classify = check_correct_classify(weak_classifiers(i, :), samples);

        for j = 1:length(weights)

            if can_classify(j) == -1
                temp = temp + weights(j);
            end

        end

        if (temp < error_rate) && (~ismember(i, classifier_indexes))
            error_rate = temp;
            index = i;

        end

    end

end

function weights = update_samples_weights(samples, alpha, weights, correct_classify)

    for i = 1:size(samples, 1)
        weights(i) = weights(i) * exp(-1 * alpha * correct_classify(i));
    end

    total = sum(weights);

    for i = 1:length(weights)
        weights(i) = weights(i) / total;
    end

end

% check if the current classifier can classify the points correctly
function correct_classify = check_correct_classify(weak_classifier, samples)

    correct_classify = [];

    for point = samples'
        temp = 0;

        temp = sgn(point(weak_classifier(1)), ...
            weak_classifier(2), weak_classifier(4));

        if temp * point(3) < 0
            correct_classify = [correct_classify; -1];
        else
            correct_classify = [correct_classify; 1];
        end

    end

end

function output = sgn(a, limit, reversed)

    if a < limit
        output = -1 * reversed;
    elseif a == limit
        output = 0;
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
                limits = [limits; orientation, limit, error_count / size(samples, 1), positive_or_negative];
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
