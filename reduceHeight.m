function newImage = reduceHeight(img, numPixels)
    newImage = img;
    for i = 1:numPixels
        i
        [horizSeam, energy, map] = getHorizSeam(newImage);
        newImage = knockOutPixels(newImage, horizSeam);
    end

    imwrite(newImage, 'new.jpg')
    subplot(1, 2, 1), imshow(newImage)
    subplot(1, 2, 2), imshow(img)
end


function newImage = knockOutPixels(img, seam)
    [m, n, k] = size(img);
    newImage = zeros(m-1, n, k, class(img));
    for j = 1:n
        correction = 0;
        for i = 1:m
            if i ~= seam(j, 1)
                for l = 1:3
                    newImage(i - correction, j, l) = img(i, j, l);
                end
            else
                correction = 1;
            end
        end
    end
end


function [horizSeam, energy, M] = getHorizSeam(img)
    [m, n, k] = size(img);
    
    energy = zeros(m, n);
    imgDouble = im2double(rgb2gray(img));
    dx = imfilter(imgDouble, fspecial('prewitt')');
    dy = imfilter(imgDouble, fspecial('prewitt'));
    for i = 1:m
        for j = 1:n
            energy(i, j) = norm(dx(i, j)) + norm(dy(i, j));
        end
    end

    M = zeros(m, n);
    M(:, 1) = energy(:, 1);

    for j = 2:n
        for i = 1:m

            %j-1 and i, i+1, i-1
            val = M(i, j-1);

            if i-1 >= 1 & (M(i-1, j-1) < val)
                val = M(i-1, j-1);
            end

            if i+1 <= m & (M(i+1, j-1) < val)
                val = M(i+1, j-1);
            end

            M(i, j) = energy(i, j) + val;

        end
    end


    [r, c] = find(M(:, n) == min(M(:, n)));
    r = r(1);
    horizSeam = [r, n];

    for j = n-1:-1:1
        row = r;

        if r-1 >= 1 & (M(r-1, j) < M(r, j))
            row = r - 1;
        end

        if r+1 <= m & (M(r+1, j) < M(row, j))
            row = r + 1;
        end

        %a bug initally had this flipped and when
        %I went to remove pixels, the axis was flipped
        horizSeam = [[row, j]; horizSeam];

        r = row;

    end
end
