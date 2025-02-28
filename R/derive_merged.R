#' Add New Variable(s) to the Input Dataset Based on Variables from Another
#' Dataset
#'
#' Add new variable(s) to the input dataset based on variables from another
#' dataset. The observations to merge can be selected by a condition
#' (`filter_add` argument) and/or selecting the first or last observation for
#' each by group (`order` and `mode` argument).
#'
#' @param dataset Input dataset
#'
#'   The variables specified by the `by_vars` parameter are expected.
#'
#' @param dataset_add Additional dataset
#'
#'   The variables specified by the `by_vars`, the `new_vars`, and the `order`
#'   parameter are expected.
#'
#' @param order Sort order
#'
#'   If the parameter is set to a non-null value, for each by group the first or
#'   last observation from the additional dataset is selected with respect to the
#'   specified order.
#'
#'   *Default*: `NULL`
#'
#'   *Permitted Values*: list of variables or `desc(<variable>)` function calls
#'   created by `vars()`, e.g., `vars(ADT, desc(AVAL))` or `NULL`
#'
#' @param new_vars Variables to add
#'
#'   The specified variables from the additional dataset are added to the output
#'   dataset. Variables can be renamed by naming the element, i.e., `new_vars =
#'   vars(<new name> = <old name>)`.
#'
#'   For example `new_vars = vars(var1, var2)` adds variables `var1` and `var2`
#'   from `dataset_add` to the input dataset.
#'
#'   And `new_vars = vars(var1, new_var2 = old_var2)` takes `var1` and
#'   `old_var2` from `dataset_add` and adds them to the input dataset renaming
#'   `old_var2` to `new_var2`.
#'
#'   If the parameter is not specified or set to `NULL`, all variables from the
#'   additional dataset (`dataset_add`) are added.
#'
#'   *Default*: `NULL`
#'
#'   *Permitted Values*: list of variables created by `vars()`
#'
#' @param mode Selection mode
#'
#'   Determines if the first or last observation is selected. If the `order`
#'   parameter is specified, `mode` must be non-null.
#'
#'   If the `order` parameter is not specified, the `mode` parameter is ignored.
#'
#'   *Default*: `NULL`
#'
#'   *Permitted Values*: `"first"`, `"last"`, `NULL`
#'
#' @param by_vars Grouping variables
#'
#'   The input dataset and the selected observations from the additional dataset
#'   are merged by the specified by variables. The by variables must be a unique
#'   key of the selected observations.
#'
#'   *Permitted Values*: list of variables created by `vars()`
#'
#' @param filter_add Filter for additional dataset (`dataset_add`)
#'
#'   Only observations fulfilling the specified condition are taken into account
#'   for merging. If the parameter is not specified, all observations are
#'   considered.
#'
#'   *Default*: `NULL`
#'
#'   *Permitted Values*: a condition
#'
#' @param match_flag Match flag
#'
#'   If the parameter is specified (e.g., `match_flag = FLAG`), the specified
#'   variable (e.g., `FLAG`) is added to the input dataset. This variable will
#'   be `TRUE` for all selected records from `dataset_add` which are merged into
#'   the input dataset, and `NA` otherwise.
#'
#'   *Default*: `NULL`
#'
#'   *Permitted Values*: Variable name
#'
#' @param check_type Check uniqueness?
#'
#'   If `"warning"` or `"error"` is specified, the specified message is issued
#'   if the observations of the (restricted) additional dataset are not unique
#'   with respect to the by variables and the order.
#'
#'   *Default*: `"warning"`
#'
#'   *Permitted Values*: `"none"`, `"warning"`, `"error"`
#'
#' @param duplicate_msg Message of unique check
#'
#'   If the uniqueness check fails, the specified message is displayed.
#'
#'   *Default*:
#'
#'   ```{r echo=TRUE, eval=FALSE}
#'   paste("Dataset `dataset_add` contains duplicate records with respect to",
#'         enumerate(vars2chr(by_vars)))
#'   ```
#'
#' @return The output dataset contains all observations and variables of the
#'   input dataset and additionally the variables specified for `new_vars` from
#'   the additional dataset (`dataset_add`).
#'
#' @details
#'
#'   1. The records from the additional dataset (`dataset_add`) are restricted
#'   to those matching the `filter_add` condition.
#'
#'   1. If `order` is specified, for each by group the first or last observation
#'   (depending on `mode`) is selected.
#'
#'   1. The variables specified for `new_vars` are renamed (if requested) and
#'   merged to the input dataset using `left_join()`. I.e., the output dataset
#'   contains all observations from the input dataset. For observations without
#'   a matching observation in the additional dataset the new variables are set
#'   to `NA`. Observations in the additional dataset which have no matching
#'   observation in the input dataset are ignored.
#'
#' @author Stefan Bundfuss
#'
#' @keywords derivation adam
#'
#' @export
#'
#' @examples
#' library(admiral.test)
#' library(dplyr, warn.conflicts = FALSE)
#' data("admiral_vs")
#' data("admiral_dm")
#'
#' # merging all dm variables to vs
#' derive_vars_merged(
#'   admiral_vs,
#'   dataset_add = select(admiral_dm, -DOMAIN),
#'   by_vars = vars(STUDYID, USUBJID)
#' ) %>%
#'   select(STUDYID, USUBJID, VSTESTCD, VISIT, VSTPT, VSSTRESN, AGE, AGEU)
#'
#' # merge last weight to adsl
#' data("admiral_adsl")
#' derive_vars_merged(
#'   admiral_adsl,
#'   dataset_add = admiral_vs,
#'   by_vars = vars(STUDYID, USUBJID),
#'   order = vars(VSDTC),
#'   mode = "last",
#'   new_vars = vars(LASTWGT = VSSTRESN, LASTWGTU = VSSTRESU),
#'   filter_add = VSTESTCD == "WEIGHT",
#'   match_flag = vsdatafl
#' ) %>%
#'   select(STUDYID, USUBJID, AGE, AGEU, LASTWGT, LASTWGTU, vsdatafl)
derive_vars_merged <- function(dataset,
                               dataset_add,
                               by_vars,
                               order = NULL,
                               new_vars = NULL,
                               mode = NULL,
                               filter_add = NULL,
                               match_flag = NULL,
                               check_type = "warning",
                               duplicate_msg = NULL) {
  filter_add <- assert_filter_cond(enquo(filter_add), optional = TRUE)
  assert_vars(by_vars)
  assert_order_vars(order, optional = TRUE)
  assert_vars(new_vars, optional = TRUE)
  assert_data_frame(dataset, required_vars = by_vars)
  assert_data_frame(dataset_add, required_vars = quo_c(by_vars, extract_vars(order), new_vars))
  match_flag <- assert_symbol(enquo(match_flag), optional = TRUE)

  add_data <- filter_if(dataset_add, filter_add)
  if (!is.null(order)) {
    add_data <- filter_extreme(
      add_data,
      by_vars = by_vars,
      order = order,
      mode = mode,
      check_type = check_type
    )
  } else {
    if (is.null(duplicate_msg)) {
      duplicate_msg <- paste(
        "Dataset `dataset_add` contains duplicate records with respect to",
        enumerate(vars2chr(by_vars))
      )
    }
    signal_duplicate_records(
      add_data,
      by_vars = by_vars,
      msg = duplicate_msg
    )
  }
  if (!is.null(new_vars)) {
    add_data <- select(add_data, !!!by_vars, !!!new_vars)
  }
  if (!quo_is_null(match_flag)) {
    add_data <- mutate(
      add_data,
      !!match_flag := TRUE
    )
  }
  # check if there are any variables in both datasets which are not by vars
  # in this case an error is issued to avoid renaming of varibles by left_join()
  common_vars <-
    setdiff(intersect(names(dataset), names(add_data)), vars2chr(by_vars))
  if (length(common_vars) > 0L) {
    abort(if_else(
      length(common_vars) == 1L,
      paste0(
        "The variable ",
        common_vars[[1]],
        " is contained in both datasets.\n",
        "Please add it to `by_vars` or remove or rename it in one of the datasets."
      ),
      paste0(
        "The variables",
        enumerate(common_vars),
        "are contained in both datasets.\n",
        "Please add them to `by_vars` or remove or rename them in one of the datasets."
      )
    ))
  }
  left_join(dataset, add_data, by = vars2chr(by_vars))
}

