
% load image
im_red = double(imread('red.jpg')); %double คือเราจะทำให้ range มันกว้างขึ้นเพื่อให้มีค่าที่ติดลบได้ด้วย
im_green = double(imread('green.jpg'));
im_blue = double(imread('blue.jpg'));

% specify image width and height
im_width = 1000; %เพื่อที่จะคล๊อปรูปให้กว้าง 1000
im_height = 1000; %เพื่อที่จะคล๊อปรูปให้สูง 1000

% crop im_red
[h, w, ~] = size(im_red); %กำหนดตัวแปรแต่ละตัวให้มีขนาดเท่ารูปจริง
w_left = floor(abs(w-im_width)/2); % พื้นที่ๆจะตัดฝั่งซ้าย
w_right = abs(w-im_width) - w_left+1;% พื้นที่ๆจะตัดฝั่งขวา

h_up = floor(abs(h-im_height)/2);% พื้นที่ๆจะตัดข้างบน
h_down = abs(h-im_height) - h_up+1;% พื้นที่ๆจะตัดข้างล่าง

cim_red = im_red(h_up:h-h_down, w_left:w-w_right);% คล็อปรูปโดยบอกขนาดที่จะตัด

% crop im_green
[h, w, ~] = size(im_green);
w_left = floor(abs(w-im_width)/2);
w_right = abs(w-im_width) - w_left+1;

h_up = floor(abs(h-im_height)/2);
h_down = abs(h-im_height) - h_up+1;

cim_green = im_green(h_up:h-h_down, w_left:w-w_right);

% crop im_blue
[h, w, ~] = size(im_blue);
w_left = floor(abs(w-im_width)/2);
w_right = abs(w-im_width) - w_left+1;

h_up = floor(abs(h-im_height)/2);
h_down = abs(h-im_height) - h_up+1;

cim_blue = im_blue(h_up:h-h_down, w_left:w-w_right);

% define step range
MAX_STEPS = 100;% ตัดให้เป็นสี่เหลี่ยมขนาด 200 * 200

start_rows = im_height/2 - MAX_STEPS;
end_rows = start_rows + (MAX_STEPS*2) - 1;

start_cols = im_width/2 - MAX_STEPS; 
end_cols =  start_cols + (MAX_STEPS*2) - 1;

% extract red patch
red_patch = cim_red(start_rows:end_rows, start_cols:end_cols);       
green_dist = realmax; % จำนวนจริงที่มากที่สุด
blue_dist = realmax;


for rows = -MAX_STEPS : MAX_STEPS
    start_rows = im_height/2 + rows; % กำหนดแถวแรกของการเริ่มต้นทุกๆลูป
    end_rows = start_rows + (MAX_STEPS*2) - 1; % กำหนดตัว
    
    for cols = -MAX_STEPS : MAX_STEPS
        start_cols = im_width/2 + cols;
        end_cols = start_cols + (MAX_STEPS*2)-1;
    
    
        green_patch = cim_green(start_rows:end_rows, start_cols:end_cols);
        tmp_g = norm(red_patch(:) - green_patch(:)); % หาค่าผลต่างในแต่ละครั้งของการเขยิบ

        
        if tmp_g < green_dist
            green_dist = tmp_g;
            green_rows = start_rows;
            green_cols = start_cols;
            good_green = green_patch;
        end
    end
end

for rows = -MAX_STEPS : MAX_STEPS
    start_rows = im_height/2 + rows; % กำหนดแถวแรกของการเริ่มต้นทุกๆลูป
    end_rows = start_rows + (MAX_STEPS*2) - 1; % กำหนดตัว
    
    for cols = -MAX_STEPS : MAX_STEPS
        start_cols = im_width/2 + cols;
        end_cols = start_cols + (MAX_STEPS*2)-1;
    
    
       
        blue_patch = cim_blue(start_rows:end_rows, start_cols:end_cols);
        tmp_b = norm(good_green(:) - blue_patch(:)); % หาค่าผลต่างในแต่ละครั้งของการเขยิบ

       
        if tmp_b < blue_dist
            blue_dist = tmp_b;
            blue_rows = start_rows;
            blue_cols = start_cols;
            good_blue = blue_patch;
        end
    end
end


patch_result = zeros(MAX_STEPS*2, MAX_STEPS*2, 3); % ปูสีขาวขนาด 200 * 200 *3
patch_result(:,:,1) = red_patch; % ปูรูปเล็กสีแดงใน layer1
patch_result(:,:,2) = cim_green(green_rows:green_rows+(MAX_STEPS*2)-1, green_cols:green_cols+(MAX_STEPS*2)-1); 
patch_result(:,:,3) = cim_blue(blue_rows:blue_rows+(MAX_STEPS*2)-1, blue_cols:blue_cols+(MAX_STEPS*2)-1); 



im_result = zeros(im_height, im_width, 3);
im_result(:,:,1) = cim_red;

start_rows = green_rows - (im_height/2 - MAX_STEPS);
start_cols = green_cols - (im_width/2 - MAX_STEPS);
im_result(1:im_height-start_rows, 1:im_width-start_cols,2) =  cim_green(start_rows:im_height-1, start_cols:im_height-1);
start_rows = blue_rows - (im_height/2 - MAX_STEPS);
start_cols = blue_cols - (im_width/2 - MAX_STEPS);
im_result(1:im_height-start_rows, 1:im_width-start_cols,3) =  cim_blue(start_rows:im_height-1, start_cols:im_height-1);

imshow(im_result./255);