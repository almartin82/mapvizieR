context('linking')

test_that('NYS linking returns known performance levels', {
  expect_equal(ny_linking('Reading', 3, 'Spring', 215), 'Level 3')
  expect_equal(ny_linking('Reading', 8, 'Spring', 235), 'Level 3')
  expect_equal(ny_linking('Reading', 8, 'Spring', 235, 'proficient'), TRUE)
  
})