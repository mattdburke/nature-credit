df1 <- read.csv("data/FRED_OAS_data_raw.csv")

rc <- read.csv("data/rating_conversion_table.csv", header = FALSE)

colnames(df1) <- c(
    "DATE", 
    "BBB",
    "C",
    "AAA",
    "AA",
    "BB")

df1 <- as.data.frame(df1 %>% gather(
    rating, oas, BBB:BB
    ) %>% dplyr::group_by(
        rating
    ) %>% dplyr::mutate(
        oas = as.numeric(oas),
        oas = median(oas, na.rm = TRUE)
    ) %>% dplyr::select(
        rating,
        oas
    ) %>% distinct(rating, oas, .keep_all = TRUE))

get_number_rating <- function(letter_rating){
    nr <- rc[rc$V1==letter_rating, ]$V2
    return (nr)
}

nr <- c()
for (i in df1$rating){
    nr <- append(nr, get_number_rating(i))
}

df1$nr <- nr

write.csv(dplyr::select(df1, rating = nr, oas), "derived_data/oas_spread.csv", row.names = FALSE)
