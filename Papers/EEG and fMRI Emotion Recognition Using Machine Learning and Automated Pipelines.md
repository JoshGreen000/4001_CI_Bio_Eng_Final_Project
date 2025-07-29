## Source
- [[4001 Project Report.pdf]]
- [[4720 EEG Emotion Paper.pdf]]
- 4001 Presentation.pptx

**Abstract**  
Emotion recognition through neuroimaging has become a powerful method for understanding human affect. In this project, we combine electroencephalography (EEG) and functional magnetic resonance imaging (fMRI) with machine learning techniques to classify and uncover patterns in emotional states. The approach includes both supervised and unsupervised models applied to preprocessed neural signals. Additionally, we demonstrate the use of automation through scripted pipelines deployed on the FABRIC testbed to streamline the data processing of EEG and fMRI datasets. The results show that multimodal models are capable of identifying distinct emotional clusters, especially for high-valence emotions such as happiness and sadness.

---

**1. Introduction**  
Emotion recognition using neural data has gained significant interest due to its applications in mental health, adaptive interfaces, and cognitive state monitoring. EEG provides high temporal resolution while fMRI offers detailed spatial insights. Merging the two modalities has the potential to improve affective decoding. However, preprocessing and feature engineering for these modalities are complex and time-consuming. This work proposes a hybrid approach using EEG and fMRI data, incorporating supervised and unsupervised learning models, and automating preprocessing with Bash scripts run on the FABRIC testbed.

---

**2. Dataset Description**

**EEG Dataset**: The SEED-IV dataset was used, consisting of 62-channel EEG signals from 15 participants who watched 72 emotional film clips. Emotions include happiness, sadness, fear, and neutral. Data was downsampled to 200Hz, band-pass filtered (1-75Hz), and segmented into 4-second epochs. Power Spectral Density (PSD) and Differential Entropy (DE) features were extracted.

**fMRI Dataset**: Functional images were collected during face perception tasks involving happy, sad, angry, and neutral expressions. Data underwent standard preprocessing via FreeSurfer and FSL. Functional volumes were projected to fsaverage surfaces using `mri_vol2surf`, and features were extracted with `mri_segstats`.

---

**3. Pipeline Automation** A suite of Bash scripts was developed and published on GitHub ([scripts folder](https://github.com/JoshGreen0/4001_CI_Bio_Eng_Final_Project)). These scripts perform:

- `rec_vol2surf.sh`: Full recon-all and projection to surface.
    
- `vol2surf_run.sh`: Recovery projection script for failed subjects.
    
- `extract_stats2.sh`: Cortical thickness and volume extraction.
    
- `preprocess_bold.sh`: fMRI BOLD preprocessing using FSL tools. Scripts were run on the FABRIC testbed, leveraging compute nodes for batch processing and reliability.
    

---

**4. Methods**

**EEG Models**:

- Supervised: Multi-Layer Perceptron (MLP), Support Vector Machine (SVM) with PCA and GridSearchCV.
    
- Unsupervised: K-Means clustering and t-SNE visualization on extracted features.
    

**fMRI Models**:

- Feature importance via Random Forest.
    
- PCA for dimensionality reduction.
    
- Cluster analysis using graph metrics (centrality, density).
    

All models were evaluated using accuracy, precision, recall, F1-score, and visualized using confusion matrices and 2D embeddings.

---

**5. Results**

EEG:

- Best performance from MLP with PCA: 69% accuracy.
    
- Strongest classifications: Happy (F1: 0.70), Neutral (F1: 0.78).
    
- t-SNE clusters aligned well with true emotion labels.
    

fMRI:

- Happiness showed strongest localization and model performance.
    
- Emotions like sadness and fear had overlapping feature distributions.
    
- Graph metrics revealed modular structures during emotional engagement.
    

---

**6. Discussion** The hybrid EEG-fMRI approach improves emotion separability. High-valence emotions consistently produce more distinguishable neural patterns. Pipeline automation allowed scalable preprocessing across multiple subjects. While EEG allowed fast emotional tracking, fMRI added anatomical validity to observed patterns. Clustering results indicated that unsupervised methods can detect structure even without label supervision.

---

**7. Conclusion** We present a multimodal emotion recognition system that uses automation, dimensionality reduction, and hybrid machine learning methods to decode affective states from EEG and fMRI. The results validate the pipeline's effectiveness and suggest promise for applications in cognitive state monitoring and adaptive interfaces.

---

**References** [1] Wei-Long Zheng et al. EmotionMeter: A Multimodal Framework for Recognizing Human Emotions. _IEEE Transactions on Cybernetics_, 2019. [2] Gu et al. Shared affective experience across participants revealed by dynamic facial expressions and self-reported emotions in naturalistic fMRI. _bioRxiv_, 2021. [3] SEED-IV Dataset. https://bcmi.sjtu.edu.cn/~seed/index.html [4] SCinet INDIS CFP. https://scinet.supercomputing.org/community/indis/indis2025/