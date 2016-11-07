## Hypothesis testing

> In statistics, one rule did we cherish:  
> P point oh five we publish, else perish!  
> Said Val Johnson, "that’s out of date, Our studies don’t replicate  
> P point oh oh five, then null is rubbish!""  
> — Roderick Little

### What is a p-value?

<div class="action">
**Read the article:**

Krzywinski, M., & Altman, N. (2013). Points of significance: Significance, P values and t-tests. Nature Methods, 10(11), 1041–1042. <http://doi.org/10.1038/nmeth.2698>

</div>

This article serves as a (re-)introduction of the basics of **hypothesis testing** and the meaning of **p-values**.
By definition in the article: a p-value is "the probability of sampling another observation from the null distribution that is as far or farther away from [the mean of the null distribution].
Here, the **null distribution** is the baseline or reference distribution, i.e. when there is no actual effect.
Hence the p-value is a measure of the unlikeliness of the data given we assume no effect, and so if more extreme data is very unlikely (e.g. $p<0.05$) then we may choose to reject the null hypothesis.
Note that this does not say anything else about the distribution that the data does arise from!

Perhaps the most important statement in the article is: "Statistical significance suggests but does not imply biological significance."

The remainder of the article describes the rational and method behind **one sample $t$-tests**.
We won't further focus on the technical details of this test here.

<div class="exercise">

### Exercise: One sample t-tests

Returning to our example of machinery.
The supplier has told us that the mean error for any measurement is 0.

Given a known standard, you have recorded errors of:

    1.04,  0.33,  2.18,  1.02, -0.04,  0.63,  0.90,  1.09,
    0.90,  0.18, -0.74,  0.46, -0.47, -0.62,  1.48,  0.62

Use the `t.test` function in R to find the p-value associated with the null hypothesis ($H_0$) that these samples are drawn from a normal distribution with mean 0.
Determine what the answer means.

Hint: you will need to use `t.test` with the `mu` parameter defined, `t.test(x, mu=0)`.

<div class="answer">

Using R, we obtain:

    > x <- c(1.04,  0.33,  2.18,  1.02, -0.04,  0.63,  0.90,  1.09,
    +        0.90,  0.18, -0.74,  0.46, -0.47, -0.62,  1.48,  0.62)
    > t.test(x, mu=0)

    One Sample t-test

    data:  x
    t = 2.869, df = 15, p-value = 0.01171
    alternative hypothesis: true mean is not equal to 0
    95 percent confidence interval:
     0.1439576 0.9760424
    sample estimates:
    mean of x
         0.56

We have a reported p-value of $0.01171$, which means we have a probability of around $0.01$ of seeing a more extreme value if our null hypothesis is true.
Note that is is common to reject the null hypothesis if $p<0.05$, but we did not specify this cutoff in the question!

</div>

</div>

We should note that if you are still finding p-values hard to understand and interpret, you are not alone.
[One informal survey found that even for scientists who understand the technical details, it can be difficult to explain the meaning of p-values in lay terms](https://fivethirtyeight.com/features/not-even-scientists-can-easily-explain-p-values/).

### Problems with p-values

<div class="action">
**Read the article:**

Halsey, L. G., Curran-Everett, D., Vowler, S. L., & Drummond, G. B. (2015). The fickle P value generates irreproducible results. Nature Methods, 12(3), 179–185. <http://doi.org/10.1038/nmeth.3288>

</div>

P-values, and their use, have recently come under much scrutiny —
this article explains some of the reasons why.


...


### Ethics of p-values

<div class="action">

**Read Part 1 of:**

[Science isn't broken ](https://fivethirtyeight.com/features/science-isnt-broken/#part1)

**Use the 'Hack Your Way To Scientific Glory' interactive visualisation** to show both Democrats and Republicans are good for the US economy.

</div>

...

### How to approach p-values

In 2016 the American Statistical Association published their own set of guidance about the appropriate use of p-values^[Wasserstein, R. L., & Lazar, N. A. (2016). The ASA's statement on p-values: context, process, and purpose. The American Statistician. <http://doi.org/10.1080/00031305.2016.1154108>].

1. P-values can indicate how incompatible the data are with a specified statistical model.
2. P-values do not measure the probability that the studied hypothesis is true, or the probability that the data were produced by random chance alone.
3. Scientific conclusions and business or policy decisions should not be based only on whether a p-value passes a specific threshold.
4. Proper inference requires full reporting and transparency.
5. A p-value, or statistical significance, does not measure the size of an effect or the importance of a result.
6. By itself, a p-value does not provide a good measure of evidence regarding a model or hypothesis.

...

### Significance versus power versus effect size

> With great power comes great responsibility

<div class="action">
**Read the article:**
Krzywinski, M., & Altman, N. (2013). Points of significance: Power and sample size. Nature Methods, 10(12), 1139–1140. <http://doi.org/10.1038/nmeth.2738>

</div>

...
