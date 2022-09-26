test_that("fix_windows_url works properly", {
  testthat::skip_if_not(is_windows())

  # Should add file:/// to file paths
  expect_equal(
    suppressWarnings(fix_windows_url("c:/path/file.html")),
    "file:///c:/path/file.html"
  )
  expect_equal(
    suppressWarnings(fix_windows_url("c:\\path\\file.html")),
    "file:///c:/path/file.html"
  )

  # Currently disabled because I'm not sure exactly should happen when there's
  # not a leading drive letter like "c:"
  # expect_equal(fix_windows_url("/path/file.html"), "file:///c:/path/file.html")
  # expect_equal(fix_windows_url("\\path\\file.html"), "file:///c:/path/file.html")
  # expect_equal(fix_windows_url("/path\\file.html"), "file:///c:/path/file.html")

  # Shouldn't affect proper URLs
  expect_equal(fix_windows_url("file:///c:/path/file.html"), "file:///c:/path/file.html")
  expect_equal(fix_windows_url("http://x.org/file.html"), "http://x.org/file.html")
})
