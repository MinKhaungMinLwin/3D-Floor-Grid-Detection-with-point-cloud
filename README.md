## Floor Tile detection with Matlab

This model first process the pointcloud data to 2D image.

Then train the convolutional neural network with prcessed 2D image data.

Use the pretrained model and apply canny for edge detection.
Blog: [Canny : opencv edge detection algorithm](https://docs.opencv.org/4.x/da/d22/tutorial_py_canny.html)
![image](https://www.google.com/imgres?q=canny%20edge%20detection&imgurl=https%3A%2F%2Fmiro.medium.com%2Fv2%2Fresize%3Afit%3A566%2F1*XAgKINgc2c2gNa2nV3zbNQ.png&imgrefurl=https%3A%2F%2Ftowardsdatascience.com%2Fcanny-edge-detection-step-by-step-in-python-computer-vision-b49c3a2d8123&docid=nEMUFvIY0oupxM&tbnid=73MQC1OmUy7-8M&vet=12ahUKEwjMo8S48YCKAxV9V2wGHYKdHvEQM3oECBgQAA..i&w=566&h=391&hcb=2&ved=2ahUKEwjMo8S48YCKAxV9V2wGHYKdHvEQM3oECBgQAA)

Line detection for hough transform and then fine hough lines.


