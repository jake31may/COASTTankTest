function kR = ftokR(frequencies,waterlineRadius)

dispConst = (4*pi()^2)/9.81;
fsquared = frequencies.^2;
k = dispConst.*fsquared;

kR = k.*waterlineRadius;