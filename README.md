# Female_ornamentation_predicts_dominance
Code for statistical analysis and data visualization for the manuscript "Dominant females have brighter ornamentation in a sexually dimorphic lekking species" published in Ethology (2021).

**Authors**: Alexis D. Earl, Richard K. Simpson, & Jessica L. Yorzinski

**Abstract**: 
Males often exhibit elaborate ornamentation that contributes to their fitness. Similarly, females can also exhibit elaborate ornamentation, but we have a relatively limited understanding of its function. Recent studies have demonstrated that female ornamentation can function in both intrasexual competition and male mate choice, but few studies have been conducted on lekking species. We therefore investigated the possibility that female ornamentation provides information about the dominance status of the bearer, which could mediate intrasexual competition. We examined this possibility using Indian peafowl (Pavo cristatus), a sexually dimorphic lekking species in which females exhibit elaborate ornamentation in the form of iridescent green neck plumage. We tested whether female ornamentation predicts dominance status using an information theoretic model averaging approach. We found that females with brighter ornamentation are more socially dominant than females with darker ornamentation. These results suggest that female ornamentation in this species provides social information about the dominance status of the bearer. This study provides insight into the evolution of conspicuous female traits by suggesting a potential role for female ornamentation in intrasexual competition in a lekking species.

Any questions or concerns can be addressed to the corresponding author Alexis D. Earl at ade2102@columbia.edu

**Data files**:

- ```feather_data_ALL_combined.csv``` contains information on each individual peahen (ID, DS_Value: david's score dominance status value prior to De Vries correction, ordered rank, peahen body mass (g), and color space variables for feathers from the side, back, and front of the ornamental neck region - separately and pooled - for "lum" i.e., brightness, hue in the UV part of the spectrum, hue in the visible RGB part of the spectrum, and chroma).

* ```NormDS.csv``` contains the "DS_Value" (dominance score) for each peahen after De Vries correction to calculate normalized David's scores and account for variation in number of interactions between dyads.

See **METHODS** for additional details [(link to manuscript)](https://doi.org/10.1111/eth.13244).
