context("plot utilities tests")

test_that("h_var produces a textgrob", {

    test_p <- h_var('testing testing', 30)
    expect_equal(length(test_p), 11)
    expect_is(test_p, "grob")
    expect_is(test_p, "gDesc")
})

