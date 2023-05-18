data = load("correspondencias2.mat");

data = data.array_de_correspondencias_filtrado;

imagen1 = 1;
imagen2 = 2;

jf = correspondeciasDeImagen(data,imagen1,imagen2);
matchedPoints1 = jf(:,1:2);
matchedPoints2 = jf(:,3:4);

I1 = imread(imagen1+".jpg");
I2 = imread(imagen2+".jpg");

I1 = imresize(I1,0.33);
I2 = imresize(I2,0.33);

figure;
showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2,"montage",PlotOptions=["ro","go","y--"]);
title("Putative Point Matches");

function c = correspondeciasDeImagen(datos, origen, destino)
    b = datos(:,2) == destino & datos(:,1) == origen;
    c = datos(b>0,:);

    c = c(:,3:6);
end