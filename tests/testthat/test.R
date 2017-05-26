
context("checkers")

test_that("checkers works", {

  check_results <- gp_check(path=system.file("scripts", package="checkers"),
           checks = "comments",
           extra_preps = list(scripts = prep_scripts),
           extra_checks = list(comments = check_well_commented))
  expect_type(check_results, "list")

  version_control <- gp_check(path=system.file("scripts", package="checkers"),
           checks = "version_control",
           extra_preps = list(version_control = prep_version_control),
           extra_checks = list(version_control = check_version_control))
  expect_type(check_results, "list")

  lint_checks <- grep("lintr", goodpractice::all_checks())
  linters <- gp_check(path=system.file("scripts", package="checkers"),
                              checks = goodpractice::all_checks()[lint_checks],
                              extra_checks = list(),
                              extra_preps = list(lintr = prep_lint_dir))
  expect_type(check_results, "list")

  check_all_results <- gp_check(path=system.file("scripts", package="checkers"),
                              checks = all_checkers(),
                              extra_preps = all_prepers(),
                              extra_checks = all_extra_checkers())
  expect_type(check_all_results, "list")

})
