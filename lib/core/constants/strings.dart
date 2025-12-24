class AppStrings {
  static const String cancel = 'Cancel';
  static const String ok = 'OK';
  
  // Timer Mode - General
  static const String timerModeTitle = 'Timer Mode';
  static const String timerModeLabel = 'Timer mode';
  static const String timerModeHelper = 'Choose the appropriate timer mode';
  
  // Timer Mode - Simple/Advanced Toggle
  static const String simpleMode = 'Simple Mode';
  static const String advancedMode = 'Advanced Mode';
  static const String switchToAdvanced = 'Switch to Advanced';
  static const String switchToSimple = 'Switch to Simple';
  
  // Timer Mode - Countdown Option
  static const String timerModeCountdown = '25:00 → 00:00';
  static const String timerModeCountdownTitle = '25:00 → 00:00';
  static const String timerModeCountdownDesc = 'Count down from 25 minutes until time runs out';
  
  // Timer Mode - Count Up Option
  static const String timerModeCountUp = '00:00 → ∞';
  static const String timerModeCountUpTitle = '00:00 → ∞';
  static const String timerModeCountUpDesc = 'Start counting from 0 until stopped manually';
  
  // Timer Mode - Custom Option
  static const String timerModeCustom = 'Custom';
  static const String timerModePomodoro = 'Pomodoro (25 minutes)';
  static const String timerModeCountUpInfinite = 'Count up infinite';
  
  // Work & Break Duration
  static const String workDurationLabel = 'Work Duration (minutes)';
  static const String workDurationHelper = 'Enter 1-480 minutes';
  static const String breakDurationLabel = 'Break Duration (minutes)';
  static const String breakDurationHelper = 'Enter 1-60 minutes';
  
  // Sessions
  static const String sessionsLabel = 'Pomodoro Sessions';
  static const String sessionsHelper = 'Enter 1-10 sessions';
  
  // Sound Settings
  static const String soundLabel = 'Notification Sound';
  static const String soundHelper = 'Play sound when timer ends';
  static const String notificationSoundLabel = 'Notification Sound';
  static const String notificationSoundHelper = 'Choose notification sound';
  static const String soundBell = 'Bell';
  static const String soundChime = 'Chime';
  static const String soundAlarm = 'Alarm';
  
  // Auto Switch
  static const String autoSwitchLabel = 'Auto Switch Sessions';
  static const String autoSwitchHelper = 'Automatically switch between work and break';
  
  // Strict Mode
  static const String strictModeTitle = 'Strict Mode Settings';
  static const String strictModeOffLabel = 'Off';
  static const String strictModeOffHelper = 'Turn off all Strict Mode';
  static const String appBlockingLabel = 'Block Apps';
  static const String appBlockingHelper = 'Prevent opening selected apps while timer is running';
  static const String flipPhoneLabel = 'Flip Phone';
  static const String flipPhoneHelper = 'Require keeping phone face down while timer is running';
  static const String exitBlockingLabel = 'Prohibit Exit';
  static const String exitBlockingHelper = 'Prevent exiting app while timer is running';
  static const String selectApps = 'Select Apps';
  static const String selectAppsTitle = 'Select Apps to Block';
  
  // Error Messages
  static const String timerRunningError = 'Please stop the timer completely or wait for it to finish before adjusting Timer Mode!';
  
  // Time Presets
  static const String workDuration15Min = '15 minutes';
  static const String workDuration25Min = '25 minutes';
  static const String workDuration45Min = '45 minutes';
  static const String workDuration60Min = '60 minutes';
  static const String breakDuration5Min = '5 minutes';
  static const String breakDuration10Min = '10 minutes';
  static const String breakDuration15Min = '15 minutes';
  static const String breakDuration30Min = '30 minutes';
}