input_ae <- tibble::tribble(
  ~STUDYID,   ~USUBJID,   ~AESEQ, ~AESTDTC,
  "my_study", "subject1",      1, "2020-01-02",
  "my_study", "subject1",      2, "2020-08-31",
  "my_study", "subject1",      3, "2020-10-10",
  "my_study", "subject2",      1, "2019-05-15",
  "my_study", "subject2",      2, "2020-02-20",
  "my_study", "subject3",      1, "2020-03-02",
  "my_study", "subject4",      1, "2020-11-02"
)

input_ex <- tibble::tribble(
  ~STUDYID,   ~USUBJID,   ~EXSTDTC,     ~EXENDTC,    ~EXSEQ, ~EXDOSE, ~EXTRT,
  "my_study", "subject1", "2020-01-01", "2020-01-01",     1,      10, "treatment",
  "my_study", "subject1", "2020-08-29", "2020-08-29",     2,      10, "treatment",
  "my_study", "subject1", "2020-09-02", "2020-09-02",     3,      10, "treatment",
  "my_study", "subject1", "2020-10-20", "2020-10-20",     4,      10, "treatment",
  "my_study", "subject2", "2019-05-25", "2019-05-25",     1,       0, "placebo",
  "my_study", "subject2", "2020-01-20", "2020-01-20",     2,       0, "placebo",
  "my_study", "subject3", "2020-03-15", "2020-03-15",     1,      10, "treatment"
) %>%
  mutate(EXSTDTC = as.Date(EXSTDTC), EXENDTC = as.Date(EXENDTC))


test_that("derive_vars_last_dose Test 1: function works as expected", {
  expected_output <- mutate(
    input_ae,
    EXSTDTC = as.Date(c("2020-01-01", "2020-08-29", "2020-09-02", NA, "2020-01-20", NA, NA)),
    EXENDTC = as.Date(c("2020-01-01", "2020-08-29", "2020-09-02", NA, "2020-01-20", NA, NA)),
    EXSEQ = c(1, 2, 3, NA, 2, NA, NA),
    EXDOSE = c(10, 10, 10, NA, 0, NA, NA),
    EXTRT = c("treatment", "treatment", "treatment", NA, "placebo", NA, NA)
  )

  res <- derive_vars_last_dose(
    input_ae,
    input_ex,
    filter_ex = (EXDOSE > 0) | (EXDOSE == 0 & EXTRT == "placebo"),
    by_vars = vars(STUDYID, USUBJID),
    dose_date = EXENDTC,
    new_vars = vars(EXDOSE, EXTRT, EXSEQ, EXENDTC, EXSTDTC),
    analysis_date = AESTDTC,
    single_dose_condition = (EXSTDTC == EXENDTC),
    traceability_vars = NULL
  )

  expect_dfs_equal(expected_output, res, keys = c("STUDYID", "USUBJID", "AESEQ", "AESTDTC"))
})


test_that("derive_vars_last_dose Test 2: function checks validity of start and end dose inputs", {
  input_ex_wrong <- dplyr::bind_rows(
    input_ex,
    tibble::tribble(
      ~STUDYID, ~USUBJID, ~EXSTDTC, ~EXENDTC, ~EXSEQ, ~EXDOSE, ~EXTRT,
      "my_study", "subject4", as.Date("2020-11-05"), as.Date("2020-11-06"), 1, 10, "treatment"
    )
  )

  expect_error(
    derive_vars_last_dose(
      input_ae,
      input_ex_wrong,
      filter_ex = (EXDOSE > 0) | (EXDOSE == 0 & EXTRT == "placebo"),
      by_vars = vars(STUDYID, USUBJID),
      dose_date = EXENDTC,
      analysis_date = AESTDTC,
      single_dose_condition = (EXSTDTC == EXENDTC),
      traceability_vars = NULL
    ),
    regexp = "Specified `single_dose_condition` is not satisfied."
  )
})


