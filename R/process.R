

r_background_process <- function(..., envvars = NULL) {
  if (is.null(envvars)) {
    envvars <- callr::rcmd_safe_env()
  }
  callr::r_bg(..., env = envvars)
}
