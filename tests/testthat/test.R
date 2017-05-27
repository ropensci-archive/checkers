
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

  lintr_stuff <- gp_check(system.file("scripts", package="checkers"),
           checks = "lintr_assignment_linter",
           extra_checks = list(), extra_preps = list(lintr=prep_lint_dir))
  expect_type(lintr_stuff, "list")


  lint_checks <- grep("lintr", goodpractice::all_checks())
  linters <- gp_check(path=system.file("scripts", package="checkers"),
                      checks = goodpractice::all_checks()[lint_checks],
                      extra_checks = list(),
                      extra_preps = list(lintr = prep_lint_dir))
  expect_type(check_results, "list")

  check_xml <- make_pref_pkg_check("XML", "xml2")
  pref_package <- gp_check(path=system.file("scripts", package="checkers"),
           checks="XML",
           extra_preps=list(packages=prep_packages),
           extra_checks = list(XML = check_xml))
  expect_type(pref_package, "list")

  check_gam <- make_fun_pair_check("gam", "gam.check")
  check_funs <- gp_check(path=system.file("scripts", package="checkers"),
           checks = "check_gam",
    extra_preps = list(functions = prep_functions),
    extra_checks = list(check_gam = check_gam))
  expect_type(check_funs, "list")
})


test_that("check_all", {

  check_all_results <- gp_check(path=system.file("scripts", package="checkers"),
                                checks = all_checkers(),
                                extra_preps = all_prepers(),
                                extra_checks = all_extra_checkers())
  expect_type(check_all_results, "list")
})
