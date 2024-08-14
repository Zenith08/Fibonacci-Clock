# **Fibonacci Clock with Time Zones**
### Introduction:
Processing was chosen because it is quick for someone to set up a development environment, and it provided me quick access to GUI functions. However, it is poorly equipped to handle changing resolutions so that functionality was disabled.
The MVC design pattern was used separating data from the view, since Processing treats code in the "global" scope differently, this code became the View, while all Model and Control functions are handled within sub-classes.

### Assumptions:
- Since the angle between clock hands was asked for an analogue clock should be displayed.
- An alarm includes a sound effect.
- The sound effect is not part of the task, as such it is acquired from [pixabay](https://pixabay.com/sound-effects/search/alarms/) and is royalty free.
- The notification icon was made in Paint.Net and while it does not display it is still needed for the application to run.
- This application is being run on a computer with time set to Vancouver local time.
- Daylight Savings has not changed for any of the included cities.

### Steps to run:
1. Download Processing [here](https://processing.org/).
2. Open the project with File -> Open and choose Tenzr_FibonacciClock.pde.
3. You may need to add the sound library, to do this choose Sketch -> Import Library -> Manage Libraries and find sound
4. Click the Play arrow in the top left.
