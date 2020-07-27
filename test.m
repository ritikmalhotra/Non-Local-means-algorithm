
image = im2double(imread('/Users/ritikmalhotra/Desktop/ultrasound.jpg'));


image1=rgb2gray(image);
figure()
imshow(image1);
noisy = imnoise(image1,'speckle',0.2);
% Denoising parameters
t = 3;
f = 2;
h1 = 1;
h2 = .1;
selfsim = 0;
tic
denoised = simple_nlm(noisy,t,f,h1,h2,selfsim);
cpuTime=toc;
figure()
subplot(2,2,1),imshow(image1),title('original');
subplot(2,2,2),imshow(noisy),title('noisy');
subplot(2,2,3),imshow(denoised),title('filtered');
subplot(2,2,4),imshow(noisy-denoised),title('residuals');
mse = norm(image-denoised, 'fro')/numel(image);
psnr = 10*log10(1/mse);aa