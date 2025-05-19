### Notes on Methodology

This pay equity analysis tool studies whether disparity in pay is present within a point-in-time snapshot of employees against a user-selected focal group.  The data you upload are assumed to be a roster or snapshot of your workforce.  At a minimum, your dataset should contain the following columns:

1. A column of pay information, whether that is base pay, total compensation, or some specific add-on pay, such as bonus.  It may be beneficial to have columns for all types of pay in your company and run a separate report for each type of pay.  Be aware that if the data contains employees who worked only part of the snapshot period, there may be a false appearance of underpaying those employees.  This is also true in the case of part-time employees.  Therefore, please ensure that the pay data are standardized to a common rate, such as hourly or annualized full-time equivalent.  

1. A column representing the pay grouping.  These are groups of employees who are presumably similar enough in the workforce that comparing pay is justifiable.  This may be defined as job title, job family, grade, career level, or some other factor.  It may be a combination of factors.  Note that groups combining employees exempt from the Fair Labor Standards Act (FLSA) with employees who are not is generally discouraged.

1. A column representing protected group status.  Generally speaking, this is race or gender, but you may want to focus on people with disabilities or veteran status also.  You will need to run separate reports for each focal group of interest.

Once data are uploaded, a series of t-tests is conducted: one for every pay group (where possible), and one for the dataset overall.  A t-test value highlighted in red indicates potentially statistically significant disparity against the focal group.  A t-test value highlighted in blue indicates potentially statistically significant disparity in favor of the focal group (i.e., the focal group is actually overpaid).  Note that we say "potentially" here because if you see a red or blue value, you should check the t-test's associated p-value to ensure it is _less than_ .05.  A p-value < .05 means that there is less than a 1 in 20 chance you would see the observed disparity if the pay process was fair, and is the generally accepted threshold for a statistically significant difference between groups.

The formula for the two-group t-test is available in all basic statistical textbooks.

This application requires at least 2 focal and 2 non-focal employees in a pay group to ensure adequate degrees of freedom for analysis.  For the total workforce, this requirement is increased to 5 in each group.  If you note a large disparity in terms of dollar value or percentage but the t-test does not appear, you should form similarly-situated pairs of employees and compare their pay on a pairwise basis.

### Limitations

This application assumes pay is measured in US dollars.

The t-test assumes that the data are normally distributed, the variances of groups are equal, and that errors are independent.  

- If the data appear non-normal, one solution is to convert the pay variable of interest to its natural (base _e_) logarithm and submit the log-pay data to the application.  However, please note that if you use log-pay data, the disparity values will still appear with dollar signs, which is obviously nonsensical.  Also, the % disparity graph will no longer be valid.

- If the groups have unequal variances, the t-test value remains the same, but it should be evaluated against Welch's corrected degrees of freedom (df), which will be lower than the standard df = n1 + n2 - 2, making the test less powerful.  

- Dependent errors would only occur in the situation where your data contained multiple records per employee (time series, multiple snapshots, or transactional data), so to avoid this issue simply ensure each employee appears once.

The analysis also assumes that race/gender groups are roughly equal on all unmeasured pay-related factors, such as tenure, level of education, and so forth.  To the extent this is not the case, you may wish to follow-up with regression or form similarly-situated pairs of employees and compare their pay on a pairwise basis.

### Disclaimer and Privacy

This application and its underlying code are presented for __technical demonstration purposes only__.  A true pay equity analysis involves much more than what is presented here, and should be conducted under the advice of counsel. 

This application does not connect to any database, data warehouse, or permanent data storage device.  Data are uploaded to working memory only.  When the application is exited, the data and results are deleted.  Still, users should take care not to upload personally identifiable information to the application, such as name, social security number, and so on.  

Use this application at your own risk.