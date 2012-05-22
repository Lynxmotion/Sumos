'Program name: basumo04.bas for Basic Atom Pro.
'This version uses the pulsout function to control the motors.
'This is for a sumo with two line detectors, and two opponent detectors.


LeftOpDetect	var word
RightOpDetect	var word

test:

adin 0,LeftOpDetect
adin 1,RightOpDetect
	serout S_OUT,i57600,[dec3 LeftOpDetect\3," ",dec3 RightOpDetect\3," ",13]
LeftOpDetect = LeftOpDetect*10
sound 9, [10\LeftOpDetect]

'goto test
'end


LeftMotor 	var word
RightMotor 	var word
Back 		var byte
Turn 		var byte
EdgeDetect 	var byte
aa 			var byte
ButA		var bit
ButB		var bit
ButC		var bit

LMCh 		Con 14	'Left Motor is connected to Pin14
RMCh 		Con 15	'Right Motor is connected to Pin15
ButDown		Con 0

input p2
input p3
low LMCh	'Left motor-control channel
low RMCh	'Right motor-control channel
Back = 20	'this affects how far the robot backs up from the line.
Turn = 20	'this affects how far the robot turns after backing.
ButA = 0
ButB = 0
ButC = 0

sound 9, [100\880, 100\988, 100\1046, 100\1175]	'four quick ascending beeps.

Start:
ButA = IN4	'This reads the value on Pin4 and puts it into the var ButA
ButB = IN5	'Value on Pin5 into var ButB
ButC = IN6	'Value on Pin6 into var ButC

if ButA = ButDown then
	sound 9, [100\880, 100\0, 100\880, 100\0]	'two quick beeps.
	goto BehaviorA
endif
if ButB = ButDown then
	sound 9, [100\988, 100\0, 100\988, 100\0]	'two quick beeps.
	goto BehaviorB
endif
if ButC = ButDown then
	sound 9, [100\1046, 100\0, 100\1046, 100\0] 'two quick beeps.
	goto BehaviorC
endif
goto Start

BehaviorA:		'Back up and Gradually Turn 90? at start
ButA = IN4
if ButA = ButDown then goto BehaviorA
for aa=1 to 5	'Beep at the end of each of the 5 seconds in the delay.
pause 900
sound 9, [100\880]
next

for aa=1 to 40		'Turn Right in reverse
LeftMotor = 4000	'Reverse, full speed
RightMotor = 2800	'Reverse, slow
gosub ServoPulses
next
goto Main

BehaviorB:		'Turn Right, do Half-Circle at start
ButB = IN5
if ButB = ButDown then goto BehaviorB
for aa=1 to 5	'Beep at the end of each of the 5 seconds in the delay.
pause 900
sound 9, [100\880]
next

for aa=1 to Turn	'Right turn in place
LeftMotor = 2000	'Forward, full speed
RightMotor = 2000	'Reverse, full speed
gosub ServoPulses
next
for aa=1 to 80		'Arc Left (gradual turn)
LeftMotor = 2700	'Forward, slow
RightMotor = 4000	'Forward, full speed
gosub ServoPulses
next
goto Main

BehaviorC:		'Go Forward at start ("Normal" sumo startup)
ButC = IN6
if ButC = ButDown then goto BehaviorC
for aa=1 to 5	'Beep at the end of each of the 5 seconds in the delay.
pause 900
sound 9, [100\880]
next
goto Main

Main:
LeftMotor = 2000	'Forward, full speed
RightMotor = 4000	'Forward, full speed

adin 0,LeftOpDetect	'Opponent Detection
adin 1,RightOpDetect

if (LeftOpDetect > 200) AND (RightOpDetect > 200) then
	RightMotor = 4000
	LeftMotor = 2000
elseif LeftOpDetect > 200
	LeftMotor = 4000
elseif RightOpDetect > 200 
	RightMotor = 2000
endif

gosub ServoPulses

EdgeDetect = (ina&%1100)	'Look at the 1st I/O nibble and mask off bit 1 and 2.
if EdgeDetect = %0100 then LeftDetect	'Look for left edge detector.
if EdgeDetect = %1000 then RightDetect	'Look for right edge detector.
if EdgeDetect = %1100 then LeftDetect	'Look for both left and right. 
goto Main

LeftDetect:			'This is where the pulses are setup for the 
for aa=1 to Back	'Scorpion motor controller for left detect.
LeftMotor = 4000	'Reverse, full speed
RightMotor = 2000	'Reverse, full speed
gosub ServoPulses
next
for aa=1 to Turn
LeftMotor = 2000	'Reverse, full speed
RightMotor = 2000	'Forward, full speed
gosub ServoPulses
next
goto Main

RightDetect:		'This is where the pulses are setup for the 
for aa=1 to Back	'Scorpion motor controller for right detect.
LeftMotor = 4000	'Reverse, full speed
RightMotor = 2000	'Reverse, full speed
gosub ServoPulses
next
for aa=1 to Turn
LeftMotor = 4000	'Forward, full speed
RightMotor = 4000	'Reverse, full speed
gosub ServoPulses
next
goto Main



ServoPulses:		'This is where the pulses are actually generated.
pulsout LMCh, LeftMotor 	'2000 = forward, 3000 = stop, 4000 = reverse
pulsout RMCh, RightMotor 	'4000 = forward, 3000 = stop, 2000 = reverse
pause 20
return