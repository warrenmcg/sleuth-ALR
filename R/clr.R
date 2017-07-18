
calculate_clr <- function(mat, base = "e") {
  base <- as.character(base)
  base <- match.arg(base, c("e", "2"))

  if (any(mat == 0)) {
    stop("The CLR transformation cannot be done because there is ",
         "at least one zero value in the supplied matrix.")
  }

  clr_table <- apply(mat, 2, function(x) {
    x / geomean(x)
  })
  if (base == "e") clr_table <- log(clr_table) else
    clr_table <- log(clr_table, base)
  clr_table
}

#' Centered Logratio Transformation
#'
#' This function applies the centered
#' logratio transformation on a matrix of
#' expression values.
#' 
#' @param mat N x M matrix of estimated abundances
#' @param base what should the base of the logarithm be?
#'   currently only supports base "e" and base 2.
#'
#' @return N x M matrix of CLR-transformed values with 
#' essential zero rows removed.
#'
#' @details this converts an N x M matrix of
#' N target IDs and M samples (N >> M). 
#' If M > N, then the matrix is flipped to do 
#' the calculations, but returned with the same           
#' as the input. The calculation is as follows:
#' x_1, x_2, ..., x_D => log(x_1 / g(X)), ..., log(x_D / g(X))
#'
#' @export
clr_transformation <- function(mat, base = "e") {
  # this function expects samples to be columns
  # and target IDs to be rows;
  # some of sleuth's internals call the
  # transformation function with the transpose
  # of the expected matrix
  flip <- FALSE
  if (ncol(mat) > nrow(mat)) {
    mat <- t(mat)
    flip <- TRUE
  }
  mat <- remove_essential_zeros(mat)
  imputed_mat <- impute_rounded_zeros(mat)
  clr_table <- calculate_clr(imputed_mat, base = base)
  if (flip) clr_table <- t(clr_table)
  clr_table
}