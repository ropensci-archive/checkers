# To test this:
# gp(path=".", checks = "comments", extra_preps = list(scripts = prep_scripts), extra_checks = list(comments = check_well_commented))

r_script_files <- function(path) {

  r_files <- list.files(path = path,
                        pattern = ".*\\.R$",
                        recursive = TRUE)
  r_scripts <- r_files[
    grep("^(R|tests)\\/", r_files, invert=TRUE)
    ]

  file.path(path, r_scripts)
}

#' @importFrom utils getParseData
frac_comments <- function(file) {
  pp <- parse(file=file, keep.source = TRUE)
  pd <- getParseData(pp)
  lines_no_blanks <- length(unique(c(pd$line1, pd$line2)))
  comment_lines <- sum(pd$token == "COMMENT")
  return(list(lines_no_blanks = lines_no_blanks,
              comment_lines = comment_lines,
              comment_frac = comment_lines/lines_no_blanks))
}

#' @export
#' @importFrom goodpractice make_prep
prep_scripts <- make_prep("scripts", function(path, quiet) {
  scripts <- r_script_files(path)
  com <- lapply(scripts, frac_comments)
  com_df <- data.frame(scripts = scripts,
                       comment_frac = purrr::map_dbl(com, "comment_frac"))
  xc <- purrr::transpose(com)
  comment_frac <- sum(unlist(xc[[2]]))/sum(unlist(xc[[1]]))
  return(list(scripts = scripts, com_df=com_df, comment_frac = comment_frac))
})

#' @export
#' @importFrom goodpractice make_check
check_well_commented <- make_check(

  description = "Scripts are well commented",
  tags = character(0),
  preps = c("scripts"),

  gp = function(state) {
    paste0(
      "Document your analyses with comments. ",
      trunc(state$scripts$comment_frac*100),
      "% of lines of your script lines are comments or have comments."
    )
  },
  check = function(state) {
    threshold <- options()$checkers[["comment_threshold"]]
    return(state$scripts$comment_frac > threshold)
  }
)

