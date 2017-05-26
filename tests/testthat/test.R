
context("checkers")

test_that("checkers works", {

  check_results <- gp_check(path=system.file("scripts", package="checkers"),
           checks = "comments",
           extra_preps = list(scripts = prep_scripts),
           extra_checks = list(comments = check_well_commented))
  expect_type(check_results, "list")

})
