function newImage = reduceWidth(img, numPixels)
    newImage = img;
    for i = 1:numPixels
        i
        [verticalSeam, energy, map] = getVerticalSeam(newImage);
        newImage = knockOutPixels(newImage, verticalSeam);
    end
    

    imwrite(newImage, 'wid.jpg')
    subplot(1, 2, 1), imshow(newImage)
    subplot(1, 2, 2), imshow(img)
end


function newImage = knockOutPixels(img, seam)
    [m, n, k] = size(img);
    newImage = zeros(m, n-1, k, class(img));
    for i = 1:m
        correction = 0;
        for j = 1:n
            if j ~= seam(i, 2)
                for l = 1:3
                    newImage(i, j - correction, l) = img(i, j, l);
                end
            else
                correction = 1;
            end
        end
    end
end


function [verticalSeam, energy, M] = getVerticalSeam(img)
    [m, n, k] = size(img);

    %precompute energy
    energy = zeros(m, n);
    imgDouble = im2double(rgb2gray(img));
    dx = imfilter(imgDouble, fspecial('prewitt')');
    dy = imfilter(imgDouble, fspecial('prewitt'));
    for i = 1:m
        for j = 1:n
            energy(i, j) = norm(dx(i, j)) + norm(dy(i, j));
        end
    end

    %dp array
    M = zeros(m, n);
    M(1, :) = energy(1, :);

    %loop over pixels
    for i = 2:m
        for j = 1:n

            val = M(i-1, j);

            %account for boundaries
            if j + 1 <= n & (M(i-1, j+1) < val)
                val = M(i-1, j+1);
            end
            if j - 1 >= 1 & (M(i-1, j-1) < val)
                val = M(i-1, j-1);
            end

            M(i, j) = energy(i, j) + min(val);
        end
    end

    %create a 1x2 matrix with the initial r,c of M
    [r, c] = find(M(m, :) == min(M(m, :)));
    verticalSeam = [m, c];
    
    for i = m-1:-1:1

        col = c;
        %we don't want to include the padded columns
        if c + 1 <= n & (M(i, c+1) < M(i, col))
            col = c + 1;
        end

        if c - 1 >= 1 & (M(i, c-1) < M(i, col))
            col = c - 1;
        end

        %new c for the new seam
        c = col;

        %a bug initally had this flipped and when
        %I went to remove pixels, the axis was flipped
        verticalSeam = [[i, c]; verticalSeam];
    end

end

