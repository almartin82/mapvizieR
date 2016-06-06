context('state pass functions')

test_that('new york state pass functions work', {
  
  ny_ex <- state_pass_prob(mapviz, 'NY')
  expect_equal(sum(ny_ex$predicted_pass, na.rm = TRUE), 819L)
})