#' Merge a (Imputed) Date Variable
#'
#' Merge a imputed date variable and date imputation  flag from a dataset to the
#' input dataset. The observations to merge can be selected by a condition
#' and/or selecting the first or last observation for each by group.
#'
#' @param dataset_add Additional dataset
#'
#'   The variables specified by the `by_vars`, the `dtc`, and the `order`
#'   parameter are expected.
#'
#' @param order Sort order
#'
#'   If the parameter is set to a non-null value, for each by group the first or
#'   last observation from the additional dataset is selected with respect to
#'   the specified order. The imputed date variable can be specified as well
#'   (see examples below).
#'
#'   Please note that `NA` is considered as the last value. I.e., if a order
#'   variable is `NA` and `mode = "last"`, this observation is chosen while for
#'   `mode = "first"` the observation is chosen only if there are no
#'   observations where the variable is not 'NA'.
#'
#'   *Default*: `NULL`
#'
#'   *Permitted Values*: list of variables or `desc(<variable>)` function calls
#'   created by `vars()`, e.g., `vars(ADT, desc(AVAL)` or `NULL`
#'
#' @inheritParams derive_vars_merged
#' @inheritParams derive_vars_dt
#'
#' @return The output dataset contains all observations and variables of the
#'   input dataset and additionally the variable `<new_vars_prefix>DT` and
#'   optionally the variable `<new_vars_prefix>DTF` derived from the additional
#'   dataset (`dataset_add`).
#'
#' @details
#'
#'   1. The additional dataset is restricted to the observations matching the
#'   `filter_add` condition.
#'
#'   1. The date variable and if requested, the date imputation flag is added to
#'   the additional dataset.
#'
#'   1. If `order` is specified, for each by group the first or last observation
#'   (depending on `mode`) is selected.
#'
#'   1. The date and flag variables are merged to the input dataset.
#'
#' @author Stefan Bundfuss
#'
#' @keywords derivation adam timing
#'
#' @export
#'
#' @examples
#' library(admiral.test)
#' library(dplyr, warn.conflicts = FALSE)
#' data("admiral_dm")
#' data("admiral_ex")
#'
#' # derive treatment start date (TRTSDT)
#' derive_vars_merged_dt(
#'   select(admiral_dm, STUDYID, USUBJID),
#'   dataset_add = admiral_ex,
#'   by_vars = vars(STUDYID, USUBJID),
#'   new_vars_prefix = "TRTS",
#'   dtc = EXSTDTC,
#'   date_imputation = "first",
#'   order = vars(TRTSDT),
#'   mode = "first"
#' )
#'
#' # derive treatment end date (TRTEDT) (without imputation)
#' derive_vars_merged_dt(
#'   select(admiral_dm, STUDYID, USUBJID),
#'   dataset_add = admiral_ex,
#'   by_vars = vars(STUDYID, USUBJID),
#'   new_vars_prefix = "TRTE",
#'   dtc = EXENDTC,
#'   order = vars(TRTEDT),
#'   mode = "last"
#' )
derive_vars_merged_dt <- function(dataset,
                                  dataset_add,
                                  by_vars,
                                  order = NULL,
                                  new_vars_prefix,
                                  filter_add = NULL,
                                  mode = NULL,
                                  dtc,
                                  date_imputation = NULL,
                                  flag_imputation = "auto",
                                  min_dates = NULL,
                                  max_dates = NULL,
                                  preserve = FALSE,
                                  check_type = "warning",
                                  duplicate_msg = NULL) {
  assert_vars(by_vars)
  dtc <- assert_symbol(enquo(dtc))
  filter_add <- assert_filter_cond(enquo(filter_add), optional = TRUE)
  assert_data_frame(dataset_add, required_vars = quo_c(by_vars, dtc))

  old_vars <- names(dataset_add)
  add_data <- filter_if(dataset_add, filter_add) %>%
    derive_vars_dt(
      new_vars_prefix = new_vars_prefix,
      dtc = !!dtc,
      date_imputation = date_imputation,
      flag_imputation = flag_imputation,
      min_dates = min_dates,
      max_dates = max_dates,
      preserve = preserve
    )
  new_vars <- quos(!!!syms(setdiff(names(add_data), old_vars)))
  derive_vars_merged(
    dataset,
    dataset_add = add_data,
    by_vars = by_vars,
    order = order,
    new_vars = new_vars,
    mode = mode,
    check_type = check_type,
    duplicate_msg = duplicate_msg
  )
}

