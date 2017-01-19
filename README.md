# MDSA
Generates vectors of random numbers that are close to the mean even in high dimensions.


As pointed out in “The Master Algorithm” by Pedro Domingos, Normal distributions in high dimensions (greater than 3 variables) end up generating points that are more likely to be further from the mean than close to it.

This is simply the nature of mathematics. However on a practical level there can be a need for a high dimension system where the points are more likely to close the mean. In attempt to solve this problem, I created an algorithm I call the Multi-Dimensional Similarity Algorithm (MDSA). This algorithm is made to randomly generate points that are more likely to be close the mean, in any dimension. There is an over all standard deviation that can be set, but also deviations for specific dimensions (these are similar, but not identical to standard deviations). This allows for the relative scaling of specific dimensions/variables while maintaining a constant standard deviation from the mean.

The code is 90% comments and should explain the process even if the reader has no coding experience, and only knows high school level statistical terms. I suggest pasting the code into a code editor such as Sublime Text before attempting to read it. For best readability turn word wrapping off, and set the viewing syntax to Matlab.
