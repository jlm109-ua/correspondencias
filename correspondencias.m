%% Leer imagen
num_imagenes = 13;

array_de_caracteristicas = [];

array_de_searchers = cell(1,13);


%% Realizar las correspondencias entre todos los pares de imágenes.

for xi = 1 : num_imagenes 
    imagen = imread("./"+xi+".jpg");
    imagen = rgb2gray(imagen);
    imagen = imresize(imagen,0.33);

    %imshow(imagen);
    points = detectSIFTFeatures(imagen);

    % Construccion del kdtree
    pointsMat = zeros(size(points,1), 8);
    
    %Obtengo todos los datos de la imagen
    for yi = 1:size(points, 1)
        pointsMat(yi, 1) = double(points.Scale(yi));
        pointsMat(yi, 2) = double(points.Orientation(yi));
        pointsMat(yi, 3) = double(points.Octave(yi));
        pointsMat(yi, 4) = double(points.Layer(yi));
        pointsMat(yi, 5) = double(points.Location(yi,1));
        pointsMat(yi, 6) = double(points.Location(yi,2));
        pointsMat(yi, 7) = double(points.Metric(yi));
        pointsMat(yi, 8) = xi;
    end

    %Guardo el array de caracteristicas
    
    array_de_caracteristicas= [array_de_caracteristicas; pointsMat ];

    %Pongo dentro del array el searcher
    array_de_searchers(1,xi) = {KDTreeSearcher(pointsMat)};
end

%% Matching entre descriptores de dos imagenes
array_de_correspondencias_sinfiltrar = [];

for vi = 1 : num_imagenes 
    
    for bi = 1 : num_imagenes

        if vi == bi; continue; end

        caracteristicas = array_de_caracteristicas(array_de_caracteristicas(:,8) == vi, :);
    
        for ei = 1 : size(array_de_searchers)
       
            if ei == vi; continue; end
    
            for ki = 1 : size(caracteristicas)
                [IdxNN, D] = knnsearch(array_de_searchers{ei}, caracteristicas(ki,:), 'k', 2);
            
                esCorrespondencia = D(1)/D(2) > 0.6;
    
                if esCorrespondencia 
                    
                    correspondencia = [vi, ei , caracteristicas(ki,5), caracteristicas(ki,6), array_de_searchers{ei}.X(IdxNN(1),5), array_de_searchers{ei}.X(IdxNN(1),6)];
                    array_de_correspondencias_sinfiltrar = [array_de_correspondencias_sinfiltrar; correspondencia ];
        
                end 
            end  
        end
    end
end

%% Array que elimina correspondencias peores
array_de_correspondencias_filtrado = [];

tam_sf = size(array_de_correspondencias_sinfiltrar,1);

for li = 1 : tam_sf

    correspondencia_b = array_de_correspondencias_sinfiltrar(li,:);
    correspondencia_b = [correspondencia_b(2),correspondencia_b(1), correspondencia_b(5:6), correspondencia_b(3:4)];

    mutuo = array_de_correspondencias_sinfiltrar(array_de_correspondencias_sinfiltrar == correspondencia_b);

    % mutuo = extraerMutuo(array_de_correspondencias_sinfiltrar, correspondencia_b);

    if size(mutuo,1) > 0
        array_de_correspondencias_filtrado = [array_de_correspondencias_filtrado; correspondencia_b];

        % pos_a_eliminar = find(array_de_correspondencias_filtrado == correspondencia_b);
        % 
        % if pos_a_eliminar == 1
        %     array_de_correspondencias_filtrado = array_de_correspondencias_filtrado( pos_a_eliminar + 1  : end, :  );
        % elseif pos_a_eliminar == size(array_de_correspondencias_filtrado,1)
        %     array_de_correspondencias_filtrado = array_de_correspondencias_filtrado( 1  : pos_a_eliminar - 1, : ) ;
        % else
        %     array_de_correspondencias_filtrado = [array_de_correspondencias_filtrado( 1  : pos_a_eliminar - 1, : ) ; array_de_correspondencias_filtrado( pos_a_eliminar + 1  : end, :  ) ];
        % end
    end
end

%% Estimacion de la matriz fundamental 
% https://www.mathworks.com/help/vision/ref/estimatefundamentalmatrix.html

%% Extraccion de tracks
% https://www.mathworks.com/help/vision/ref/pointtrack.html