#' Merge a (Imputed) Datetime Variable
#'
#' Merge a imputed datetime variable, date imputation  flag, and time imputation
#' flag from a dataset to the input dataset. The observations to merge can be
#' selected by a condition and/or selecting the first or last observation for
#' each by group.
#'
#' @param dataset_add Additional dataset
#'
#'   The variables specified by the `by_vars`, the `dtc`, and the `order`
#'   parameter are expected.
#'
#' @param order Sort order
#'
#'   If the parameter is set to a non-null value, for each by group the first or
#'   last observation from the additional dataset is selected with respect to
#'   the specified order. The imputed datetime variable can be specified as well
#'   (see examples below).
#'
#'   *Default*: `NULL`
#'
#'   *Permitted Values*: list of variables or `desc(<variable>)` function calls
#'   created by `vars()`, e.g., `vars(ADT, desc(AVAL)` or `NULL`
#'
#' @inheritParams derive_vars_merged
#' @inheritParams derive_vars_dtm
#'
#' @return The output dataset contains all observations and variables of the
#'   input dataset and additionally the variable `<new_vars_prefix>DT` and
#'   optionally the variables `<new_vars_prefix>DTF` and `<new_vars_prefix>TMF`
#'   derived from the additional dataset (`dataset_add`).
#'
#' @details
#'
#'   1. The additional dataset is restricted to the observations matching the
#'   `filter_add` condition.
#'
#'   1. The datetime variable and if requested, the date imputation flag and
#'   time imputation flag is added to the additional dataset.
#'
#'   1. If `order` is specified, for each by group the first or last observation
#'   (depending on `mode`) is selected.
#'
#'   1. The date and flag variables are merged to the input dataset.
#'
#' @author Stefan Bundfuss
#'
#' @keywords derivation adam timing
#'
#' @export
#'
#' @examples
#' library(admiral.test)
#' library(dplyr, warn.conflicts = FALSE)
#' data("admiral_dm")
#' data("admiral_ex")
#'
#' # derive treatment start datetime (TRTSDTM)
#' derive_vars_merged_dtm(
#'   select(admiral_dm, STUDYID, USUBJID),
#'   dataset_add = admiral_ex,
#'   by_vars = vars(STUDYID, USUBJID),
#'   new_vars_prefix = "TRTS",
#'   dtc = EXSTDTC,
#'   date_imputation = "first",
#'   time_imputation = "first",
#'   order = vars(TRTSDTM),
#'   mode = "first"
#' )
#'
#' # derive treatment end datetime (TRTEDTM) (without date imputation)
#' derive_vars_merged_dtm(
#'   select(admiral_dm, STUDYID, USUBJID),
#'   dataset_add = admiral_ex,
#'   by_vars = vars(STUDYID, USUBJID),
#'   new_vars_prefix = "TRTE",
#'   dtc = EXENDTC,
#'   time_imputation = "last",
#'   order = vars(TRTEDTM),
#'   mode = "last"
#' )
derive_vars_merged_dtm <- function(dataset,
                                   dataset_add,
                                   by_vars,
                                   order = NULL,
                                   new_vars_prefix,
                                   filter_add = NULL,
                                   mode = NULL,
                                   dtc,
                                   date_imputation = NULL,
                                   time_imputation = "00:00:00",
                                   flag_imputation = "auto",
                                   min_dates = NULL,
                                   max_dates = NULL,
                                   preserve = FALSE,
                                   check_type = "warning",
                                   duplicate_msg = NULL) {
  dtc <- assert_symbol(enquo(dtc))

  filter_add <- assert_filter_cond(enquo(filter_add), optional = TRUE)
  assert_data_frame(dataset_add, required_vars = quo_c(by_vars, dtc))

  old_vars <- names(dataset_add)
  add_data <- filter_if(dataset_add, filter = filter_add) %>%
    derive_vars_dtm(
      new_vars_prefix = new_vars_prefix,
      dtc = !!dtc,
      date_imputation = date_imputation,
      time_imputation = time_imputation,
      flag_imputation = flag_imputation,
      min_dates = min_dates,
      max_dates = max_dates,
      preserve = preserve
    )
  new_vars <- quos(!!!syms(setdiff(names(add_data), old_vars)))
  derive_vars_merged(
    dataset,
    dataset_add = add_data,
    by_vars = by_vars,
    order = order,
    new_vars = new_vars,
    mode = mode,
    check_type = check_type,
    duplicate_msg = duplicate_msg
  )
}

