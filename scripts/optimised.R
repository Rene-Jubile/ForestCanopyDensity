
setwd("/home/rene/Documents/GitHub/forest_canopy_density")

all_landsat_bands <- c(
  "data/landsat/LC80340322016205-SC20170127160728/crop/LC80340322016205LGN00_sr_band1_crop.tif",
  "data/landsat/LC80340322016205-SC20170127160728/crop/LC80340322016205LGN00_sr_band2_crop.tif",
  "data/landsat/LC80340322016205-SC20170127160728/crop/LC80340322016205LGN00_sr_band3_crop.tif",
  "data/landsat/LC80340322016205-SC20170127160728/crop/LC80340322016205LGN00_sr_band4_crop.tif",
  "data/landsat/LC80340322016205-SC20170127160728/crop/LC80340322016205LGN00_sr_band5_crop.tif",
  "data/landsat/LC80340322016205-SC20170127160728/crop/LC80340322016205LGN00_sr_band6_crop.tif",
  "data/landsat/LC80340322016205-SC20170127160728/crop/LC80340322016205LGN00_sr_band7_crop.tif"
)


# Créer le brick directement à partir de cette liste
landsat_csf_br <- brick(all_landsat_bands)


# Normaliser les noms des bandes
names(landsat_csf_br) <- sub("LC80340322016189LGN00_sr_", "", names(landsat_csf_br))

# Fonction pour calculer les indices de manière générale
calc_index <- function(brick, formula) {
  calc(brick, fun = function(x) eval(parse(text = formula)))
}

# Calcul des indices avec la fonction générique 'calc_index'
ndvi <- calc_index(landsat_csf_br, "(x[5]-x[4])/(x[5]+x[4])")
avi <- calc_index(landsat_csf_br, "(x[5] * (1 - x[4]) * (x[5] - x[4]))^(1/3)")
bsi <- calc_index(landsat_csf_br, "((x[6] + x[4]) - (x[5] + x[2]))/((x[6] + x[4]) + (x[5] + x[2]))")
si <- calc_index(landsat_csf_br, "sqrt((256 - x[3]) * (256 - x[4]))")

# Normaliser l'indice d'ombre (SI) entre 0 et 100
ssi <- stretch(si, to = c(0, 100))

# MNDVI et sa version rescalée
mndvi <- calc_index(landsat_csf_br, "(ndvi*x[5]-x[4])/(ndvi*x[5]+x[4])")
r_mndvi <- stretch(mndvi, to = c(0, 100))

# Calcul du Forest Canopy Density
fcd <- sqrt(r_mndvi * ssi + 1) - 1

# Visualisation des indices (Optionnel)
par(mfrow = c(2, 3))
plot(ndvi, main = "NDVI")
plot(avi, main = "AVI")
plot(bsi, main = "BSI")
plot(ssi, main = "SSI")
plot(r_mndvi, main = "Rescaled MNDVI")
plot(fcd, main = "Forest Canopy Density")