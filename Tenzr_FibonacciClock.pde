import java.time.LocalDateTime;
import java.time.Duration;
import java.lang.Math;
import java.awt.*;
import java.awt.TrayIcon.MessageType;
import javax.imageio.*;
import processing.sound.*;

/**
 * @brief Processing by default runs your code as an internal part of a PApplet class, this is how all of the draw functions are readily defined.
 */
// The globally accessible data source for the frontend.
TimeManagement timeManager;

/**
 * @brief The default Processing message for initialization
 */
void setup() {
  fibTest();
  // P2D here sets up the app to use OpenGL accelerated 2D rendering.
  size(640, 360, P2D);
  windowResizable(false);
  windowTitle("Fibonacci Clock");
  frameRate(60);
  textAlign(CENTER);
  
  // Init data
  // We have to load the sound file here because a PApplet has to be passed in.
  timeManager = new TimeManagement(new SoundFile(this, "alarm-clock-90867.mp3"));
}

/**
 * @brief The draw function for updating and rendering each frame.
 */
void draw() {
  // Refresh Data
  timeManager.tick();

  // Do Rendering
  background(255);
  
  // drawClock(timeManager.getCurrentTime(-5), 100, 100);
  drawCity("Vancouver", 0, 320);
  drawCity("London", 8, 160);
  drawCity("Tokyo", 16, 480);
  
  fill(0);
  textSize(24);
  Duration timeToAlarm = timeManager.getTimeToNextAlarm();
  double totalSeconds = timeToAlarm.getSeconds();
  int hours = (int)Math.floor(totalSeconds / 3600.0);
  int minutes = (int)Math.floor((totalSeconds % 3600.0) / 60);
  int seconds = (int)Math.floor(totalSeconds % 60);
  
  String secondsS = zeroPad(seconds);
  String minutesS = zeroPad(minutes);
  String hoursS = "" + hours;

  if (hours != 0) {
    text("Next alarm in: " + hoursS + ":" + minutesS + ":" + secondsS, 320, 340);
  } else {
    text("Next alarm in: " + minutesS + ":" + secondsS, 320, 340);
  } 
}

/**
 * @brief Helper function to draw all of the necessary information about a given city.
 * @param name The name of the city to draw, used as a title.
 * @param timeOffset The time difference between this application's local time and the chosen city.
 * @param x The x coordinate the city should be drawn at. The cities information is centered at this x coordinate.
 */
void drawCity(String name, int timeOffset, int x) {
  LocalDateTime cityTime = timeManager.getCurrentTime(timeOffset);
  textSize(24);
  fill(0);
  text(name, x, 25);
  
  drawClock(cityTime, x, 100);
  
  fill(0);
  textSize(24);
  text(cityTime.getHour() + ":" + zeroPad(cityTime.getMinute()), x, 200);
}

final float clockDiameter = 100;
final float hourHandRadius = 25f;
final float minuteHandRadius = 45f;

/**
 * @brief Helper function to draw an analogue clock.
 * @param time The time the clock should be showing.
 * @param x The x position to center the clock face on.
 * @param y The y position to center the clock face on.
 */
void drawClock(LocalDateTime time, int x, int y) {
  TimeManagement.ClockAngles clockAngles = timeManager.getClockHands(time);
  fill(255);
  circle(x, y, clockDiameter);
  // System.out.println("Clock at " + clockAngles.hourAngle + " for time " + time.getHour() + ":" + time.getMinute());
  stroke(0);
  // hour hand
  line(x, y, x + (float)Math.sin(Math.toRadians(clockAngles.hourAngle)) * hourHandRadius, y - (float)Math.cos(Math.toRadians(clockAngles.hourAngle)) * hourHandRadius);
  // minute hand
  line(x, y, x + (float)Math.sin(Math.toRadians(clockAngles.minuteAngle)) * minuteHandRadius, y - (float)Math.cos(Math.toRadians(clockAngles.minuteAngle)) * minuteHandRadius);
  
  fill(0);
  textSize(12);
  text("Angle between hands: " + clockAngles.angleDifference, x, y + clockDiameter/2 + 15);
}

private String zeroPad(int number) {
  if (number < 10) {
    return "0" + number;
  } else {
    return "" + number;
  }
}

/**
 * @brief A function to run component tests the fibonacci sequence code.
 */
void fibTest() {
  // Test fibonacci stepper
  int[] fibonacciNumbers = {0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144};
  SteppingFibonacci testSubject = new SteppingFibonacci();
  
  for (int i = 0; i < fibonacciNumbers.length; i++) {
    int nextFib = testSubject.stepNext();
    if (nextFib != fibonacciNumbers[i]) {
      System.out.println("Error detected on fib number " + i + " actual: " + nextFib + " expected: " + fibonacciNumbers[i]);
      return;
    }
  }

  System.out.println("All tests completed successfully");
}

