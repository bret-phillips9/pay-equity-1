### Notes on Methodology

This pay equity analysis tool studies whether disparity in pay is present against a user-selected focal group.  The data you upload are assumed to be a roster or snapshot of your workforce.  

Once data are uploaded, a series of t-tests is conducted: one for every pay group (where possible), and one for the dataset overall.  A t-test value highlighted in red indicates potentially statistically significant disparity against the focal group.  A t-test value highlighted in blue indicates potentially statistically significant disparity in favor of the focal group (i.e., the focal group is actually overpaid).  Note that we say "potentially" here because if you see a red or green value, you should check the t-test's associated p-value to ensure it is _less than_ .05.  A p-value < .05 means that there is less than a 1 in 20 chance you would see the observed disparity if the pay process was fair.

The formula for the two-group t-test is available in all basic statistical textbooks.

### Limitations

The t-test assumes that the data are normally distributed, the variances of groups are equal, and that errors are independent.  If the data appear non-normal, one solution is to convert the pay variable of interest to its natural (base _e_) logarithm and submit the log-pay data to the application.  If the groups have unequal variances, the t-test value remains the same, but it should be evaluated against Welch's corrected degrees of freedom (df), which will be lower than the standard df = n1 + n2 - 2, making the test less powerful.  Dependent errors would only occur in the situation where your data contained multiple records per employee (multiple snapshots or transactional data), so to avoid this issue simply ensure each employee appears once.

The analysis also assumes that race/gender groups are roughly equal on all unmeasured pay-related factors, such as tenure, level of education, and so forth.  To the extent this is not the case, you may wish to follow-up with regression or pair-level comparisons.

### Disclaimer and Privacy

This application and its underlying code are presented for __technical demonstration purposes only__.  A true pay equity analysis involves much more than what is presented here, and should be conducted under the advice of counsel. 

This application does not connect to any database, data warehouse, or permanent data storage device.  Data are uploaded to working memory only.  When the application is exited, the data and results are deleted.  Still, users should take care not to upload personally identifiable information to the application such as name, social security number, and so on.  

Use this application at your own risk.