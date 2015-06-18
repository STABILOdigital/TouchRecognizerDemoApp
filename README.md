# TouchRecognizerDemoApp
Quick-and-dirty demo app to try out the superb palm rejection possible with the STABILO SMART stylus

For documentation please point your browser to https://stabilodigital.com/support/stabilo-smartstylus/sdk/
User name is „appdeveloper“ and the password is „letmein“. Sorry for the inconvenience, but the restricted access is a must.

***Quick Overview:***

**General**

We have created a new type of stylus which allows to work on projected-capacitive touchscreens while resting the palm of the hand on them. This palm rejection technology uses the stylus and a special software filter.

The SID_PulsedTouchRecognizer  is a custom touch recognizer for iOS for version iOS7 and higher that collects touch information and presents it in a number of public methods. Inside, it assigns touches to sequences of touch events, which are caused by the user stroking the touchscreen with a special pen and his/her hand. The pen causes a distinct pattern of interruptions in the touch sequence. This is recognized by the touchRecognizer and distinguished from palm or finger touches.

Many palm touches can be filtered early by observing the duration of touch events. In its simplest implementation, the calling method transfers touch handling to the PulsedTouchRecognizer completely. In this case, the calling method will receive a notification with all possible pen touch events every time a touch event has ended.

Alternatively, the calling method can choose to handle touch events itself, but then needs to report all touch events (touchBegan, touchMoved and touchEnded) to the PulsedTouchRecognizer. Again, it will receive information on what is a possible pen touch event only with the return value of the touchEnded method of the PulsedTouchRecognizer.

Internally, the PulsedTouchRecognizer will observe the timing of touches. A touch sequence with the typical on-off pattern of the STABILO SMARTStylus will quickly recognized. Typical times for a recognizable touch pattern are between 0.1 to 0.25 sec. With the first longer pen stroke, the PulsedTouchRecognizer will identify an enclosing rectangle, so any consecutive pen strokes in its vicinity will be immediately recognized as pen strokes. Equally, another rectangle enclosing palm touches is defined as soon as the first palm touches are identified as such. (Both rectangles are initially set to the size of zero width and height.)

**Touch filtering**

Due to the different source of a touch sequence, the SID_PulsedTouchRecognizer needs to filter these sequences. To ensure proper function of the touch recognizer, several strategies are used:

The on-off pattern of the pen is recognized. Touches which last for more than an adjustable number of digitizer cycles are discarded.
In iOS8 and above, the radius of the touch is evaluated, and only touches below an adjustable multiple of the device based touch radius base are accepted as candidates for pen input. The classification of a touch as a palm touch is performed by checking if its radius is above a preset multiple of radius base and if the touch duration is above the preset limit for pen touches.
Rectangles with previous pen input and with previous palm touches are defined and constantly updated. If pen touches have been registered shortly before, new touches should be in temporal and spatial vicinity to those touches to be accepted. The SID_PulsedTouchRecognizer constantly updates an average pen speed and discards points which would need more than a preset multiple of this average speed to be connected to an existing line of touches.

**Hardware sample**

The whole thing will not work without a small piece of hardware. If you want to develop for the SMART stylus and need a sample, please let us know at Peter.Kaempf@stabilo.com