#' Merge a Categorization Variable
#'
#' Merge a categorization variable from a dataset to the input dataset. The
#' observations to merge can be selected by a condition and/or selecting the
#' first or last observation for each by group.
#'
#' @param dataset_add Additional dataset
#'
#'   The variables specified by the `by_vars`, the `source_var`, and the `order`
#'   parameter are expected.
#'
#' @param new_var New variable
#'
#'   The specified variable is added to the additional dataset and set to the
#'   categorized values, i.e., `cat_fun(<source variable>)`.
#'
#' @param source_var Source variable
#'
#' @param cat_fun Categorization function
#'
#'   A function must be specified for this parameter which expects the values of
#'   the source variable as input and returns the categorized values.
#'
#' @param missing_value Values used for missing information
#'
#'   The new variable is set to the specified value for all by groups without
#'   observations in the additional dataset.
#'
#'   *Default*: `NA_character_`
#'
#' @inheritParams derive_vars_merged
#'
#' @return The output dataset contains all observations and variables of the
#'   input dataset and additionally the variable specified for `new_var` derived
#'   from the additional dataset (`dataset_add`).
#'
#' @details
#'
#'   1. The additional dataset is restricted to the observations matching the
#'   `filter_add` condition.
#'
#'   1. The categorization variable is added to the additional dataset.
#'
#'   1. If `order` is specified, for each by group the first or last observation
#'   (depending on `mode`) is selected.
#'
#'   1. The categorization variable is merged to the input dataset.
#'
#' @author Stefan Bundfuss
#'
#' @keywords derivation adam
#'
#' @export
#'
#' @examples
#' library(admiral.test)
#' library(dplyr, warn.conflicts = FALSE)
#' data("admiral_dm")
#' data("admiral_vs")
#'
#' wgt_cat <- function(wgt) {
#'   case_when(
#'     wgt < 50 ~ "low",
#'     wgt > 90 ~ "high",
#'     TRUE ~ "normal"
#'   )
#' }
#'
#' derive_var_merged_cat(
#'   admiral_dm,
#'   dataset_add = admiral_vs,
#'   by_vars = vars(STUDYID, USUBJID),
#'   order = vars(VSDTC, VSSEQ),
#'   filter_add = VSTESTCD == "WEIGHT" & substr(VISIT, 1, 9) == "SCREENING",
#'   new_var = WGTBLCAT,
#'   source_var = VSSTRESN,
#'   cat_fun = wgt_cat,
#'   mode = "last"
#' ) %>%
#'   select(STUDYID, USUBJID, AGE, AGEU, WGTBLCAT)
#'
#' # defining a value for missing VS data
#' derive_var_merged_cat(
#'   admiral_dm,
#'   dataset_add = admiral_vs,
#'   by_vars = vars(STUDYID, USUBJID),
#'   order = vars(VSDTC, VSSEQ),
#'   filter_add = VSTESTCD == "WEIGHT" & substr(VISIT, 1, 9) == "SCREENING",
#'   new_var = WGTBLCAT,
#'   source_var = VSSTRESN,
#'   cat_fun = wgt_cat,
#'   mode = "last",
#'   missing_value = "MISSING"
#' ) %>%
#'   select(STUDYID, USUBJID, AGE, AGEU, WGTBLCAT)
derive_var_merged_cat <- function(dataset,
                                  dataset_add,
                                  by_vars,
                                  order = NULL,
                                  new_var,
                                  source_var,
                                  cat_fun,
                                  filter_add = NULL,
                                  mode = NULL,
                                  missing_value = NA_character_) {
  new_var <- assert_symbol(enquo(new_var))
  source_var <- assert_symbol(enquo(source_var))
  filter_add <- assert_filter_cond(enquo(filter_add), optional = TRUE)
  assert_data_frame(dataset_add, required_vars = quo_c(by_vars, source_var))

  add_data <- filter_if(dataset_add, filter_add) %>%
    mutate(!!new_var := cat_fun(!!source_var))
  derive_vars_merged(
    dataset,
    dataset_add = add_data,
    by_vars = by_vars,
    order = order,
    new_vars = vars(!!new_var),
    match_flag = temp_match_flag,
    mode = mode
  ) %>%
    mutate(!!new_var := if_else(temp_match_flag, !!new_var, missing_value, missing_value)) %>%
    select(-temp_match_flag)
}

