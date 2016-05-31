context('linking')

test_that('NYS linking returns known performance levels', {
  expect_equal(ny_linking('Reading', 3, 'Spring', 215), 'Level 3')
  expect_equal(ny_linking('Reading', 8, 'Spring', 235), 'Level 3')
  expect_equal(ny_linking('Reading', 8, 'Spring', 235, 'proficient'), TRUE)
  
  expect_equal(ny_linking('Mathematics', 5, 'Spring', 219), 'Level 2')
  expect_equal(ny_linking('Mathematics', 5, 'Spring', 232), 'Level 3')
  expect_equal(ny_linking('Mathematics', 5, 'Spring', 247), 'Level 4')
  
  expect_equal(ny_linking('Reading', 4, 'Winter', 198), 'Level 1')
  expect_equal(ny_linking('Reading', 4, 'Winter', 212), 'Level 2')
  expect_equal(ny_linking('Reading', 4, 'Winter', 217), 'Level 3')
  expect_equal(ny_linking('Reading', 4, 'Winter', 228), 'Level 4')
  
  expect_equal(ny_linking('Mathematics', 7, 'Winter', 203), 'Level 1')
  expect_equal(ny_linking('Mathematics', 7, 'Winter', 225), 'Level 2')
  expect_equal(ny_linking('Mathematics', 7, 'Winter', 239), 'Level 3')
  expect_equal(ny_linking('Mathematics', 7, 'Winter', 253), 'Level 4')
  
})