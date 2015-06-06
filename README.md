# Audio Time Shifting
Determining time shift between two audio files.

The result of the function is number of seconds:
<p align="center">
  <img src="https://github.com/Vaberer/audio_time_shifting/blob/master/picture1.png?raw=true" />
</p>

Demnostration of finding time shift between two audio files in Objective-C compatible with iOS8.

Sample code contains two audio files in Bundle in which we perform cross-correlation
and determine time shift is seconds.

We were recording a youtube song where the second audio - ```audio2.m4a``` is shifted in 3 minutes. 

The code is also optimalized by <b>50 times</b>. We presume that sample rate and file formats of two audio files are equal.

<h2>Author</h2>

Patrik Vaberer, patrik.vaberer@gmail.com<br/>
<a target="_blank" href="https://sk.linkedin.com/in/vaberer">LinkedIn</a><br>
<a target="_blank" href="http://vaberer.me">Blog</a>

Thanks to:
Tomas Milo
<h2>Licence</h2>

PVGuide is available under the MIT license. See the LICENSE file for more info.