test_that("derive_vars_last_dose Test 3: function returns traceability vars", {
  expected_output <- mutate(
    input_ae,
    EXSTDTC = as.Date(c("2020-01-01", "2020-08-29", "2020-09-02", NA, "2020-01-20", NA, NA)),
    EXENDTC = as.Date(c("2020-01-01", "2020-08-29", "2020-09-02", NA, "2020-01-20", NA, NA)),
    EXSEQ = c(1, 2, 3, NA, 2, NA, NA),
    EXDOSE = c(10, 10, 10, NA, 0, NA, NA),
    EXTRT = c("treatment", "treatment", "treatment", NA, "placebo", NA, NA),
    LDOSEDOM = c("EX", "EX", "EX", NA, "EX", NA, NA),
    LDOSESEQ = c(1, 2, 3, NA, 2, NA, NA),
    LDOSEVAR = c("EXSTDTC", "EXSTDTC", "EXSTDTC", NA, "EXSTDTC", NA, NA)
  )

  res <- derive_vars_last_dose(
    input_ae,
    input_ex,
    filter_ex = (EXDOSE > 0) | (EXDOSE == 0 & EXTRT == "placebo"),
    by_vars = vars(STUDYID, USUBJID),
    dose_date = EXENDTC,
    analysis_date = AESTDTC,
    single_dose_condition = (EXSTDTC == EXENDTC),
    traceability_vars = dplyr::vars(LDOSEDOM = "EX", LDOSESEQ = EXSEQ, LDOSEVAR = "EXSTDTC")
  )

  expect_dfs_equal(expected_output, res, keys = c("STUDYID", "USUBJID", "AESEQ", "AESTDTC"))
})


test_that("derive_vars_last_dose Test 4: function errors when multiple doses are on same date", {
  input_ex_dup <- dplyr::bind_rows(
    input_ex,
    tibble::tribble(
      ~STUDYID, ~USUBJID, ~EXSTDTC, ~EXENDTC, ~EXSEQ, ~EXDOSE, ~EXTRT,
      "my_study", "subject2", as.Date("2020-01-20"), as.Date("2020-01-20"), 3, 0, "placebo"
    )
  )

  expected_output <- mutate(
    input_ae,
    EXSTDTC = as.Date(c("2020-01-01", "2020-08-29", "2020-09-02", NA, "2020-01-20", NA, NA)),
    EXENDTC = as.Date(c("2020-01-01", "2020-08-29", "2020-09-02", NA, "2020-01-20", NA, NA)),
    EXSEQ = c(1, 2, 3, NA, 3, NA, NA),
    EXDOSE = c(10, 10, 10, NA, 0, NA, NA),
    EXTRT = c("treatment", "treatment", "treatment", NA, "placebo", NA, NA)
  )

  expect_error(
    derive_vars_last_dose(
      input_ae,
      input_ex_dup,
      filter_ex = (EXDOSE > 0) | (EXDOSE == 0 & EXTRT == "placebo"),
      by_vars = vars(STUDYID, USUBJID),
      dose_date = EXENDTC,
      analysis_date = AESTDTC,
      single_dose_condition = (EXSTDTC == EXENDTC),
      traceability_vars = NULL
    ),
    regexp = "Multiple doses exist for the same `dose_date`. Update `dose_id` to identify unique doses." # nolint
  )
})


test_that("derive_vars_last_dose Test 5: multiple doses on same date - dose_id supplied", {
  input_ex_dup <- dplyr::bind_rows(
    input_ex,
    tibble::tribble(
      ~STUDYID, ~USUBJID, ~EXSTDTC, ~EXENDTC, ~EXSEQ, ~EXDOSE, ~EXTRT,
      "my_study", "subject2", as.Date("2020-01-20"), as.Date("2020-01-20"), 3, 0, "placebo"
    )
  )

  expected_output <- mutate(
    input_ae,
    EXSTDTC = as.Date(c("2020-01-01", "2020-08-29", "2020-09-02", NA, "2020-01-20", NA, NA)),
    EXENDTC = as.Date(c("2020-01-01", "2020-08-29", "2020-09-02", NA, "2020-01-20", NA, NA)),
    EXSEQ = c(1, 2, 3, NA, 3, NA, NA),
    EXDOSE = c(10, 10, 10, NA, 0, NA, NA),
    EXTRT = c("treatment", "treatment", "treatment", NA, "placebo", NA, NA)
  )

  res <- derive_vars_last_dose(
    input_ae,
    input_ex_dup,
    filter_ex = (EXDOSE > 0) | (EXDOSE == 0 & EXTRT == "placebo"),
    by_vars = vars(STUDYID, USUBJID),
    dose_date = EXENDTC,
    dose_id = vars(EXSEQ),
    new_vars = vars(EXDOSE, EXTRT, EXSEQ, EXSTDTC, EXENDTC),
    analysis_date = AESTDTC,
    single_dose_condition = (EXSTDTC == EXENDTC),
    traceability_vars = NULL
  )

  expect_dfs_equal(expected_output, res, keys = c("STUDYID", "USUBJID", "AESEQ", "AESTDTC"))
})


