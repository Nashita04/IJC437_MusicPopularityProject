# Making sure my working directory is correct
getwd()

# Loading up the correct packages
library(tidyverse)
library(rpart)
library(rpart.plot)

# Folder paths
meta_path <- "musicoset_metadata"
pop_path  <- "musicoset_popularity"
feat_path <- "musicoset_songfeatures"

# Choosing the relevant sections of data
#METADATA
songs  <- read_tsv(file.path(meta_path, "songs.csv"))
tracks <- read_tsv(file.path(meta_path, "tracks.csv"))

# POPULARITY 
song_pop   <- read_tsv(file.path(pop_path, "song_pop.csv"))

# FEATURES
acoustic_features <- read_tsv(file.path(feat_path, "acoustic_features.csv"))
lyrics            <- read_tsv(file.path(feat_path, "lyrics.csv"))

# Loading up the column names to see what they can be joined by
names(songs)
names(tracks)
names(song_pop)
names(acoustic_features)
names(lyrics)

# Joining songs with song-level popularity
# 1) Collapse song_pop to one row per song_id; song_pop may have multiple rows per song,
#    therefore, this removes duplicates
song_pop_summary <- song_pop %>%
  group_by(song_id) %>%
  summarise(
    max_year_end_score = max(year_end_score, na.rm = TRUE),
    ever_pop           = max(is_pop, na.rm = TRUE),   # 1 if it was popular in any year
    first_year         = min(year, na.rm = TRUE)
  )

# 2) Adding previous columns to the songs data set by matching the song_id
songs_pop <- songs %>%
  left_join(song_pop_summary, by = "song_id")


# 3) Joining tracks to songs_pop using song_id
songs_tracks <- songs_pop %>%
  left_join(tracks, by = "song_id")

# 4) Adding acoustic features and lyrics to each song using 'track_id'
songs_feats <- songs_tracks %>%
  left_join(acoustic_features, by = "song_id")

songs_full <- songs_feats %>%
  left_join(lyrics, by = "song_id") 

# Checking the final structure
glimpse(songs_full)
view(songs_full)

nrow(songs_full)
length(unique(songs_full$song_id))

# Creating a list of the Spotify features I'll use as predictors
features <- c(
  "danceability", "energy", "loudness", "valence",
  "tempo", "acousticness", "instrumentalness",
  "liveness", "speechiness"
)

# Creating one clean modelling data set
music_df <- songs_full %>%
  select(
    song_id,
    song_name,             
    artists,       
    release_date,       
    popularity,         
    all_of(features)
  ) %>%
  drop_na()   

glimpse(music_df)
summary(music_df$popularity)


# Calculating the median popularity score (RQ1)
median_pop <- median(music_df$popularity, na.rm = TRUE)

music_df <- music_df %>%
  mutate(
    HighPop = if_else(popularity >= median_pop, 1, 0),
    HighPop = as.factor(HighPop)
  )

table(music_df$HighPop)

# Bar chart: high vs low popularity, checking the class balance (RQ1)
ggplot(music_df, aes(x = HighPop)) +
  geom_bar(fill = "skyblue") +
  labs(
    title = "Distribution of High vs Low Popularity Songs",
    x = "High Popularity (1 = yes, 0 = no)",
    y = "Count"
  )

# Boxplot; danceability by popularity group (how danceability differs
# between low- and high-popularity songs)(RQ1)
ggplot(music_df, aes(x = HighPop, y = danceability)) +
  geom_boxplot(fill = "lightgreen") +
  labs(
    title = "Danceability by Popularity Group",
    x = "High Popularity (1 = yes, 0 = no)",
    y = "Danceability"
  )

# Histogram: energy (Distribution of energy feature (high/low energy)(RQ1/2)
ggplot(music_df, aes(x = energy)) +
  geom_histogram(bins = 20, fill = "purple") +
  labs(
    title = "Distribution of Energy",
    x = "Energy",
    y = "Frequency"
  )

# Logistic regression (RQ1)
logit_mod <- glm(
  HighPop ~ danceability + energy + loudness + speechiness +
    acousticness + instrumentalness + liveness + valence + tempo,
  data   = music_df,
  family = binomial
)

summary(logit_mod)

# Logistic regression predictions & evaluation
music_df$logit_prob <- predict(logit_mod, type = "response")
music_df$logit_pred <- ifelse(music_df$logit_prob >= 0.5, 1, 0)
music_df$logit_pred <- as.factor(music_df$logit_pred)

cm_logit <- table(
  Actual   = music_df$HighPop,
  Predicted = music_df$logit_pred
)
cm_logit

logit_accuracy <- sum(diag(cm_logit)) / sum(cm_logit)
logit_accuracy

# Decision tree classifier to predict HighPop using the same feautres (RQ1)
tree_mod <- rpart(
  HighPop ~ danceability + energy + loudness + speechiness +
    acousticness + instrumentalness + liveness + valence + tempo,
  data   = music_df,
  method = "class"
)

# Drawing the tree diagram (RQ1)
rpart.plot(tree_mod, type = 2, extra = 104,
           main = "Decision Tree Predicting High Popularity")

#Is the tree better/worse than logistic (RQ1)
music_df$tree_pred <- predict(tree_mod, type = "class")

cm_tree <- table(
  Actual   = music_df$HighPop,
  Predicted = music_df$tree_pred
)
cm_tree

tree_accuracy <- sum(diag(cm_tree)) / sum(cm_tree)
tree_accuracy

# Multiple linear regression model for RQ2
lin_mod <- lm(
  popularity ~ danceability + energy + loudness + valence + tempo,
  data = music_df
)

summary(lin_mod)

#Predicted vs actual popularity plot (RQ2)
music_df$lin_pred <- predict(lin_mod)

ggplot(music_df, aes(x = lin_pred, y = popularity)) +
  geom_point(alpha = 0.4) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  labs(
    title = "Predicted vs Actual Popularity",
    x = "Predicted Popularity",
    y = "Actual Popularity"
  )

summary(logit_mod)
nagelkerke(logit_mod)










