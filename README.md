## IJC437_MusicPopularityProject
This project is an analysis of Spotify audio features and song popularity using the MusicOSet dataset for MSc Data Science (IJC437 Introduction to Data Science).

This project investigates whether Spotify audio features can be used to predict and explain song popularity.
Using the MusicOSet dataset, the analysis applies exploratory data analysis, classification, and regression techniques
to examine the relationship between musical characteristics and streaming popularity.
The project emphasises interpretability, reproducibility, and critical evaluation of model limitations.

## Research Questions
Which Spotify audio features predict whether a song achieves high popularity?
To what extent do Spotify audio features explain variation in continuous popularity scores?
  
## Key Findings
- Danceability, loudness, and speechiness are strong positive predictors of high song popularity.
- Acousticness, instrumentalness, and valence show consistent negative associations with popularity.
- Classification models achieved moderate accuracy (~64%), indicating meaningful but limited predictive power.
- Linear regression explained approximately 15% of the variance in popularity, highlighting the influence of non-musical factors such as platform algorithms and cultural trends.
  
## R Code
The complete R script used for data preprocessing, exploratory analysis, feature engineering, and modelling is provided in this repository.
The code is fully commented and structured to allow reproducibility of all results and visualisations presented in the report.

## How to Run the Code

1. Download the MusicOSet datasets from:
   https://marianaossilva.github.io/DSW2019/index.html#tables

2. Extract the zip files into a single project directory with the following structure:
   - musicoset_metadata/
   - musicoset_popularity/
   - musicoset_songfeatures/

3. Clone or download this GitHub repository and place it in the same directory as the dataset folders.

4. Open the main R script (MusicOSet.R) in RStudio.

5. Install the required R packages listed at the top of the script.

6. Run the script from start to finish to reproduce the full analysis.