test_that("derive_vars_last_dose Test 6: error is issued if same variable is found in both input datasets ", { # nolint
  input_ae <- tibble::tribble(
    ~STUDYID,   ~USUBJID,   ~AESEQ, ~EXSTDTC,
    "my_study", "subject1",      1, "2020-01-02",
    "my_study", "subject1",      2, "2020-08-31",
    "my_study", "subject1",      3, "2020-10-10",
    "my_study", "subject2",      1, "2019-05-15",
    "my_study", "subject2",      2, "2020-02-20",
    "my_study", "subject3",      1, "2020-03-02",
    "my_study", "subject4",      1, "2020-11-02"
  )

  input_ex <- tibble::tribble(
    ~STUDYID, ~USUBJID, ~EXSTDTC, ~EXENDTC, ~EXSEQ, ~EXDOSE, ~EXTRT,
    "my_study", "subject1", "2020-01-01", "2020-01-01", 1, 10, "treatment",
    "my_study", "subject1", "2020-08-29", "2020-08-29", 2, 10, "treatment",
    "my_study", "subject1", "2020-09-02", "2020-09-02", 3, 10, "treatment",
    "my_study", "subject1", "2020-10-20", "2020-10-20", 4, 10, "treatment",
    "my_study", "subject2", "2019-05-25", "2019-05-25", 1, 0, "placebo",
    "my_study", "subject2", "2020-01-20", "2020-01-20", 2, 0, "placebo",
    "my_study", "subject3", "2020-03-15", "2020-03-15", 1, 10, "treatment"
  ) %>%
    mutate(EXSTDTC = as.Date(EXSTDTC), EXENDTC = as.Date(EXENDTC))

  expect_error(
    derive_vars_last_dose(
      input_ae,
      input_ex,
      filter_ex = (EXDOSE > 0) | (EXDOSE == 0 & EXTRT == "placebo"),
      by_vars = vars(STUDYID, USUBJID),
      dose_date = EXENDTC,
      new_vars = vars(EXDOSE, EXTRT, EXSEQ, EXENDTC, EXSTDTC),
      analysis_date = EXSTDTC,
      single_dose_condition = (EXSTDTC == EXENDTC),
      traceability_vars = NULL
    ),
    "Variable(s) `EXSTDTC` found in both datasets, cannot perform join",
    fixed = TRUE
  )
})

test_that("derive_vars_last_dose Test 7: no error is raised when setting `dose_date` to a renamed variable", { # nolint
  adae <- tibble::tribble(
    ~USUBJID, ~AESTDTC, ~AENDTC, ~ASTDT, ~AENDT, ~AEDECOD,
    "P01", "2022-01-10", "2022-01-12", ymd("2022-01-10"), ymd("2022-01-12"), "Nausea",
    "P02", "2022-01-31", "2022-01-31", ymd("2022-01-31"), ymd("2022-01-31"), "Vomitting",
    "P02", "2022-02-02", "2022-02-04", ymd("2022-02-02"), ymd("2022-02-04"), "Vomitting"
  )

  adex <- tibble::tribble(
    ~USUBJID, ~EXTRT, ~EXDOSFRQ, ~EXSTDTC, ~EXENDTC, ~ASTDT, ~AENDT,
    "P01", "Drug A", "QD", "2022-01-09", "2022-01-12", ymd("2022-01-09"), ymd("2022-01-12"),
    "P02", "Drug A", "QD", "2022-02-01", "2022-02-04", ymd("2022-02-01"), ymd("2022-02-04")
  )

  (adex_single <- create_single_dose_dataset(adex))

  expect_error(
    derive_vars_last_dose(
      adae,
      adex_single,
      by_vars = vars(USUBJID),
      dose_date = EXSTDT,
      analysis_date = AESTDTC,
      new_vars = vars(EXSTDT = ASTDT)
    ),
    NA
  )
})
