context("Convert VW format to data frame")

# Good formats
vw <- c(
  "1 1.0 |MetricFeatures:3.0 height:1.5 length:2.0 |Has stripe |Other Legs:4.0 IsAnimal",
  "1 1.0 zebra|MetricFeatures:3.0 height:1.5 length:2.0 |Has stripe |Other Legs:4.0 IsAnimal",
  "1 1.0 zebra|MetricFeatures:1.5 length:2.0 |Has a white stripe |Other Legs:4.0 IsAlive",
  "1 2 'tag|a:2 b:3",
  "0 |f:.23 sqft:.25 age:.05 2006"
)

# List of expected R objects
expected <- {
  
  df1 <- data.frame(
    label = "1",
    importance = 1.0,
    tag = as.character(NA),
    MetricFeatures_height = 3.0 * 1.5, 
    MetricFeatures_length = 3.0 * 2.0,
    Has_stripe = 1.0,
    Other_Legs = 4.0,
    Other_IsAnimal = 1.0,
    stringsAsFactors = F
  )
  
  df2 <- {
    df2 <- df1
    df2$tag = "zebra"
    df2
  }
  
  df3 <- data.frame(
    label = "1",
    importance = 1.0,
    tag = "zebra",
    MetricFeatures_length = 1.5 * 2.0,
    Has_a = 1.0,
    Has_white = 1.0,
    Has_stripe = 1.0,
    Other_Legs = 4.0,
    Other_IsAlive = 1.0,
    stringsAsFactors = F
  )
  
  df4 <- data.frame(
    label = "1",
    importance = 2.0,
    tag = "'tag",
    a_b = 2.0 * 3.0,
    stringsAsFactors = F
  )
  
  df5 <- data.frame(
    label = "0",
    importance = 1.0,
    tag = as.character(NA),
    f_sqft = 0.23 * 0.25,
    f_age = 0.23 * 0.05,
    f_2006 = 0.23,
    stringsAsFactors = F
  )
  
  list(df1, df2, df3, df4, df5)
}

# Bad formats
vw.bad <- c(
  "1 2 'tag |a:2 b:3",
  "1 2 tag |a:2 b:3",
  "1 2 'second_house |f:.18 sqft:.15 age:.35 1976",
  "0 1 0.5 'third_house |f:.53 sqft:.32 age:.87 1924"
)

# Tests

test_that("Parses vowpal wabbit string to sparse R format correctly", {
  for (i in length(expected)) expect_equal(fromVw(vw[i], dense = F), expected[i])
})

test_that("Parses vowpal wabbit string to dense R format correctly", {
  for (i in length(expected)) expect_equal(fromVw(vw[i], dense = T), expected[[i]])
})

test_that("Parses vowpal wabbit vector to sparse R format correctly",
  expect_equal(fromVw(vw, dense = F), expected)
)

test_that("Parses vowpal wabbit data to dense R format correctly",
  expect_equal(fromVw(vw, dense = T), as.data.frame(data.table::rbindlist(expected, fill = T)))
)

test_that("Cannot parse bad data", {
  for (x in vw.bad) expect_error(fromVw(x), "Could not parse")
})
