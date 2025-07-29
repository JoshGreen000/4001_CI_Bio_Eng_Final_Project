## Source
- [[brain_efficiency_comparison_report.pdf]]

**Abstract**  
This study investigates structural brain differences between chess masters and control participants using features derived from structural magnetic resonance imaging (sMRI). We analyzed cortical thickness and volumetric data extracted with FreeSurfer to assess brain efficiency across two matched groups. Key brain regions involved in executive control and spatial reasoning, including the precuneus and superior frontal gyrus, were found to exhibit statistically significant differences in cortical thickness. Our results support the hypothesis that expert-level cognitive training correlates with increased structural specialization, with implications for understanding neuroplasticity and performance.

---

**1. Introduction**  
Brain efficiency in elite cognitive performers, such as chess masters, provides an opportunity to study the neural correlates of expertise. Previous research has linked structural and functional differences in frontal and parietal regions to strategic reasoning and spatial cognition. In this study, we apply quantitative analysis to structural MRI features extracted using FreeSurfer from 58 participants (29 masters, 29 controls) to evaluate differences in brain morphology and derive insights into neural efficiency.

---

**2. Dataset and Preprocessing**

Participants were grouped into "Masters" and "Average Chess Players" based on chess expertise and identification tags. T1-weighted MRI scans were processed using FreeSurfer’s `recon-all` to generate cortical surface and subcortical volume statistics. The following tools were employed:

- `aparcstats2table` and `asegstats2table` for extracting cortical thickness, volume, surface area, and curvature.
    
- Custom scripts aggregated these into a master CSV for statistical analysis.
    

Metrics included:

- Cortical thickness in superior frontal and precuneus regions.
    
- Volumetric measures such as total gray matter and regional frontal cortex volumes.
    
- BrainSeg-to-eTIV ratio for normalized efficiency estimation.
    

---

**3. Methods**

**Statistical Analysis**:

- Mean differences were computed between groups for each feature.
    
- Welch's t-test evaluated significance.
    
- p-values < 0.05 were considered statistically significant.
    

**Feature Selection**: Top features were selected based on statistical significance and relevance to executive function. These included:

- `lh_thickness_lh_superiorfrontal_thickness`
    
- `lh_thickness_lh_precuneus_thickness`
    
- `rh_thickness_rh_superiorparietal_thickness`
    
- `aseg_volume_BrainSegVol-to-eTIV`
    

**Visualization**:

- Boxplots for top features.
    
- PCA for dimensionality reduction and visualization of subject separation.
    
- KMeans clustering for grouping based on structural patterns.
    

---

**4. Results**

**Significant Features**:

- Chess masters showed increased cortical thickness in superior parietal and precuneus regions (p < 0.001).
    
- The BrainSeg-to-eTIV ratio was higher among masters, suggesting more efficient volume utilization (p = 0.0005).
    

**Group Comparison**:

- PCA revealed partial separation between the two groups.
    
- KMeans clustering showed overlap but with distinguishable centroids, validating that feature patterns loosely align with expertise level.
    

|Feature|Mean Diff|p-value|
|---|---|---|
|rh_superiorparietal_thickness|+0.0959|0.00005|
|lh_supramarginal_thickness|+0.1106|0.00020|
|lh_precuneus_thickness|+0.0984|0.00054|
|BrainSegVol-to-eTIV|+0.0036|0.00054|
|lh_paracentral_thickness|+0.1542|0.00066|

---

**5. Discussion**

The increased thickness in parietal and frontal regions among chess masters aligns with literature associating these areas with abstract reasoning, decision-making, and mental imagery. The normalized brain volume efficiency metric (BrainSegVol-to-eTIV) further supports the notion that experts may utilize brain resources more effectively. While volumetric increases were not uniformly significant, consistent patterns emerged in cortical measurements.

---

**6. Conclusion**

This study reinforces the idea that cognitive training leads to measurable structural differences in the brain. Cortical thickness, especially in regions linked to executive functions, offers a viable marker for brain efficiency. Our results provide a foundation for future investigations into dynamic modeling of cognitive expertise and neuroplasticity.

---

**References** [1] Gu et al. Shared affective experience across participants revealed by dynamic facial expressions and self-reported emotions in naturalistic fMRI. _bioRxiv_, 2021.  
[2] FreeSurfer. https://surfer.nmr.mgh.harvard.edu/  
[3] Brain Efficiency Comparison Report, 2025.  
[4] SCinet INDIS CFP. https://scinet.supercomputing.org/community/indis/indis2025/