#' Merge an Existence Flag
#'
#' Adds a flag variable to the input dataset which indicates if there exists at
#' least one observation in another dataset fulfilling a certain condition.
#'
#' @param dataset_add Additional dataset
#'
#'   The variables specified by the `by_vars` parameter are expected.
#'
#' @param by_vars Grouping variables
#'
#'   *Permitted Values*: list of variables
#'
#' @param new_var New variable
#'
#'   The specified variable is added to the input dataset.
#'
#' @param condition Condition
#'
#'   The condition is evaluated at the additional dataset (`dataset_add`). For
#'   all by groups where it evaluates as `TRUE` at least once the new variable
#'   is set to the true value (`true_value`). For all by groups where it
#'   evaluates as `FALSE` or `NA` for all observations the new variable is set
#'   to the false value (`false_value`). The new variable is set to the missing
#'   value (`missing_value`) for by groups not present in the additional
#'   dataset.
#'
#' @param true_value True value
#'
#'   *Default*: `"Y"`
#'
#' @param false_value False value
#'
#'   *Default*: `NA_character_`
#'
#' @param missing_value Values used for missing information
#'
#'   The new variable is set to the specified value for all by groups without
#'   observations in the additional dataset.
#'
#'   *Default*: `NA_character_`
#'
#'   *Permitted Value*: A character scalar
#'
#' @param filter_add Filter for additional data
#'
#'   Only observations fulfilling the specified condition are taken into account
#'   for flagging. If the parameter is not specified, all observations are
#'   considered.
#'
#'   *Permitted Values*: a condition
#'
#' @inheritParams derive_vars_merged
#'
#' @return The output dataset contains all observations and variables of the
#'   input dataset and additionally the variable specified for `new_var` derived
#'   from the additional dataset (`dataset_add`).
#'
#' @details
#'
#'   1. The additional dataset is restricted to the observations matching the
#'   `filter_add` condition.
#'
#'   1. The new variable is added to the input dataset and set to the true value
#'   (`true_value`) if for the by group at least one observation exists in the
#'   (restricted) additional dataset where the condition evaluates to `TRUE`. It
#'   is set to the false value (`false_value`) if for the by group at least one
#'   observation exists and for all observations the condition evaluates to
#'   `FALSE` or `NA`. Otherwise, it is set to the missing value
#'   (`missing_value`).
#'
#' @author Stefan Bundfuss
#'
#' @keywords derivation adam
#'
#' @export
#'
#' @examples
#'
#' library(admiral.test)
#' library(dplyr, warn.conflicts = FALSE)
#' data("admiral_dm")
#' data("admiral_ae")
#' derive_var_merged_exist_flag(
#'   admiral_dm,
#'   dataset_add = admiral_ae,
#'   by_vars = vars(STUDYID, USUBJID),
#'   new_var = AERELFL,
#'   condition = AEREL == "PROBABLE"
#' ) %>%
#'   select(STUDYID, USUBJID, AGE, AGEU, AERELFL)
#'
#' data("admiral_vs")
#' derive_var_merged_exist_flag(
#'   admiral_dm,
#'   dataset_add = admiral_vs,
#'   by_vars = vars(STUDYID, USUBJID),
#'   filter_add = VSTESTCD == "WEIGHT" & VSBLFL == "Y",
#'   new_var = WTBLHIFL,
#'   condition = VSSTRESN > 90,
#'   false_value = "N",
#'   missing_value = "M"
#' ) %>%
#'   select(STUDYID, USUBJID, AGE, AGEU, WTBLHIFL)
derive_var_merged_exist_flag <- function(dataset,
                                         dataset_add,
                                         by_vars,
                                         new_var,
                                         condition,
                                         true_value = "Y",
                                         false_value = NA_character_,
                                         missing_value = NA_character_,
                                         filter_add = NULL) {
  new_var <- assert_symbol(enquo(new_var))
  condition <- assert_filter_cond(enquo(condition))
  filter_add <-
    assert_filter_cond(enquo(filter_add), optional = TRUE)

  add_data <- filter_if(dataset_add, filter_add) %>%
    mutate(!!new_var := if_else(!!condition, 1, 0, 0))

  derive_vars_merged(
    dataset,
    dataset_add = add_data,
    by_vars = by_vars,
    new_vars = vars(!!new_var),
    order = vars(!!new_var),
    check_type = "none",
    mode = "last"
  ) %>%
    mutate(!!new_var := if_else(!!new_var == 1, true_value, false_value, missing_value))
}

