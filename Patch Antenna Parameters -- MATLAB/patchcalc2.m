function [Zo_out, Fr_out] = patchcalc2(h_de,Er_de, W_de, L_de) 

%PATCHCALC2: Returns the center frequency and intrinsic impedance of the
%antenna calculated by the parameters h, Er, W and L; 

  Er           = Er_de;       %relative permitivity
  h            = h_de;       %height of dielectric  (m)
  W            = W_de;       %width of patch        (m) 
  L            = L_de;       %length of patch       (m) 
  

    Eeff = (Er + 1)/2 + (Er-1)/2*(1 + (12*h)/W)^(-1/2);

    Zo_out = (120*pi*h)/(W*sqrt(Eeff));

    dL = (0.412*h)*((Eeff+.3)/(Eeff-0.258))*((W/h+0.264)/(W/h+0.8));

    Fr_out=(3E8)/(2*sqrt(Eeff)*(L+(2*dL)));