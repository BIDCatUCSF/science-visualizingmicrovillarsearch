imwrite(tContactsPixels_l(:,:,1),'MapStack.tif','compression','none')
%imwrite(tContactsPixels_l(:,:,2),'MapStack.tif','writemode','append','compression','none')
SizeC=size(tContactsPixels_l);
for kk=2:SizeC(3)
imwrite(tContactsPixels_l(:,:,kk),'MapStack.tif','writemode','append','compression','none');
end