#' Merge a Character Variable
#'
#' Merge a character variable from a dataset to the input dataset. The
#' observations to merge can be selected by a condition and/or selecting the
#' first or last observation for each by group.
#'
#' @param dataset_add Additional dataset
#'
#'   The variables specified by the `by_vars`, the `source_var`, and the `order`
#'   parameter are expected.
#'
#' @param new_var New variable
#'
#'   The specified variable is added to the additional dataset and set to the
#'   transformed value with respect to the `case` parameter.
#'
#' @param source_var Source variable
#'
#' @param case Change case
#'
#'   Changes the case of the values of the new variable.
#'
#'   *Default*: `NULL`
#'
#'   *Permitted Values*: `NULL`, `"lower"`, `"upper"`, `"title"`
#'
#' @param missing_value Values used for missing information
#'
#'   The new variable is set to the specified value for all by groups without
#'   observations in the additional dataset.
#'
#'   *Default*: `NA_character_`
#'
#'   *Permitted Value*: A character scalar
#'
#' @inheritParams derive_vars_merged
#'
#' @return The output dataset contains all observations and variables of the
#'   input dataset and additionally the variable specified for `new_var` derived
#'   from the additional dataset (`dataset_add`).
#'
#' @details
#'
#'   1. The additional dataset is restricted to the observations matching the
#'   `filter_add` condition.
#'
#'   1. The (transformed) character variable is added to the additional dataset.
#'
#'   1. If `order` is specified, for each by group the first or last observation
#'   (depending on `mode`) is selected.
#'
#'   1. The character variable is merged to the input dataset.
#'
#' @author Stefan Bundfuss
#'
#' @keywords derivation adam
#'
#' @export
#'
#' @examples
#' library(admiral.test)
#' library(dplyr, warn.conflicts = FALSE)
#' data("admiral_dm")
#' data("admiral_ds")
#'
#' derive_var_merged_character(
#'   admiral_dm,
#'   dataset_add = admiral_ds,
#'   by_vars = vars(STUDYID, USUBJID),
#'   new_var = DISPSTAT,
#'   filter_add = DSCAT == "DISPOSITION EVENT",
#'   source_var = DSDECOD,
#'   case = "title"
#' ) %>%
#'   select(STUDYID, USUBJID, AGE, AGEU, DISPSTAT)
derive_var_merged_character <- function(dataset,
                                        dataset_add,
                                        by_vars,
                                        order = NULL,
                                        new_var,
                                        source_var,
                                        case = NULL,
                                        filter_add = NULL,
                                        mode = NULL,
                                        missing_value = NA_character_) {
  new_var <- assert_symbol(enquo(new_var))
  source_var <- assert_symbol(enquo(source_var))
  case <-
    assert_character_scalar(
      case,
      values = c("lower", "upper", "title"),
      case_sensitive = FALSE,
      optional = TRUE
    )
  filter_add <- assert_filter_cond(enquo(filter_add), optional = TRUE)
  assert_data_frame(dataset_add, required_vars = quo_c(by_vars, source_var))
  assert_character_scalar(missing_value)

  if (is.null(case)) {
    trans <- expr(!!source_var)
  } else if (case == "lower") {
    trans <- expr(str_to_lower(!!source_var))
  } else if (case == "upper") {
    trans <- expr(str_to_upper(!!source_var))
  } else if (case == "title") {
    trans <- expr(str_to_title(!!source_var))
  }
  add_data <- filter_if(dataset_add, filter_add) %>%
    mutate(!!new_var := !!trans)
  derive_vars_merged(
    dataset,
    dataset_add = add_data,
    by_vars = by_vars,
    order = order,
    new_vars = vars(!!new_var),
    match_flag = temp_match_flag,
    mode = mode
  ) %>%
    mutate(!!new_var := if_else(temp_match_flag, !!new_var, missing_value, missing_value)) %>%
    select(-temp_match_flag)
}
