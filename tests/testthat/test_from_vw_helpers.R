context("Convert VW format to R list")

test_that("vwNamespaceToList cannot parse bad data", {
  expect_error(vwNamespaceToList('Has'), "Could not parse")
  expect_error(vwNamespaceToList(' Has Stripe'), "Could not parse")
})

test_that("vwNamespaceToList parses good data", {
  expect_equal(vwNamespaceToList("Has stripe "), list(Has_stripe = 1.0))
  expect_equal(vwNamespaceToList("Other Legs:4.0 IsAnimal"), list(Other_Legs = 4.0, Other_IsAnimal = 1.0))
  expect_equal(
    vwNamespaceToList("MetricFeatures:3.0 height:1.5 length:2.0 "),
    list(MetricFeatures_height = 3.0 * 1.5, MetricFeatures_length = 3.0 * 2.0)
  )
})

test_that("vwToList cannot parse bad data", {
  expect_error(vwNamespacesToList('a b:2.0 |Has '), "Could not parse")
  expect_error(vwNamespacesToList('a b:2.0 | Has Stripe'), "Could not parse")
})

test_that("vwToList parses good data", {
  expect_equal(vwNamespacesToList("Has stripe"), list(list(Has_stripe = 1.0)))
  expect_equal(
    vwNamespacesToList("Has stripe |Other Legs:4.0 IsAnimal"),
    list(list(Has_stripe = 1.0), list(Other_Legs = 4.0, Other_IsAnimal = 1.0))
  )
})