/**
 * @brief The main system to trakc time and trigger alarms.
 */
class TimeManagement {
  private LocalDateTime timeThisFrame;

  private SteppingFibonacci fibonacciTracker;
  private LocalDateTime nextAlarm;
  
  private SoundFile alarmSound;
  
  /**
   * @brief Constructs a default TimeMangement object, it requires an alarmSound to be passed in because alarm sounds can only be loaded by PApplets.
   * @param alarm The sound to play when an alarm goes off.
   */
  public TimeManagement(SoundFile alarm) {
    timeThisFrame = LocalDateTime.now();
    fibonacciTracker = new SteppingFibonacci();
    nextAlarm = timeThisFrame;
    
    this.alarmSound = alarm;
  }

  /**
   * @brief The entry point called by the rendering loop to update 
   */
  public void tick() {
    // Update time for the entire frame
    timeThisFrame = LocalDateTime.now();

    // Check if the current timer has passed
    if (!nextAlarm.isAfter(timeThisFrame)) {
       // if yes -> send alarm, create new timer
      sendAlarm();
      setNextAlarm();
    }
    // if no -> take no action
  }

  /**
   * @brief Plays a sound and sends a notification when an alarm should go off.
   */
  private void sendAlarm() {
    // Sends a notification
    SystemTray tray = SystemTray.getSystemTray();
    
    Image image = Toolkit.getDefaultToolkit().createImage("notification.png");
    TrayIcon trayIcon = new TrayIcon(image, "Alarm Clock");
    
    trayIcon.setImageAutoSize(true);
    try {
      tray.add(trayIcon);
    } catch (AWTException e) {
      // skip
    }
    trayIcon.displayMessage("Alarm!", "Hours since the last alarm: " + fibonacciTracker.peekNext(), MessageType.INFO);
    tray.remove(trayIcon);
    // Plays a sound
    alarmSound.play();
  }

  /**
   * @brief Sets the time the next alarm should go off at using the fibonacci sequence.
   */
  private void setNextAlarm() {
    // Step to the next increment.
    fibonacciTracker.stepNext();
    // Then set the alarm based on the next time.
    nextAlarm = timeThisFrame.plusHours(fibonacciTracker.peekNext());
  }

  /**
   * @brief Gets the current time offset by the provided number of hours.
   * @param offsetHours The number of hours to offset the time by.
   * @return The current time offset by the provided number of hours.
   */
  public LocalDateTime getCurrentTime(int offsetHours) {
    return timeThisFrame.plusHours(offsetHours);
  }

  /**
   * @brief A helper function to identify how long is left before the next alarm will sound.
   * @return A Duration object containing the total number of seconds until the next alarm.
   */
  public Duration getTimeToNextAlarm() {
    return Duration.between(timeThisFrame, nextAlarm);
  }

  /**
   * @brief Gets the angles that a clocks hands should be starting with 12:00 being at 0 degrees.
   * @param time The time the clock hands should represent.
   * @return A container with the angle each hand should be at, plus the difference between the two angles.
   */
  public ClockAngles getClockHands(LocalDateTime time) {
    ClockAngles result = new ClockAngles();
    result.hourAngle = 0.5f * time.getMinute() + 30f * twelveHourTime(time.getHour());
    result.minuteAngle = 6.0f * time.getMinute();

    result.angleDifference = Math.abs(result.hourAngle - result.minuteAngle);

    return result;
  }
  
  /**
   * @brief Converts a 24 hour time to a 12 hour time (0-indexed).
   * @param twentyFourHour The hour in 24 hour format.
   * @return If twentyFourHour > 12, returns twentyFourHour - 12, otherwise returns twentyFourHour.
   */
  private int twelveHourTime(int twentyFourHour) {
    if(twentyFourHour > 12) {
      return twentyFourHour - 12;
    }
    else
    {
      return twentyFourHour;
    }
  }

  /**
   * @brief A container class to store the angles of a clock's hands for an analogue clock.
   */
  public class ClockAngles {
    public float hourAngle;
    public float minuteAngle;
    
    public float angleDifference;
  }
}

/**
 * @brief A helper class to return each fibonacci number in sequenceone after the other.
 */
class SteppingFibonacci {
  private int next0;
  private int next1;

  /**
   * @brief A default constructor that initializes the fibonacci sequence to start at 0.
   */
  public SteppingFibonacci() {
    next0 = 0;
    next1 = 1;
  }

  /**
   * @brief Gets the next number in the fibonacci sequence, then steps the sequence.
   * @return The next number in the fibonacci sequence.
   */
  public int stepNext() {
    int output = next0;
    
    int continuation = next0 + next1;
    next0 = next1;
    next1 = continuation;

    return output;
  }
  
  /**
   * @brief Gets the next number in the fibonacci sequence but does not step the sequence.
   * @return The next number in the fibonacci sequence.
   */
  public int peekNext() {
    return next0;
  }
}
