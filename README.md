## iAXMaterialProgress

A material style progress wheel for iOS

[Android version by Nico Hormazábal](https://github.com/pnikosis/materialish-progress)

This is how it looks in indeterminate mode (the spinSpeed here is 0.64 which is the default, look below how to change it):

![spinning wheel](spinningwheel.gif)

And in determinate mode (here the spinSpeed is set to 0.333):

![spinning wheel](spinningwheel_progress.gif)

## Usage 

```objc
iAXMaterialProgress *progress = [[iAXMaterialProgress alloc] init];
...
[self.view addSubview:progress];
[progress start];
```

- **barColor:** color, sets the small bar's color (the spinning bar in the indeterminate wheel, or the progress bar)
- **barWidth:** dimension, the width of the spinning bar
- **rimColor:** color, the wheel's border color
- **rimWidth:** dimension, the wheel's width (not the bar)
- **spinSpeed:** float, the base speed for the bar in indeterminate mode, and the animation speed when setting a value on progress. The speed is in full turns per - - second, this means that if you set speed as 1.0, means that the bar will take one second to do a full turn.
- **barSpinCycleTime:** integer, the time in milliseconds the indeterminate progress animation takes to complete (extending and shrinking the bar while spinning)
- **circleRadius:** dimension, the radius of the progress wheel, it will be ignored if you set fillRadius to true
- **linearProgress:** boolean, set to true if you want a linear animation on the determinate progress (instead of the interpolated default one).


## Author 
- **Amir Hossein Aghajari**

License
=======

    Copyright 2020 Amir Hossein Aghajari
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

<br><br>
<div align="center">
  <img width="64" alt="LCoders | AmirHosseinAghajari" src="https://user-images.githubusercontent.com/30867537/90538314-a0a79200-e193-11ea-8d90-0a3576e28a18.png">
  <br><a>Amir Hossein Aghajari</a> • <a href="mailto:amirhossein.aghajari.82@gmail.com">Email</a> • <a href="https://github.com/Aghajari">GitHub</a>
</div>
